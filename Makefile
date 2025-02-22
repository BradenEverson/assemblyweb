CC=clang
CFLAGS=-g -Wall

all: server

server: server.o
	$(CC) $(CFLAGS) -nostartfiles -o server server.o

server.o: server.s
	$(CC) $(CFLAGS) -c -o server.o server.s

clean:
	rm -rf *.o server

