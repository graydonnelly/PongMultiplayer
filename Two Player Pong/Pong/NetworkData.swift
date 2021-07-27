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
    var enemy_paddle_position: Float? = nil
    var initial_velocities: [Int]? = nil
    var starting: Bool? = nil
    var ball_position_x: Float? = nil
    var ball_position_y: Float? = nil
    var ball_velocity_x: Float? = nil
    var ball_velocity_y: Float? = nil
    var should_update_ball: Bool? = nil
    var error: String? = nil
}

struct DataToSend:Codable{
    var looking_for_game: Bool? = nil
    var paddle_position: Float? = nil
    var point_winner: Int? = nil
    var disconnecting: Bool? = nil
    
    var ball_position_x: Float? = nil
    var ball_position_y: Float? = nil
    var ball_velocity_x: Float? = nil
    var ball_velocity_y: Float? = nil
    var should_update_ball: Bool? = nil
    
    func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(looking_for_game, forKey: .looking_for_game)
            try container.encode(paddle_position, forKey: .paddle_position)
            try container.encode(point_winner, forKey: .point_winner)
            try container.encode(disconnecting, forKey: .disconnecting)
            try container.encode(ball_position_x, forKey: .ball_position_x)
            try container.encode(ball_position_y, forKey: .ball_position_y)
            try container.encode(ball_velocity_x, forKey: .ball_velocity_x)
            try container.encode(ball_velocity_y, forKey: .ball_velocity_y)
            try container.encode(should_update_ball, forKey: .should_update_ball)
        }
}
