#!/usr/bin/env python2
# should be in /config/.acme.sh/helper/parse.py

import sys
import xml.etree.ElementTree as ET

if __name__ == '__main__':
    tree = ET.parse(sys.stdin)
    root = tree.getroot()

    if len(sys.argv) < 1:
        sys.exit(1)

    if sys.argv[1] == 'records':
        lookup = '_acme-challenge'
        found = []

        records = root.find('records')

        if records == None:
            sys.exit(1)

        for item in records.findall('item'):
            e_type = item.find('type')
            if e_type.text.strip() != 'TXT':
                continue

            recordid = item.find('recordid')
            host = item.find('host')

            if recordid == None or host == None:
                continue

            if lookup in host.text:
                found.append(recordid.text.strip())

        print ' '.join(found)
        sys.exit(0)

    if sys.argv[1] == 'record':
        if len(sys.argv) <= 1:
            sys.exit(1)
        lookup = sys.argv[2]
        found = ''

        for item in root.find('records').findall('item'):
            e_type = item.find('type')
            if e_type.text.strip() != 'TXT':
                continue

            recordid = item.find('recordid')
            data = item.find('data')

            if recordid == None or data == None:
                continue

            if lookup in data.text:
                found = recordid.text.strip()

        print found
        sys.exit(0)
