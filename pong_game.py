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
        self.ball_velocities = [random.randint(5,35),random.randint(5,35),random.randint(5,35),random.randint(5,35),random.randint(5,35),random.randint(5,35),random.randint(5,35),random.randint(5,35),random.randint(5,35)]

        self.ball_position_x = None
        self.ball_position_y = None
        self.ball_velocity_x = None
        self.ball_velocity_y = None
        self.needs_to_update_ball = None


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
        
        if self.in_game:

            if msg["paddle_position"]:
                if conn == self.p1_conn:
                    self.p1_pos = float(msg["paddle_position"])
                    data["enemy_paddle_position"] = self.p2_pos
                
                if conn == self.p2_conn:
                    self.p2_pos = float(msg["paddle_position"])
                    data["enemy_paddle_position"] = self.p1_pos

            if self.needs_to_update_ball:
                if (conn == self.p1_conn and self.needs_to_update_ball == "p1") or (conn == self.p2_conn and self.needs_to_update_ball == "p2"):
                    print("BALL UPDATING")
                    data["ball_position_x"] = self.ball_position_x
                    data["ball_position_y"] = self.ball_position_y
                    data["ball_velocity_x"] = self.ball_velocity_x
                    data["ball_velocity_y"] = self.ball_velocity_y
                    data["should_update_ball"] = True
                    self.needs_to_update_ball = None

            if msg["should_update_ball"]:
                print("ball to update")
                self.ball_position_x = msg["ball_position_x"]
                self.ball_position_y = msg["ball_position_y"]
                self.ball_velocity_x = msg["ball_velocity_x"]
                self.ball_velocity_y = msg["ball_velocity_y"]
                if conn == self.p1_conn:
                    self.needs_to_update_ball = "p2"
                if conn == self.p2_conn:
                    self.needs_to_update_ball = "p1"

            



       
        return data



