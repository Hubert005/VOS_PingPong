//
//  IntegrationTests.swift
//  VOS_PingPongTests
//
//  Integration tests for complete game flow
//

import Foundation
import Testing
import RealityKit
@testable import VOS_PingPong

@Suite("Integration Tests - Complete Game Flow")
@MainActor
struct IntegrationTests {
    
    // MARK: - Test 1: Complete game session from start to game over
    
    @Test("Complete game session from start to game over")
    func testCompleteGameSession() async throws {
        // Create game components
        let config = GameConfiguration()
        let gameManager = GameManager(configuration: config)
        let audioManager = AudioManager()
        
        // Verify initial state
        #expect(gameManager.gameState == .idle, "Game should start in idle state")
        #expect(gameManager.score == 0, "Initial score should be 0")
        #expect(gameManager.consecutiveHits == 0, "Initial consecutive hits should be 0")
        
        // Start the game
        gameManager.startGame()
        #expect(gameManager.gameState == .playing, "Game should be in playing state after start")
        #expect(gameManager.isGameActive == true, "Game should be active")
        
        // Simulate gameplay: record several hits
        let numberOfHits = 10
        for i in 1...numberOfHits {
            gameManager.recordHit()
            
            // Verify state after each hit
            #expect(gameManager.consecutiveHits == i, "Consecutive hits should be \(i)")
            #expect(gameManager.score == i, "Score should be \(i)")
            #expect(gameManager.gameState == .playing, "Game should remain in playing state")
        }
        
        // Simulate ball hitting ground (game over)
        let finalScore = gameManager.score
        gameManager.handleGroundCollision()
        
        // Verify game over state
        #expect(gameManager.gameState == .gameOver, "Game should be in gameOver state")
        #expect(gameManager.isGameActive == false, "Game should not be active")
        #expect(gameManager.consecutiveHits == 0, "Consecutive hits should be reset to 0")
        #expect(gameManager.score == finalScore, "Score should be preserved")
    }
    
    // MARK: - Test 2: Multiple consecutive games
    
    @Test("Multiple consecutive games")
    func testMultipleConsecutiveGames() async throws {
        let gameManager = GameManager()
        let numberOfGames = 5
        
        for gameNumber in 1...numberOfGames {
            // Start game
            gameManager.startGame()
            #expect(gameManager.gameState == .playing, "Game \(gameNumber) should start in playing state")
            
            // Play game with random number of hits
            let hitsInThisGame = Int.random(in: 5...20)
            for _ in 1...hitsInThisGame {
                gameManager.recordHit()
            }
            
            #expect(gameManager.consecutiveHits == hitsInThisGame, "Game \(gameNumber) should have \(hitsInThisGame) hits")
            
            // End game
            gameManager.handleGroundCollision()
            #expect(gameManager.gameState == .gameOver, "Game \(gameNumber) should end in gameOver state")
            
            // Reset for next game
            gameManager.resetGame()
            #expect(gameManager.gameState == .idle, "Game \(gameNumber) should reset to idle state")
            #expect(gameManager.score == 0, "Score should be reset to 0 after game \(gameNumber)")
            #expect(gameManager.consecutiveHits == 0, "Consecutive hits should be reset to 0 after game \(gameNumber)")
        }
    }
    
    // MARK: - Test 3: Pause and resume functionality
    
    @Test("Pause and resume functionality")
    func testPauseAndResume() async throws {
        let gameManager = GameManager()
        
        // Start game
        gameManager.startGame()
        #expect(gameManager.gameState == .playing, "Game should be playing")
        
        // Record some hits
        gameManager.recordHit()
        gameManager.recordHit()
        gameManager.recordHit()
        let hitsBeforePause = gameManager.consecutiveHits
        let scoreBeforePause = gameManager.score
        
        #expect(hitsBeforePause == 3, "Should have 3 hits before pause")
        
        // Pause the game
        gameManager.pauseGame()
        #expect(gameManager.gameState == .paused, "Game should be paused")
        #expect(gameManager.isGameActive == false, "Game should not be active when paused")
        
        // Try to record hits while paused (should not work)
        gameManager.recordHit()
        gameManager.recordHit()
        #expect(gameManager.consecutiveHits == hitsBeforePause, "Hits should not be recorded while paused")
        #expect(gameManager.score == scoreBeforePause, "Score should not change while paused")
        
        // Resume the game
        gameManager.resumeGame()
        #expect(gameManager.gameState == .playing, "Game should be playing after resume")
        #expect(gameManager.isGameActive == true, "Game should be active after resume")
        
        // Record more hits after resume
        gameManager.recordHit()
        gameManager.recordHit()
        #expect(gameManager.consecutiveHits == hitsBeforePause + 2, "Hits should continue from where they left off")
        #expect(gameManager.score == scoreBeforePause + 2, "Score should continue from where it left off")
    }
    
