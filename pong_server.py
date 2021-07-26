import socket
import threading
from pong_game import Game
import json
from data_to_send import get_data_to_send

#This function gets your local IP address which helps with the constants.
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

#Define Constants
HEADER = 1024
HOST = get_ip()
PORT = 5051
ADDRESS = (HOST, PORT)
FORMAT = "utf-8"

#variables for games
active_games = []
game_needing_player = []

#setup the server
server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.bind(ADDRESS)

#when a client disconnects
def disconnect(conn, addr):
    print(f"[DISCONNECTING] {addr} disconnected.")
    data = get_data_to_send()
    data["disconnect_message"] = "Thanks for playing"
    conn.send(json.dumps(data).encode(FORMAT))

#handle incoming connections
def handle_client(conn, addr):
    
    print(f"[NEW CONNECTION] {addr} connected.")
    connected = True
    data = get_data_to_send()

    if len(game_needing_player) == 1:
        game_needing_player[0].p2_conn = conn
        active_games.append(game_needing_player[0])
        game = game_needing_player[0]
        del game_needing_player[0]
        data["starting"] = True
        print(f"[GAME STARTING]")

    else:
        game = Game()
        game.p1_conn = conn
        game_needing_player.append(game)
        data["starting"] = False

    while connected:

        if not data:
            data = get_data_to_send()

        msg = conn.recv(HEADER).decode(FORMAT)
        #print(f"[NEW MESSAGE] {addr} said: {msg}")

        if len(msg) == 0:
            connected = False
            disconnect(conn,addr)

        else:
            msg = json.loads(msg)

            if msg["disconnecting"]:
                connected = False
                disconnect(conn,addr)

            conn.send(json.dumps(game.handler(msg,conn,data)).encode(FORMAT))

    conn.close()


#start the server and listen
def start():

    server.listen(2)
    print(f"[LISTENING] Server is listening on {HOST}")

    while True:
        conn, addr = server.accept()
        thread = threading.Thread(target=handle_client, args=(conn,addr))
        thread.start()
        print(f"[ACTIVE CONNECTIONS] {threading.active_count() - 1}")


#calls the start function
print("[STARTING] server is starting...")
start()