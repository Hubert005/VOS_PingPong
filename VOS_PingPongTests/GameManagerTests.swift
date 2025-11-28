//
//  GameManagerTests.swift
//  VOS_PingPongTests
//
//  Property-based tests for GameManager
//

import Foundation
import Testing
@testable import VOS_PingPong

@Suite("GameManager Property Tests")
@MainActor
struct GameManagerTests {
    
    // MARK: - Property 15: Game reset restores initial state
    // Feature: ar-pingpong-game, Property 15: Game reset restores initial state
    // Validates: Requirements 6.1, 6.2, 6.3, 6.4
    
    @Test("Property 15: Game reset restores initial state")
    func testGameResetRestoresInitialState() throws {
        try PropertyTestHelper.runPropertyTest(iterations: 100) {
            // Create a GameManager
            let manager = GameManager()
            
            // Generate random initial state by performing random operations
            let randomScore = PropertyGenerator.randomInt(min: 0, max: 1000)
            let randomHits = PropertyGenerator.randomInt(min: 0, max: 100)
            
            // Manually set state to simulate gameplay
            manager.score = randomScore
            manager.consecutiveHits = randomHits
            manager.gameState = PropertyGenerator.randomGameState()
            
            // Reset the game
            manager.resetGame()
            
            // Verify initial state is restored
            #expect(manager.score == 0, "Score should be reset to 0")
            #expect(manager.consecutiveHits == 0, "Consecutive hits should be reset to 0")
            #expect(manager.gameState == .idle, "Game state should be idle after reset")
            #expect(manager.isGameActive == false, "Game should not be active after reset")
        }
    }
    
    // MARK: - Property 11: Score calculation from hits
    // Feature: ar-pingpong-game, Property 11: Score calculation from hits
    // Validates: Requirements 4.2
    
    @Test("Property 11: Score calculation from hits")
    func testScoreCalculationFromHits() throws {
        try PropertyTestHelper.runPropertyTest(iterations: 100) {
            // Create a GameManager and start the game
            let manager = GameManager()
            manager.startGame()
            
            // Generate a random number of hits
            let numberOfHits = PropertyGenerator.randomInt(min: 1, max: 50)
            
            // Record the hits
            for _ in 0..<numberOfHits {
                manager.recordHit()
            }
            
            // Verify score equals consecutive hits
            #expect(manager.score == numberOfHits, "Score should equal the number of consecutive hits")
            #expect(manager.consecutiveHits == numberOfHits, "Consecutive hits should match the number of recorded hits")
        }
    }
    
    // MARK: - Property 14: Ground collision ends game
    // Feature: ar-pingpong-game, Property 14: Ground collision ends game
    // Validates: Requirements 5.2, 4.5
    
    @Test("Property 14: Ground collision ends game")
    func testGroundCollisionEndsGame() throws {
        try PropertyTestHelper.runPropertyTest(iterations: 100) {
            // Create a GameManager and start the game
            let manager = GameManager()
            manager.startGame()
            
            // Generate random game state before collision
            let randomHits = PropertyGenerator.randomInt(min: 1, max: 100)
            for _ in 0..<randomHits {
                manager.recordHit()
            }
            
            let scoreBeforeCollision = manager.score
            
            // Handle ground collision
            manager.handleGroundCollision()
            
            // Verify game ended and hit counter reset
            #expect(manager.gameState == .gameOver, "Game state should be gameOver after ground collision")
            #expect(manager.consecutiveHits == 0, "Consecutive hits should be reset to 0 after ground collision")
            #expect(manager.isGameActive == false, "Game should not be active after ground collision")
            #expect(manager.score == scoreBeforeCollision, "Score should be preserved after ground collision")
        }
    }
    
    // MARK: - Additional Edge Case Tests
    
    @Test("recordHit should not work when game is not active")
    func testRecordHitWhenNotActive() {
        let manager = GameManager()
        
        // Try to record hit when game is idle
        manager.recordHit()
        #expect(manager.consecutiveHits == 0, "Hits should not be recorded when game is idle")
        
        // Start and end game
        manager.startGame()
        manager.endGame()
        
        // Try to record hit when game is over
        manager.recordHit()
        #expect(manager.consecutiveHits == 0, "Hits should not be recorded when game is over")
    }
    
    @Test("handleGroundCollision should not work when game is not active")
    func testHandleGroundCollisionWhenNotActive() {
        let manager = GameManager()
        
        // Try to handle collision when game is idle
        manager.handleGroundCollision()
        #expect(manager.gameState == .idle, "Game state should remain idle")
        
        // Start, end, and try again
        manager.startGame()
        manager.endGame()
        manager.handleGroundCollision()
        #expect(manager.gameState == .gameOver, "Game state should remain gameOver")
    }
    
    @Test("startGame transitions to playing state")
    func testStartGameTransition() {
        let manager = GameManager()
        
        #expect(manager.gameState == .idle, "Initial state should be idle")
        
        manager.startGame()
        #expect(manager.gameState == .playing, "State should be playing after startGame")
        #expect(manager.isGameActive == true, "Game should be active after startGame")
    }
}
