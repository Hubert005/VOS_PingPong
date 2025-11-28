//
//  GameState.swift
//  VOS_PingPong
//
//  Enum representing the current state of the game
//

import Foundation

/// Represents the current state of the ping pong game
enum GameState {
    /// Game has not started yet
    case idle
    
    /// Game is actively being played
    case playing
    
    /// Game has ended (ball hit ground)
    case gameOver
}
