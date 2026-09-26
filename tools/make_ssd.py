"""Build a bootable Acorn DFS disk image (.ssd) that runs a BBC BASIC program.

The disk holds one file, !BOOT, containing the program as plain text followed
by RUN. The catalogue sets boot option 3 (*EXEC), so SHIFT+BREAK (or an
emulator's autoboot) reads the file as if it were typed, at disk speed.
No BASIC tokeniser is needed.

Usage: python tools/make_ssd.py program.bas disk.ssd
"""
import os
import sys

SECTOR = 256
SECTORS = 400          # 40 track single sided
FIRST_DATA_SECTOR = 2  # sectors 0 and 1 hold the catalogue


def make_ssd(bas_path, ssd_path):
    text = open(bas_path, encoding='ascii').read().replace('\r\n', '\n').strip('\n')
    data = (text + '\nRUN\n').replace('\n', '\r').encode('ascii')
    if len(data) > (SECTORS - FIRST_DATA_SECTOR) * SECTOR:
        sys.exit(f'{bas_path} is too big for one disk')

    title = os.path.splitext(os.path.basename(bas_path))[0].upper()[:12].ljust(12).encode('ascii')
    img = bytearray(SECTORS * SECTOR)
    img[0:8] = title[:8]                          # sector 0: title, then file names
    img[8:15] = b'!BOOT  '
    img[15] = ord('$')                            # directory
    img[256:260] = title[8:]                      # sector 1: rest of title
    img[256 + 5] = 1 * 8                          # number of files * 8
    img[256 + 6] = (3 << 4) | (SECTORS >> 8)      # boot option 3 (*EXEC), sector count high bits
    img[256 + 7] = SECTORS & 0xFF
    length = len(data)                            # load and exec addresses are 0
    img[256 + 8:256 + 16] = bytes([0, 0, 0, 0, length & 0xFF, (length >> 8) & 0xFF,
                                   ((length >> 16) & 3) << 4 | (FIRST_DATA_SECTOR >> 8),
                                   FIRST_DATA_SECTOR & 0xFF])
    img[FIRST_DATA_SECTOR * SECTOR:FIRST_DATA_SECTOR * SECTOR + length] = data
    open(ssd_path, 'wb').write(img)


if __name__ == '__main__':
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    make_ssd(sys.argv[1], sys.argv[2])
    print(sys.argv[2])