    // MARK: - Test 4: Hand tracking integration with pause/resume
    
    @Test("Hand tracking loss triggers pause and restoration triggers resume")
    func testHandTrackingPauseResume() async throws {
        let gameManager = GameManager()
        let handTrackingManager = HandTrackingManager(gameManager: gameManager)
        
        // Start game
        gameManager.startGame()
        #expect(gameManager.gameState == .playing, "Game should be playing")
        
        // Simulate hand tracking active
        handTrackingManager.isTrackingActive = true
        
        // Record some hits
        gameManager.recordHit()
        gameManager.recordHit()
        let hitsBeforeTrackingLoss = gameManager.consecutiveHits
        
        // Simulate tracking loss
        handTrackingManager.isTrackingActive = false
        handTrackingManager.trackingLost = true
        gameManager.pauseGame()
        
        #expect(gameManager.gameState == .paused, "Game should pause when tracking is lost")
        #expect(handTrackingManager.trackingLost == true, "Tracking lost flag should be set")
        
        // Try to record hits while tracking is lost (should not work)
        gameManager.recordHit()
        #expect(gameManager.consecutiveHits == hitsBeforeTrackingLoss, "Hits should not be recorded when tracking is lost")
        
        // Simulate tracking restoration
        handTrackingManager.isTrackingActive = true
        handTrackingManager.trackingLost = false
        gameManager.resumeGame()
        
        #expect(gameManager.gameState == .playing, "Game should resume when tracking is restored")
        
        // Record hits after restoration
        gameManager.recordHit()
        #expect(gameManager.consecutiveHits == hitsBeforeTrackingLoss + 1, "Hits should continue after tracking restoration")
    }
    
    // MARK: - Test 5: Ball boundary enforcement
    
    @Test("Ball boundary enforcement")
    func testBallBoundaryEnforcement() async throws {
        let config = GameConfiguration()
        let ball = BallEntity.create(with: config)
        
        // Verify ball starts in bounds
        #expect(ball.isOutOfBounds() == false, "Ball should start in bounds")
        
        // Move ball out of bounds in X direction
        ball.position = SIMD3<Float>(100, 1, 0)
        #expect(ball.isOutOfBounds() == true, "Ball should be out of bounds")
        
        // Reposition ball
        let wasRepositioned = ball.repositionIfOutOfBounds()
        #expect(wasRepositioned == true, "Ball should be repositioned")
        #expect(ball.isOutOfBounds() == false, "Ball should be back in bounds")
        #expect(ball.position == config.ballStartPosition, "Ball should be at start position")
        
        // Move ball out of bounds in Y direction (below ground)
        ball.position = SIMD3<Float>(0, -5, 0)
        #expect(ball.isOutOfBounds() == true, "Ball should be out of bounds below ground")
        
        ball.repositionIfOutOfBounds()
        #expect(ball.isOutOfBounds() == false, "Ball should be back in bounds")
        
        // Move ball out of bounds in Z direction
        ball.position = SIMD3<Float>(0, 1, -100)
        #expect(ball.isOutOfBounds() == true, "Ball should be out of bounds")
        
        ball.repositionIfOutOfBounds()
        #expect(ball.isOutOfBounds() == false, "Ball should be back in bounds")
    }
    
    // MARK: - Test 6: Ball velocity clamping
    
    @Test("Ball velocity clamping prevents unrealistic speeds")
    func testBallVelocityClamping() async throws {
        let config = GameConfiguration()
        let ball = BallEntity.create(with: config)
        
        // Add physics motion component
        var physicsMotion = PhysicsMotionComponent()
        
        // Set velocity below max (should not be clamped)
        let normalVelocity = SIMD3<Float>(5, 5, 5)
        physicsMotion.linearVelocity = normalVelocity
        ball.components[PhysicsMotionComponent.self] = physicsMotion
        
        ball.clampVelocity(max: config.maxBallVelocity)
        
        if let motion = ball.components[PhysicsMotionComponent.self] {
            let speed = length(motion.linearVelocity)
            #expect(speed <= config.maxBallVelocity, "Velocity should be within max limit")
        }
        
        // Set velocity above max (should be clamped)
        let excessiveVelocity = SIMD3<Float>(20, 20, 20)
        physicsMotion.linearVelocity = excessiveVelocity
        ball.components[PhysicsMotionComponent.self] = physicsMotion
        
        ball.clampVelocity(max: config.maxBallVelocity)
        
        if let motion = ball.components[PhysicsMotionComponent.self] {
            let speed = length(motion.linearVelocity)
            #expect(speed <= config.maxBallVelocity, "Excessive velocity should be clamped to max")
            
            // Verify direction is preserved
            let originalDirection = normalize(excessiveVelocity)
            let clampedDirection = normalize(motion.linearVelocity)
            let directionDifference = length(originalDirection - clampedDirection)
            #expect(directionDifference < 0.01, "Direction should be preserved when clamping")
        }
    }
    
