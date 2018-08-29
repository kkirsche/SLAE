#!/bin/sh

gcc -o original original.c -fno-stack-protector -zexecstack
