#/usr/bin/python3

'''
starPing.py - Check the status of a Starbound server by sending a protocol
request and verifying the server's protocol response with an expected result.
'''

from __future__ import print_function

import argparse
import socket
import sys
import textwrap


'''
Example proto729 ProtocolRequest packet:
 b'\x00\x08\x00\x00\x02\xd9'
   \__/\__/\______________/
    |   |   |
    |   |   +-- 32-bit int. Protocol version.
    |   +-- VLQ. Constant length, so we can cheese it.
    +-- Packet ID.
'''

'''
Example good ProtocolResponse packet:
 b'\x01\x02\x01'
   \__/\__/\__/
    |   |   |
    |   |   +-- Bool. The server supports the version stated in ProtocolRequest.
    |   +-- VLQ. Constant length, so we can cheese it.
    +-- Packet ID.
'''

defaultTimeout = 5
defaultProtoVer = 729 # The protocol we tell the server we're using.
goodResp = b'\x01\x02\x01'
badPResp = b'\x01\x02\x00'

class starPing(object):

    def __init__(self, silent=False, stdout=False):
        '''
        Initialize starPing.

        :param silent: Boolean, False.
        :param stdout: Boolean, False. Send output to STDOUT.
        :return: Null
        '''
        self.silent = silent
        self.stdout = stdout

    def eprint(self, *args, **kwargs):
        '''
        Given *args and **kwargs, pass both to print, with output as stdout or stderr.

        :return: Null
        '''
        if not self.silent:
            if self.stdout:
                print(*args, file=sys.stdout, **kwargs)
            else:
                print(*args, file=sys.stderr, **kwargs)

    def ping(self, host, port, ackOnly=False, protoVer=defaultProtoVer, silent=False, timeout=5):
        '''
        Given a host and port, ping a Starbound server.

        :param host:
        :param port:
        :param ackOnly: Only check for handshake completion?
        :param protover: Override protocol version to spoof.
        :param silent:
        :param timeout:
        :return: exit code integer.
        '''
        # This chunk of magic just takes the protoVer int, turns it into a 32-bit chunk
        # of hex suitable for the payload, and sticks it onto the normal payload header.
        self.payload = b'\x00\x08' + protoVer.to_bytes(4, byteorder='big')

        try:
            self.s = socket.create_connection((host, port), timeout)
            if ackOnly:
                self.s.close()
                return 0
            self.s.send(self.payload)
            self.protoResp = self.s.recv(3)
        except socket.timeout:
            self.eprint("X Failed to connect to {}:{}! Timeout after {} seconds.".format(host, port, timeout))
            return 100
        except socket.gaierror:
            self.eprint("X Failed to connect to {}:{}! Unknown host.".format(host, port))
            return 101
        except ConnectionRefusedError:
            self.eprint("X Failed to connect to {}:{}! Connection refused.".format(host,port))
            return 102
        except ConnectionResetError:
            self.eprint("X Failed to connect to {}:{}! Connection reset.".format(host,port))
            return 103
        except Exception as e:
            print(e)
            self.eprint("X Failed to connect to {}:{}!".format(host, port))
            return 104
        finally:
            try:
                self.s.close()
            except:
                pass
        if self.protoResp == goodResp:
            return 0
        elif self.protoResp == badPResp:
            self.eprint("! Protocol mismatch! Check the Starbound server's logs and update protoVer!")
            return 0
        else:
            self.eprint("X Unexpected response {}!".format(self.protoResp))
            return 200


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
            formatter_class=argparse.RawDescriptionHelpFormatter,
            description="Protocol-aware Starbound ping utility.",
            epilog=textwrap.dedent("""\
                    Exit codes:
                        0 - Success.
                        1 - Unhandled exception.
                        2 - Invalid syntax.
                      100 - Failed to connect: timeout.
                      101 - Failed to connect: unknown host.
                      102 - Failed to connect: connection refused.
                      103 - Failed to connect: connection reset.
                      104 - Failed to connect.
                      200 - Unexpected response.
                    """))
    parser.add_argument("host", type=str, help="IP or domain name to ping.")
    parser.add_argument("port", type=int, help="Port to ping.")
    parser.add_argument("-a", "--ackonly", action="store_true", help="Only check if a connection can be completed.")
    parser.add_argument("-P", "--proto", type=int, help="Protocol version to spoof. Defaults to {}".format(defaultProtoVer))
    parser.add_argument("-s", "--silent", action="store_true", help="Suppress all output.")
    parser.add_argument("-t", "--timeout", type=int, help="Seconds before timeout. Defaults to {}".format(defaultTimeout))
    parser.add_argument("--stdout", action="store_true", help="Send messages to STDOUT instead of STDERR.")
    parser.set_defaults(proto=defaultProtoVer, timeout=defaultTimeout)
    args = parser.parse_args()

    starPinger = starPing(silent=args.silent, stdout=args.stdout)
    retval = starPinger.ping(args.host, args.port, ackOnly=args.ackonly, protoVer=args.proto, timeout=args.timeout)
    exit(retval)
