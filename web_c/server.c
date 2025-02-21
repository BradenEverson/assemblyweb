/**
 * Simple server in C before I jump into Assembly
 */

#include <errno.h>
#include <unistd.h>
#include <netinet/in.h>
#include <stdio.h>
#include <string.h>
#include <arpa/inet.h>
#include <sys/socket.h>

#define PORT 7878
#define BUFFER_SIZE 1024

int main() {
    char response[] = 
        "HTTP/1.0 200 OK\r\n"
        "Server: server\r\n"
        "Content-type: text/html\r\n\r\n"
        "<html>Whaddup!</html>";

    char buf[BUFFER_SIZE];

    int socket_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (socket_fd == -1) {
        fprintf(stderr, "Failed to create socket: %s\n", strerror(errno));
        return 1;
    }
    printf("socket created!\n");

    struct sockaddr_in host_addr;
    int host_addr_len = sizeof(host_addr);

    host_addr.sin_family = AF_INET;
    host_addr.sin_port = htons(PORT);
    host_addr.sin_addr.s_addr = htonl(INADDR_ANY);

    struct sockaddr* host_addr_sock = (struct sockaddr *)&host_addr;

    int res = bind(socket_fd, host_addr_sock, host_addr_len);
    if (res != 0) {
        fprintf(stderr, "Failed to bind to socket: %s\n", strerror(errno));
        return 1;
    }
    printf("socket bound!\n");

    res = listen(socket_fd, SOMAXCONN);
    if (res != 0) {
        fprintf(stderr, "Failed to start listening: %s\n", strerror(errno));
        return 1;
    }

    while (1) {
        int new_fd = accept(socket_fd, host_addr_sock, (socklen_t *)&host_addr_len);

        if (new_fd < 0) {
            fprintf(stderr, "Failed to accept connection: %s\n", strerror(errno));
            return 1;
        }
        printf("New connection yay!\n");

        int try_read = read(new_fd, buf, BUFFER_SIZE);
        if (try_read < 0) {
            fprintf(stderr, "Failed to read payload: %s\n", strerror(errno));
            return 1;
        }
        
        printf("From client: \"%s\"\n", buf);

        res = write(new_fd, response, strlen(response));
        if (res < 0) {
            fprintf(stderr, "Failed to write to client: %s\n", strerror(errno));
            return 1;
        }

        close(new_fd);
    }

    return 0;
}
