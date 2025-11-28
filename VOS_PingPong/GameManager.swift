//
//  GameManager.swift
//  VOS_PingPong
//
//  Manages game state, scoring, and game lifecycle
//

import Foundation
import Observation

/// Manages the game state, scoring, and lifecycle for the ping pong game
@MainActor
@Observable
class GameManager {
    // MARK: - Game State Properties
    
    /// Current state of the game
    var gameState: GameState = .idle
    
    /// Current score accumulated during gameplay
    var score: Int = 0
    
    /// Number of consecutive hits without the ball touching the ground
    var consecutiveHits: Int = 0
    
    /// Whether the game is currently active (playing state)
    var isGameActive: Bool {
        gameState == .playing
    }
    
    // MARK: - Game Configuration
    
    /// Configuration for game constants
    private let configuration: GameConfiguration
    
    // MARK: - Initialization
    
    /// Creates a new GameManager with the specified configuration
    /// - Parameter configuration: Game configuration (defaults to standard configuration)
    init(configuration: GameConfiguration = GameConfiguration()) {
        self.configuration = configuration
    }
    
    // MARK: - Game Lifecycle Methods
    
    /// Starts a new game session
    /// Transitions from idle or gameOver state to playing state
    func startGame() {
        gameState = .playing
    }
    
    /// Ends the current game session
    /// Transitions to gameOver state
    func endGame() {
        gameState = .gameOver
    }
    
    /// Resets the game to initial state
    /// Resets score, consecutive hits, and returns to idle state
    func resetGame() {
        score = 0
        consecutiveHits = 0
        gameState = .idle
    }
    
    // MARK: - Game Event Handlers
    
    /// Records a successful hit between racket and ball
    /// Increments consecutive hit counter and updates score
    func recordHit() {
        guard isGameActive else { return }
        
        consecutiveHits += 1
        score = consecutiveHits
    }
    
    /// Handles collision between ball and ground
    /// Ends the game and resets consecutive hit counter
    func handleGroundCollision() {
        guard isGameActive else { return }
        
        consecutiveHits = 0
        endGame()
    }
}
