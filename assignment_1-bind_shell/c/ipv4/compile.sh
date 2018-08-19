#!/bin/sh

binary='bind_shell'

echo '[+] Compiling...'
gcc "${binary}.c" -fno-stack-protector -shared -z execstack -Wnonnull -no-pie -o "${binary}"
