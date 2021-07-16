//
//  NetworkData.swift
//  Pong
//
//  Created by Isi Donnelly on 7/16/21.
//  Copyright © 2021 Go Deep Games. All rights reserved.
//

import Foundation

struct DataToReceive:Codable{
    var in_game: Bool? = nil
    var enemy_paddle_position: Int? = nil
    var ball_initial_velocity: Int? = nil
    var error: String? = nil
}

struct DataToSend:Codable{
    var looking_for_game: Bool? = nil
    var paddle_position: Int? = nil
    var point_winner: Int? = nil
}
