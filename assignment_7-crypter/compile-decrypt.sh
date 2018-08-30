#!/bin/sh

gcc -o decrypt decrypt.c -lcrypto -lssl -fno-stack-protector -zexecstack