    // MARK: - Test 7: Complete collision flow
    
    @Test("Complete collision flow with all surfaces")
    func testCompleteCollisionFlow() async throws {
        let config = GameConfiguration()
        let gameManager = GameManager(configuration: config)
        let audioManager = AudioManager()
        let collisionHandler = CollisionHandler(
            configuration: config,
            gameManager: gameManager,
            audioManager: audioManager
        )
        
        // Start game
        gameManager.startGame()
        
        // Create entities
        let ball = BallEntity.create(with: config)
        let racket = RacketEntity.create()
        
        // Add physics motion to ball
        var ballMotion = PhysicsMotionComponent()
        ballMotion.linearVelocity = SIMD3<Float>(0, -5, 0)
        ball.components[PhysicsMotionComponent.self] = ballMotion
        
        // Test racket collision
        let initialHits = gameManager.consecutiveHits
        collisionHandler.handleBallRacketCollision(ball: ball, racket: racket)
        #expect(gameManager.consecutiveHits == initialHits + 1, "Hit should be recorded after racket collision")
        
        // Verify ball velocity changed after racket hit
        if let motion = ball.components[PhysicsMotionComponent.self] {
            let speed = length(motion.linearVelocity)
            #expect(speed > 0, "Ball should have velocity after racket hit")
        }
        
        // Test table collision (reflection)
        ballMotion.linearVelocity = SIMD3<Float>(0, -5, 0)
        ball.components[PhysicsMotionComponent.self] = ballMotion
        
        let table = Entity()
        table.name = CollisionType.table.rawValue
        
        collisionHandler.handleBallTableCollision(ball: ball, table: table)
        
        if let motion = ball.components[PhysicsMotionComponent.self] {
            // Y velocity should be reflected (positive after bouncing off table)
            #expect(motion.linearVelocity.y > 0, "Ball should bounce upward after table collision")
        }
        
        // Test wall collision (reflection)
        ballMotion.linearVelocity = SIMD3<Float>(0, 0, -5)
        ball.components[PhysicsMotionComponent.self] = ballMotion
        
        let wall = Entity()
        wall.name = CollisionType.wall.rawValue
        
        collisionHandler.handleBallWallCollision(ball: ball, wall: wall)
        
        if let motion = ball.components[PhysicsMotionComponent.self] {
            // Z velocity should be reflected (positive after bouncing off wall)
            #expect(motion.linearVelocity.z > 0, "Ball should bounce back after wall collision")
        }
        
        // Test ground collision (game over)
        let ground = Entity()
        ground.name = CollisionType.ground.rawValue
        
        collisionHandler.handleBallGroundCollision(ball: ball, ground: ground)
        
        #expect(gameManager.gameState == .gameOver, "Game should end after ground collision")
        #expect(gameManager.consecutiveHits == 0, "Consecutive hits should reset after ground collision")
        
        if let motion = ball.components[PhysicsMotionComponent.self] {
            #expect(motion.linearVelocity == .zero, "Ball should stop after ground collision")
        }
    }
    
    // MARK: - Test 8: Edge case - rapid state transitions
    
    @Test("Edge case: rapid state transitions")
    func testRapidStateTransitions() async throws {
        let gameManager = GameManager()
        
        // Rapid start/pause/resume/end cycles
        for _ in 1...10 {
            gameManager.startGame()
            #expect(gameManager.gameState == .playing, "Should be playing")
            
            gameManager.pauseGame()
            #expect(gameManager.gameState == .paused, "Should be paused")
            
            gameManager.resumeGame()
            #expect(gameManager.gameState == .playing, "Should be playing again")
            
            gameManager.endGame()
            #expect(gameManager.gameState == .gameOver, "Should be game over")
            
            gameManager.resetGame()
            #expect(gameManager.gameState == .idle, "Should be idle")
        }
    }
    
