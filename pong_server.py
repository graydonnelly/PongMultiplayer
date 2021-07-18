import socket
import threading
from pong_game import Game

'''
This function gets your local IP address which helps with the constants.
'''
def get_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        # doesn't even have to be reachable
        s.connect(('10.255.255.255', 1))
        IP = s.getsockname()[0]
    except Exception:
        IP = '127.0.0.1'
    finally:
        s.close()
    return IP

HEADER = 64
HOST = get_ip()
PORT = 5051
ADDRESS = (HOST, PORT)
FORMAT = "utf-8"
DISCONNECT_MSG = "!DISCONNECT"
GAME = Game()

server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.bind(ADDRESS)

def handle_client(conn, addr):
    
    print(f"[NEW CONNECTION] {addr} connected.")
    connected = True

    while connected:

        msg = conn.recv(HEADER).decode(FORMAT)

        if msg == DISCONNECT_MSG:
            connected = False
                
        print(f"{addr} said {msg}")
        conn.send(GAME.handler(msg,conn).encode(FORMAT))

    conn.close()


def start():

    server.listen(2)
    print(f"[LISTENING] Server is listening on {HOST}")
    
    while True:
        conn, addr = server.accept()
        thread = threading.Thread(target=handle_client, args=(conn,addr))
        thread.start()
        print(f"[ACTIVE CONNECTIONS] {threading.active_count() - 1}")


print("[STARTING] server is starting...")
start()