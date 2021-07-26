import json
import ast
import random
from data_to_send import get_data_to_send

class Game:

    p1_conn = None
    p2_conn = None

    def __init__(self):
        self.in_game = False
        self.p1_pos, self.p2_pos = (0,0)
        self.p1_ready, self.p2_ready = (False, False)
        self.ball_velocities = [0,random.randint(5,35),random.randint(5,35),random.randint(5,35),random.randint(5,35),random.randint(5,35),random.randint(5,35),random.randint(5,35),random.randint(5,35)]


    def handler(self, msg, conn, data):

        data["initial_velocities"] = self.ball_velocities

        if msg["looking_for_game"]: 
            if conn == self.p1_conn:
                self.p1_ready = True
            if conn == self.p2_conn:
                self.p2_ready = True

            data["in_game"] = False
            if self.p1_ready and self.p2_ready:
                self.in_game = True
                data["in_game"] = True
        
        if self.in_game and msg["paddle_position"]:

            if conn == self.p1_conn:
                self.p1_pos = float(msg["paddle_position"])
                data["enemy_paddle_position"] = self.p2_pos
            
            if conn == self.p2_conn:
                self.p2_pos = float(msg["paddle_position"])
                data["enemy_paddle_position"] = self.p1_pos

       
        return data



