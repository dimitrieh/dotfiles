#!/usr/bin/env /usr/local/bin/python3

import json
import os
import subprocess

p = subprocess.Popen(
  ['infinit', 'journal', 'stat', '--script', '--as', 'strages'],
  stdout = subprocess.PIPE,
  env = {'PATH': '/usr/local/bin:%s' % os.environ['PATH']},
)
out, err = p.communicate()
res = json.loads(out.decode('utf-8'))

total_size = 0
for k, v in res.items():
  total_size += v['size']

def GetHumanReadable(size,precision=3):
    suffixes=[' B',' KB',' MB',' GB',' TB']
    suffixIndex = 0
    while size > 1024 and suffixIndex < 4:
        suffixIndex += 1 #increment the index of the suffix
        size = size/1024.0 #apply the division
    return "%.*f%s"%(precision,size,suffixes[suffixIndex])

total_size_readable = GetHumanReadable(total_size)

print(total_size_readable)
