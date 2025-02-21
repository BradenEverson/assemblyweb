CC=clang
CFLAGS=-g -Wall

all: server

server: server.o
	$(CC) $(CFLAGS) -o server server.o

server.o: server.c
	$(CC) $(CFLAGS) -c -o server.o server.c

clean:
	rm -rf *.o server
