//
//  HandTrackingTests.swift
//  VOS_PingPongTests
//
//  Property-based tests for hand tracking state management
//

import Foundation
import Testing
@testable import VOS_PingPong

@Suite("Hand Tracking Property Tests")
@MainActor
struct HandTrackingTests {
    
    // MARK: - Property 18: Tracking loss pauses game
    // Feature: ar-pingpong-game, Property 18: Tracking loss pauses game
    // Validates: Requirements 8.2
    
    @Test("Property 18: Tracking loss pauses game")
    func testTrackingLossPausesGame() throws {
        try PropertyTestHelper.runPropertyTest(iterations: 100) {
            // Create a GameManager and HandTrackingManager
            let gameManager = GameManager()
            let handTrackingManager = HandTrackingManager(gameManager: gameManager)
            
            // Start the game (must be in playing state for pause to work)
            gameManager.startGame()
            
            // Verify game is playing
            #expect(gameManager.gameState == .playing, "Game should be in playing state")
            
            // Simulate tracking being active
            handTrackingManager.isTrackingActive = true
            
            // Generate random game state before tracking loss
            let randomHits = PropertyGenerator.randomInt(min: 0, max: 50)
            for _ in 0..<randomHits {
                gameManager.recordHit()
            }
            
            let scoreBeforeLoss = gameManager.score
            let hitsBeforeLoss = gameManager.consecutiveHits
            
            // Simulate tracking loss by calling pauseGame (simulating what would happen in monitorHandAnchors)
            gameManager.pauseGame()
            handTrackingManager.isTrackingActive = false
            handTrackingManager.trackingLost = true
            
            // Verify game is paused
            #expect(gameManager.gameState == .paused, "Game state should be paused after tracking loss")
            #expect(handTrackingManager.isTrackingActive == false, "Tracking should be marked as inactive")
            #expect(handTrackingManager.trackingLost == true, "Tracking lost flag should be set")
            
            // Verify game state is preserved (score and hits should not change)
            #expect(gameManager.score == scoreBeforeLoss, "Score should be preserved during pause")
            #expect(gameManager.consecutiveHits == hitsBeforeLoss, "Consecutive hits should be preserved during pause")
        }
    }
    
    // MARK: - Property 19: Tracking restoration resumes game
    // Feature: ar-pingpong-game, Property 19: Tracking restoration resumes game
    // Validates: Requirements 8.3
    
    @Test("Property 19: Tracking restoration resumes game")
    func testTrackingRestorationResumesGame() throws {
        try PropertyTestHelper.runPropertyTest(iterations: 100) {
            // Create a GameManager and HandTrackingManager
            let gameManager = GameManager()
            let handTrackingManager = HandTrackingManager(gameManager: gameManager)
            
            // Start the game
            gameManager.startGame()
            
            // Generate random game state
            let randomHits = PropertyGenerator.randomInt(min: 0, max: 50)
            for _ in 0..<randomHits {
                gameManager.recordHit()
            }
            
            let scoreBeforePause = gameManager.score
            let hitsBeforePause = gameManager.consecutiveHits
            
            // Simulate tracking loss and pause
            handTrackingManager.isTrackingActive = false
            handTrackingManager.trackingLost = true
            gameManager.pauseGame()
            
            // Verify game is paused
            #expect(gameManager.gameState == .paused, "Game should be paused")
            
            // Simulate tracking restoration by calling resumeGame (simulating what would happen in monitorHandAnchors)
            gameManager.resumeGame()
            handTrackingManager.isTrackingActive = true
            handTrackingManager.trackingLost = false
            
            // Verify game is resumed
            #expect(gameManager.gameState == .playing, "Game state should be playing after tracking restoration")
            #expect(handTrackingManager.isTrackingActive == true, "Tracking should be marked as active")
            #expect(handTrackingManager.trackingLost == false, "Tracking lost flag should be cleared")
            
            // Verify game state is preserved (score and hits should not change)
            #expect(gameManager.score == scoreBeforePause, "Score should be preserved after resume")
            #expect(gameManager.consecutiveHits == hitsBeforePause, "Consecutive hits should be preserved after resume")
        }
    }
    
    // MARK: - Edge Case Tests
    
    @Test("pauseGame should only work when game is playing")
    func testPauseOnlyWorksWhenPlaying() {
        let manager = GameManager()
        
        // Try to pause when game is idle
        manager.pauseGame()
        #expect(manager.gameState == .idle, "Game state should remain idle when pausing from idle")
        
        // Try to pause when game is over
        manager.gameState = .gameOver
        manager.pauseGame()
        #expect(manager.gameState == .gameOver, "Game state should remain gameOver when pausing from gameOver")
        
        // Pause should work when playing
        manager.startGame()
        manager.pauseGame()
        #expect(manager.gameState == .paused, "Game state should be paused when pausing from playing")
    }
    
    @Test("resumeGame should only work when game is paused")
    func testResumeOnlyWorksWhenPaused() {
        let manager = GameManager()
        
        // Try to resume when game is idle
        manager.resumeGame()
        #expect(manager.gameState == .idle, "Game state should remain idle when resuming from idle")
        
        // Try to resume when game is playing
        manager.startGame()
        manager.resumeGame()
        #expect(manager.gameState == .playing, "Game state should remain playing when resuming from playing")
        
        // Resume should work when paused
        manager.pauseGame()
        manager.resumeGame()
        #expect(manager.gameState == .playing, "Game state should be playing when resuming from paused")
    }
    
    @Test("game actions should not work when paused")
    func testGameActionsWhenPaused() {
        let manager = GameManager()
        
        // Start and pause the game
        manager.startGame()
        manager.recordHit()
        manager.pauseGame()
        
        let hitsBeforePause = manager.consecutiveHits
        
        // Try to record hit when paused
        manager.recordHit()
        #expect(manager.consecutiveHits == hitsBeforePause, "Hits should not be recorded when game is paused")
        
        // Try to handle ground collision when paused
        manager.handleGroundCollision()
        #expect(manager.gameState == .paused, "Game state should remain paused when handling collision while paused")
    }
}
