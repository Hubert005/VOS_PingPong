//
//  AudioTests.swift
//  VOS_PingPongTests
//
//  Property-based tests for audio events
//

import Foundation
import Testing
import RealityKit
@testable import VOS_PingPong

@Suite("Audio Property Tests")
@MainActor
struct AudioTests {
    
    // MARK: - Property 16: Collision audio events
    // Feature: ar-pingpong-game, Property 16: Collision audio events
    // Validates: Requirements 7.1
    
    @Test("Property 16: Collision audio events")
    func testCollisionAudioEvents() throws {
        try PropertyTestHelper.runPropertyTest(iterations: 100) {
            // Create game configuration and components
            let config = GameConfiguration()
            let gameManager = GameManager(configuration: config)
            let audioManager = TestableAudioManager()
            let collisionHandler = CollisionHandler(
                configuration: config,
                gameManager: gameManager,
                audioManager: audioManager
            )
            
            // Create entities
            let ball = BallEntity.create(with: config)
            let table = TableEntity.create(with: config)
            let wall = WallEntity.create(with: config)
            let racket = RacketEntity.create()
            let ground = GroundEntity.create(with: config)
            
            // Set random ball velocity
            let velocityX = PropertyGenerator.randomFloat(min: -5.0, max: 5.0)
            let velocityY = PropertyGenerator.randomFloat(min: -5.0, max: 5.0)
            let velocityZ = PropertyGenerator.randomFloat(min: -5.0, max: 5.0)
            let velocity = SIMD3<Float>(velocityX, velocityY, velocityZ)
            
            guard var physicsMotion = ball.components[PhysicsMotionComponent.self] else {
                Issue.record("Ball should have PhysicsMotionComponent")
                return
            }
            
            physicsMotion.linearVelocity = velocity
            ball.components[PhysicsMotionComponent.self] = physicsMotion
            
            // Test 1: Table collision should trigger table bounce sound
            audioManager.reset()
            collisionHandler.handleBallTableCollision(ball: ball, table: table)
            
            #expect(
                audioManager.tableBounceCount > 0,
                "Table collision should trigger table bounce sound"
            )
            
            #expect(
                audioManager.lastTableBouncePosition != nil,
                "Table bounce sound should have a position"
            )
            
            // Test 2: Wall collision should trigger wall bounce sound
            audioManager.reset()
            collisionHandler.handleBallWallCollision(ball: ball, wall: wall)
            
            #expect(
                audioManager.wallBounceCount > 0,
                "Wall collision should trigger wall bounce sound"
            )
            
            #expect(
                audioManager.lastWallBouncePosition != nil,
                "Wall bounce sound should have a position"
            )
            
            // Test 3: Racket collision should trigger ball hit sound
            audioManager.reset()
            gameManager.startGame() // Ensure game is active for hit recording
            collisionHandler.handleBallRacketCollision(ball: ball, racket: racket)
            
            #expect(
                audioManager.ballHitCount > 0,
                "Racket collision should trigger ball hit sound"
            )
            
            #expect(
                audioManager.lastBallHitPosition != nil,
                "Ball hit sound should have a position"
            )
            
            // Test 4: Ground collision should trigger game over sound
            audioManager.reset()
            gameManager.startGame() // Ensure game is active
            collisionHandler.handleBallGroundCollision(ball: ball, ground: ground)
            
            #expect(
                audioManager.gameOverCount > 0,
                "Ground collision should trigger game over sound"
            )
            
            // Test 5: Verify audio is triggered at collision position
            // For spatial audio, the position should match the ball's position
            audioManager.reset()
            let ballPosition = ball.position
            collisionHandler.handleBallTableCollision(ball: ball, table: table)
            
            if let audioPosition = audioManager.lastTableBouncePosition {
                let tolerance: Float = 0.01
                let distance = length(audioPosition - ballPosition)
                
                #expect(
                    distance < tolerance,
                    "Audio should be played at the collision position"
                )
            }
        }
    }
}

// MARK: - Testable Audio Manager

/// A testable version of AudioManager that tracks method calls
@MainActor
class TestableAudioManager: AudioManager {
    
    // Track method calls
    var ballHitCount = 0
    var tableBounceCount = 0
    var wallBounceCount = 0
    var gameOverCount = 0
    
    // Track positions
    var lastBallHitPosition: SIMD3<Float>?
    var lastTableBouncePosition: SIMD3<Float>?
    var lastWallBouncePosition: SIMD3<Float>?
    
    override func playBallHitSound(at position: SIMD3<Float>) {
        ballHitCount += 1
        lastBallHitPosition = position
        // Don't call super to avoid actual audio playback in tests
    }
    
    override func playTableBounceSound(at position: SIMD3<Float>) {
        tableBounceCount += 1
        lastTableBouncePosition = position
        // Don't call super to avoid actual audio playback in tests
    }
    
    override func playWallBounceSound(at position: SIMD3<Float>) {
        wallBounceCount += 1
        lastWallBouncePosition = position
        // Don't call super to avoid actual audio playback in tests
    }
    
    override func playGameOverSound() {
        gameOverCount += 1
        // Don't call super to avoid actual audio playback in tests
    }
    
    func reset() {
        ballHitCount = 0
        tableBounceCount = 0
        wallBounceCount = 0
        gameOverCount = 0
        lastBallHitPosition = nil
        lastTableBouncePosition = nil
        lastWallBouncePosition = nil
    }
}