    // MARK: - Test 9: Edge case - operations in wrong state
    
    @Test("Edge case: operations in wrong state")
    func testOperationsInWrongState() async throws {
        let gameManager = GameManager()
        
        // Try to pause when not playing
        gameManager.pauseGame()
        #expect(gameManager.gameState == .idle, "Should remain idle when pausing from idle")
        
        // Try to resume when not paused
        gameManager.resumeGame()
        #expect(gameManager.gameState == .idle, "Should remain idle when resuming from idle")
        
        // Try to record hits when not playing
        gameManager.recordHit()
        #expect(gameManager.consecutiveHits == 0, "Should not record hits when not playing")
        
        // Try to handle ground collision when not playing
        gameManager.handleGroundCollision()
        #expect(gameManager.gameState == .idle, "Should remain idle when handling collision from idle")
        
        // Start game, end it, then try operations
        gameManager.startGame()
        gameManager.endGame()
        
        gameManager.recordHit()
        #expect(gameManager.consecutiveHits == 0, "Should not record hits when game is over")
        
        gameManager.pauseGame()
        #expect(gameManager.gameState == .gameOver, "Should remain gameOver when pausing from gameOver")
    }
    
    // MARK: - Test 10: Edge case - ball reset behavior
    
    @Test("Edge case: ball reset behavior")
    func testBallResetBehavior() async throws {
        let config = GameConfiguration()
        let ball = BallEntity.create(with: config)
        
        // Add velocity to ball
        var physicsMotion = PhysicsMotionComponent()
        physicsMotion.linearVelocity = SIMD3<Float>(10, 10, 10)
        physicsMotion.angularVelocity = SIMD3<Float>(5, 5, 5)
        ball.components[PhysicsMotionComponent.self] = physicsMotion
        
        // Move ball to random position
        ball.position = SIMD3<Float>(5, 5, 5)
        
        // Reset ball
        let resetPosition = SIMD3<Float>(0, 2, 0)
        ball.reset(to: resetPosition)
        
        // Verify position reset
        #expect(ball.position == resetPosition, "Ball position should be reset")
        
        // Verify velocities are zeroed
        if let motion = ball.components[PhysicsMotionComponent.self] {
            #expect(motion.linearVelocity == .zero, "Linear velocity should be zero after reset")
            #expect(motion.angularVelocity == .zero, "Angular velocity should be zero after reset")
        }
    }
    
    // MARK: - Test 11: Integration - full game with boundary checks
    
    @Test("Integration: full game with boundary checks")
    func testFullGameWithBoundaryChecks() async throws {
        let config = GameConfiguration()
        let gameManager = GameManager(configuration: config)
        let ball = BallEntity.create(with: config)
        
        // Start game
        gameManager.startGame()
        
        // Play several rounds with boundary checks
        for round in 1...5 {
            // Record some hits
            for _ in 1...3 {
                gameManager.recordHit()
            }
            
            // Simulate ball going out of bounds
            ball.position = SIMD3<Float>(100, 100, 100)
            #expect(ball.isOutOfBounds() == true, "Ball should be out of bounds in round \(round)")
            
            // Reposition ball
            ball.repositionIfOutOfBounds()
            #expect(ball.isOutOfBounds() == false, "Ball should be back in bounds in round \(round)")
            
            // Continue playing
            gameManager.recordHit()
        }
        
        // End game
        gameManager.handleGroundCollision()
        #expect(gameManager.gameState == .gameOver, "Game should be over")
        #expect(gameManager.score > 0, "Score should be greater than 0")
    }
    
    // MARK: - Test 12: Stress test - many hits in one game
    
    @Test("Stress test: many hits in one game")
    func testManyHitsInOneGame() async throws {
        let gameManager = GameManager()
        
        gameManager.startGame()
        
        let manyHits = 1000
        for i in 1...manyHits {
            gameManager.recordHit()
            
            // Verify state consistency
            #expect(gameManager.consecutiveHits == i, "Consecutive hits should be \(i)")
            #expect(gameManager.score == i, "Score should be \(i)")
            #expect(gameManager.gameState == .playing, "Game should remain playing")
        }
        
        // End game
        gameManager.handleGroundCollision()
        #expect(gameManager.gameState == .gameOver, "Game should end")
        #expect(gameManager.consecutiveHits == 0, "Consecutive hits should reset")
        #expect(gameManager.score == manyHits, "Score should be preserved")
    }
}
