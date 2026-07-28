import sys
import socket

PORT = 22711
if len(sys.argv) < 4:
    print("Usage: SBMOHookTest.py game, type, message, [port]")
    quit()
COMMAND = str(sys.argv[1] + "¶" + sys.argv[2] + "¶" + sys.argv[3])
if len(sys.argv) > 4:
    PORT = int(sys.argv[4])

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.sendto(bytes(COMMAND, "utf-8"), ("127.0.0.1", PORT))
print("Command [" + str(COMMAND + "] sent on port " + str(PORT)))
