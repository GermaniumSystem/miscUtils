#/usr/bin/python3

'''
starPing.py - Check the status of a Starbound server by sending a protocol
request and verifying the server's protocol response with an expected result.
'''

from __future__ import print_function
import socket
import sys

socket.setdefaulttimeout(5)
# The protocol we tell the server we're using.
protoVer = 729

# These are the expected responses.
# First byte  = packet ID.
# Second byte = VLQ.
# Third byte  = True/False in response to "Do you support protocol protoVer?"
goodResp = b'\x01\x02\x01'
badPResp = b'\x01\x02\x00'

# Example proto729 ProtocolRequest packet:
#payload = b'\x00\x08\x00\x00\x02\xd9'

# This chunk of magic just takes the protoVer int, turns it into a 32-bit chunk
# of hex suitable for the payload, and sticks it onto the normal payload header.
payload = b'\x00\x08' + protoVer.to_bytes(4, byteorder='big')

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

try:
    host = sys.argv[1]
    port = int(sys.argv[2])
except:
    eprint("starPing.py - Malformed arguments. Usage: starPing.py <host> <port>")
    exit(2)

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

try:
    s.connect((host, port))
    s.send(payload)
    protoResp = s.recv(3)
except:
    eprint("starPing.py - Failed to connect to {}:{}!".format(host,port))
    exit(104)
if protoResp == goodResp:
    exit(0)
elif protoResp == badPResp:
    eprint("starPing.py - Protocol mismatch! Check the Starbound server's logs and update protoVer!")
    exit(0)
else:
    eprint("starPing.py - Unexpected response {}!".format(protoResp))
    exit(105)

