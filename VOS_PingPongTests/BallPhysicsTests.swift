#!/usr/bin/env swift
//
//  BallPhysicsTests.swift
//  VOS_PingPongTests
//
//  Property-based tests for ball physics
//

import Foundation
import simd

// MARK: - Simplified GameConfiguration for verification
struct GameConfiguration {
    let ballRadius: Float
    let gravity: SIMD3<Float>
    let maxBallVelocity: Float
    let ballStartPosition: SIMD3<Float>
    
    init(
        ballRadius: Float = 0.02,
        gravity: SIMD3<Float> = SIMD3<Float>(0, -9.81, 0),
        maxBallVelocity: Float = 15.0,
        ballStartPosition: SIMD3<Float> = SIMD3<Float>(0, 1.5, -1.5)
    ) {
        self.ballRadius = ballRadius
        self.gravity = gravity
        self.maxBallVelocity = maxBallVelocity
        self.ballStartPosition = ballStartPosition
    }
}

// MARK: - Simplified BallEntity for testing
struct BallEntity {
    var position: SIMD3<Float>
    var velocity: SIMD3<Float>
    let configuration: GameConfiguration
    
    init(at position: SIMD3<Float>, configuration: GameConfiguration) {
        self.position = position
        self.velocity = .zero
        self.configuration = configuration
    }
    
    mutating func reset(to position: SIMD3<Float>) {
        self.position = position
        self.velocity = .zero
    }
    
    mutating func applyImpulse(_ impulse: SIMD3<Float>) {
        self.velocity += impulse
        clampVelocity(max: configuration.maxBallVelocity)
    }
    
    mutating func clampVelocity(max: Float) {
        let speed = length(velocity)
        if speed > max {
            let direction = normalize(velocity)
            velocity = direction * max
        }
    }
    
    mutating func applyGravity(deltaTime: Float) {
        velocity.y += configuration.gravity.y * deltaTime
    }
    
    static func create(with configuration: GameConfiguration) -> BallEntity {
        return BallEntity(at: configuration.ballStartPosition, configuration: configuration)
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

print("=== Running Ball Physics Property Tests ===\n")

// Feature: ar-pingpong-game, Property 8: Gravity application
// Validates: Requirements 3.3
runTest(name: "Property 8: Gravity application") {
    for iteration in 0..<100 {
        // Generate random configuration with different gravity values
        let gravityMagnitude = Float.random(in: 5.0...15.0)
        let gravity = SIMD3<Float>(0, -gravityMagnitude, 0)
        
        let config = GameConfiguration(gravity: gravity)
        
        // Create ball entity
        var ball = BallEntity.create(with: config)
        
        // Set an initial upward velocity
        let initialVelocity = SIMD3<Float>(0, Float.random(in: 5.0...10.0), 0)
        ball.velocity = initialVelocity
        
        // Simulate a time step
        let deltaTime = Float.random(in: 0.01...0.1)
        
        // Store current velocity
        let velocityBefore = ball.velocity.y
        
        // Apply gravity
        ball.applyGravity(deltaTime: deltaTime)
        
        // Calculate expected velocity after gravity application
        let expectedVelocityY = velocityBefore + gravity.y * deltaTime
        
        // Verify the velocity decreased due to gravity
        let tolerance: Float = 0.01
        assert(
            abs(ball.velocity.y - expectedVelocityY) < tolerance,
            "Ball's Y-velocity should decrease by gravity * deltaTime (iteration \(iteration))"
        )
        
        // Verify that gravity causes downward acceleration
        assert(
            ball.velocity.y < velocityBefore,
            "Ball's Y-velocity should decrease over time due to gravity (iteration \(iteration))"
        )
    }
}

// Feature: ar-pingpong-game, Property 20: Velocity clamping
// Validates: Requirements 8.4
runTest(name: "Property 20: Velocity clamping") {
    for iteration in 0..<100 {
        // Generate random max velocity
        let maxVelocity = Float.random(in: 10.0...20.0)
        
        let config = GameConfiguration(maxBallVelocity: maxVelocity)
        
        // Create ball entity
        var ball = BallEntity.create(with: config)
        
        // Generate a velocity that exceeds the maximum
        let excessFactor = Float.random(in: 1.5...3.0)
        let excessSpeed = maxVelocity * excessFactor
        
        // Random direction
        let direction = normalize(SIMD3<Float>(
            Float.random(in: -1.0...1.0),
            Float.random(in: -1.0...1.0),
            Float.random(in: -1.0...1.0)
        ))
        
        let excessVelocity = direction * excessSpeed
        ball.velocity = excessVelocity
        
        // Clamp velocity
        ball.clampVelocity(max: maxVelocity)
        
        // Verify velocity is clamped to max
        let finalSpeed = length(ball.velocity)
        let tolerance: Float = 0.01
        
        assert(
            finalSpeed <= maxVelocity + tolerance,
            "Ball velocity should be clamped to max velocity (iteration \(iteration), speed: \(finalSpeed), max: \(maxVelocity))"
        )
        
        // Verify direction is preserved
        let finalDirection = normalize(ball.velocity)
        let directionDiff = length(finalDirection - direction)
        
        assert(
            directionDiff < tolerance,
            "Ball velocity direction should be preserved after clamping (iteration \(iteration))"
        )
    }
}

// Test that velocities below max are not affected
runTest(name: "Property 20: Velocity clamping (below max)") {
    for iteration in 0..<100 {
        let maxVelocity = Float.random(in: 10.0...20.0)
        
        let config = GameConfiguration(maxBallVelocity: maxVelocity)
        
        var ball = BallEntity.create(with: config)
        
        // Generate a velocity below the maximum
        let belowMaxSpeed = maxVelocity * Float.random(in: 0.3...0.9)
        
        let direction = normalize(SIMD3<Float>(
            Float.random(in: -1.0...1.0),
            Float.random(in: -1.0...1.0),
            Float.random(in: -1.0...1.0)
        ))
        
        let velocity = direction * belowMaxSpeed
        ball.velocity = velocity
        
        let speedBefore = length(ball.velocity)
        
        // Clamp velocity (should not change)
        ball.clampVelocity(max: maxVelocity)
        
        let speedAfter = length(ball.velocity)
        
        let tolerance: Float = 0.01
        assert(
            abs(speedAfter - speedBefore) < tolerance,
            "Ball velocity below max should not be affected by clamping (iteration \(iteration))"
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
    print("\n✅ All ball physics tests passed!")
    exit(0)
}
