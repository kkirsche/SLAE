#!/bin/sh

gcc -o polymorphic polymorphic.c -fno-stack-protector -zexecstack
