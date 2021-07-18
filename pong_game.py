import json
import ast
import random

class Game:

    def __init__(self):

        self.in_game = False
        self.p1_conn, self.p2_conn = (None, None)
        self.p1_pos, self.p2_pos = (0,0)
        self.ball_velocities = [random.randint(5,35),random.randint(5,35),random.randint(5,35),random.randint(5,35),random.randint(5,35),random.randint(5,35),random.randint(5,35),random.randint(5,35),random.randint(5,35)]

   

    def handler(self, msg, conn):

        data_to_send = {"in_game":None, "enemy_paddle_position":None, "ball_initial_velocity":self.ball_velocities}

        if len(msg) == 0:
            print("CONNECTION BROKEN")
            if conn == self.p1_conn:
                self.p1_conn = None
            if conn == self.p2_conn:
                self.p2_conn = None

        else:

            msg = json.loads(msg)

            
            if not self.p1_conn:
                self.p1_conn = conn

            if not self.p2_conn:
                if conn != self.p1_conn:
                    self.p2_conn = conn

            if "looking_for_game" in msg.keys(): 
                if msg["looking_for_game"] == "true":

                    while self.in_game == False:
                        if self.p1_conn and self.p2_conn:
                            self.in_game = True
                            data_to_send["in_game"] = "true"
                            return json.dumps(data_to_send)
            
            if self.in_game == True:

                if conn == self.p1_conn:
                    self.p1_pos = float(msg["paddle_position"])
                    data_to_send["enemy_paddle_position"] = self.p2_pos
                
                if conn == self.p2_conn:
                    self.p2_pos = float(msg["paddle_position"])
                    data_to_send["enemy_paddle_position"] = self.p1_pos

        return json.dumps(data_to_send)



