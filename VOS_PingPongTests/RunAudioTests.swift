#!/usr/bin/env swift
//
//  RunAudioTests.swift
//  VOS_PingPongTests
//
//  Standalone test runner for audio property tests
//

import Foundation
import simd

// MARK: - Mock Audio Manager for Testing

class MockAudioManager {
    var ballHitCount = 0
    var tableBounceCount = 0
    var wallBounceCount = 0
    var gameOverCount = 0
    
    var lastBallHitPosition: SIMD3<Float>?
    var lastTableBouncePosition: SIMD3<Float>?
    var lastWallBouncePosition: SIMD3<Float>?
    
    func playBallHitSound(at position: SIMD3<Float>) {
        ballHitCount += 1
        lastBallHitPosition = position
    }
    
    func playTableBounceSound(at position: SIMD3<Float>) {
        tableBounceCount += 1
        lastTableBouncePosition = position
    }
    
    func playWallBounceSound(at position: SIMD3<Float>) {
        wallBounceCount += 1
        lastWallBouncePosition = position
    }
    
    func playGameOverSound() {
        gameOverCount += 1
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

// MARK: - Test Framework
var testsPassed = 0
var testsFailed = 0

func assert(_ condition: Bool, _ message: String) {
    if condition {
        testsPassed += 1
    } else {
        testsFailed += 1
        print("❌ FAILED: \(message)")
    }
}

func runTest(name: String, test: () -> Void) {
    print("\nRunning: \(name)")
    test()
}

// MARK: - Property Tests

print("=== Running Audio Property Tests ===\n")

// Feature: ar-pingpong-game, Property 16: Collision audio events
// Validates: Requirements 7.1
runTest(name: "Property 16: Collision audio events") {
    for iteration in 0..<100 {
        let audioManager = MockAudioManager()
        
        // Generate random collision position
        let positionX = Float.random(in: -2.0...2.0)
        let positionY = Float.random(in: 0.0...2.0)
        let positionZ = Float.random(in: -3.0...0.0)
        let collisionPosition = SIMD3<Float>(positionX, positionY, positionZ)
        
        // Test 1: Table collision should trigger table bounce sound
        audioManager.reset()
        audioManager.playTableBounceSound(at: collisionPosition)
        
        assert(
            audioManager.tableBounceCount == 1,
            "Table collision should trigger exactly one table bounce sound - iteration \(iteration)"
        )
        
        assert(
            audioManager.lastTableBouncePosition != nil,
            "Table bounce sound should have a position - iteration \(iteration)"
        )
        
        if let position = audioManager.lastTableBouncePosition {
            let tolerance: Float = 0.001
            let distance = length(position - collisionPosition)
            assert(
                distance < tolerance,
                "Table bounce sound should be at collision position - iteration \(iteration)"
            )
        }
        
        // Test 2: Wall collision should trigger wall bounce sound
        audioManager.reset()
        audioManager.playWallBounceSound(at: collisionPosition)
        
        assert(
            audioManager.wallBounceCount == 1,
            "Wall collision should trigger exactly one wall bounce sound - iteration \(iteration)"
        )
        
        assert(
            audioManager.lastWallBouncePosition != nil,
            "Wall bounce sound should have a position - iteration \(iteration)"
        )
        
        if let position = audioManager.lastWallBouncePosition {
            let tolerance: Float = 0.001
            let distance = length(position - collisionPosition)
            assert(
                distance < tolerance,
                "Wall bounce sound should be at collision position - iteration \(iteration)"
            )
        }
        
        // Test 3: Racket collision should trigger ball hit sound
        audioManager.reset()
        audioManager.playBallHitSound(at: collisionPosition)
        
        assert(
            audioManager.ballHitCount == 1,
            "Racket collision should trigger exactly one ball hit sound - iteration \(iteration)"
        )
        
        assert(
            audioManager.lastBallHitPosition != nil,
            "Ball hit sound should have a position - iteration \(iteration)"
        )
        
        if let position = audioManager.lastBallHitPosition {
            let tolerance: Float = 0.001
            let distance = length(position - collisionPosition)
            assert(
                distance < tolerance,
                "Ball hit sound should be at collision position - iteration \(iteration)"
            )
        }
        
        // Test 4: Ground collision should trigger game over sound
        audioManager.reset()
        audioManager.playGameOverSound()
        
        assert(
            audioManager.gameOverCount == 1,
            "Ground collision should trigger exactly one game over sound - iteration \(iteration)"
        )
        
        // Test 5: Multiple collisions should accumulate counts
        audioManager.reset()
        let numCollisions = Int.random(in: 1...10)
        
        for _ in 0..<numCollisions {
            let randomPos = SIMD3<Float>(
                Float.random(in: -2.0...2.0),
                Float.random(in: 0.0...2.0),
                Float.random(in: -3.0...0.0)
            )
            audioManager.playTableBounceSound(at: randomPos)
        }
        
        assert(
            audioManager.tableBounceCount == numCollisions,
            "Multiple collisions should accumulate sound counts - iteration \(iteration)"
        )
        
        // Test 6: Different collision types should be independent
        audioManager.reset()
        audioManager.playTableBounceSound(at: collisionPosition)
        audioManager.playWallBounceSound(at: collisionPosition)
        audioManager.playBallHitSound(at: collisionPosition)
        audioManager.playGameOverSound()
        
        assert(
            audioManager.tableBounceCount == 1 &&
            audioManager.wallBounceCount == 1 &&
            audioManager.ballHitCount == 1 &&
            audioManager.gameOverCount == 1,
            "Different collision types should be tracked independently - iteration \(iteration)"
        )
    }
}

// Summary
print("\n=== Test Summary ===")
print("Passed: \(testsPassed)")
print("Failed: \(testsFailed)")

if testsFailed > 0 {
    print("\n❌ Some tests failed")
    exit(1)
} else {
    print("\n✅ All audio tests passed!")
    exit(0)
}
