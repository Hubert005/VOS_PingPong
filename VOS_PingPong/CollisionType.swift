//
//  CollisionType.swift
//  VOS_PingPong
//
//  Enum for identifying different collision types in the game
//

import Foundation

/// Identifies the type of entity involved in a collision
enum CollisionType: String {
    /// The ping pong ball
    case ball = "ball"
    
    /// The player's racket
    case racket = "racket"
    
    /// The table surface
    case table = "table"
    
    /// The wall at the end of the table
    case wall = "wall"
    
    /// The ground/floor
    case ground = "ground"
}
