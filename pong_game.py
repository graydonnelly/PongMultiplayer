class Game:

    def __init__(self):

        self.in_game = False
        self.p1_conn, self.p2_conn = (None, None)
        self.p1_pos, self.p2_pos = (0,0)


    def handler(self, msg, conn):

        data = {"in_game":None, "enemy_paddle_position":None, "ball_initial_velocity":None}

        if not self.p1_conn:
            self.p1_conn = conn

        if not self.p2_conn:
            if conn != self.p1_conn:
                self.p2_conn = conn

        if msg == "ready":
            if self.p1_conn and self.p2_conn:
                self.in_game = True
                return "game starting"
            else:
                return "not ready"
        
        if self.in_game == True:

            if conn == self.p1_conn:
                self.p1_pos = float(msg)
                return str(self.p2_pos)
            
            if conn == self.p2_conn:
                self.p2_pos = float(msg)
                return str(self.p1_pos)



