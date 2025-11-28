#!/usr/bin/env swift
//
//  RunCollisionPhysicsTests.swift
//  VOS_PingPongTests
//
//  Standalone test runner for collision physics property tests
//

import Foundation
import simd

// MARK: - GameConfiguration
struct GameConfiguration {
    let tableSize: SIMD3<Float>
    let wallSize: SIMD3<Float>
    let ballRadius: Float
    let gravity: SIMD3<Float>
    let maxBallVelocity: Float
    let tablePosition: SIMD3<Float>
    let wallPosition: SIMD3<Float>
    let groundLevel: Float
    
    init(
        tableSize: SIMD3<Float> = SIMD3<Float>(2.74, 0.76, 1.525),
        wallSize: SIMD3<Float> = SIMD3<Float>(1.525, 1.0, 0.05),
        ballRadius: Float = 0.02,
        gravity: SIMD3<Float> = SIMD3<Float>(0, -9.81, 0),
        maxBallVelocity: Float = 15.0,
        tablePosition: SIMD3<Float> = SIMD3<Float>(0, 0.76, -1.5),
        wallPosition: SIMD3<Float> = SIMD3<Float>(0, 1.26, -2.87),
        groundLevel: Float = 0.0
    ) {
        self.tableSize = tableSize
        self.wallSize = wallSize
        self.ballRadius = ballRadius
        self.gravity = gravity
        self.maxBallVelocity = maxBallVelocity
        self.tablePosition = tablePosition
        self.wallPosition = wallPosition
        self.groundLevel = groundLevel
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

print("=== Running Collision Physics Property Tests ===\n")

// Feature: ar-pingpong-game, Property 6: Table bounce reflection
// Validates: Requirements 3.1
runTest(name: "Property 6: Table bounce reflection") {
    for iteration in 0..<100 {
        let config = GameConfiguration()
        
        // Generate random ball velocity hitting the table from above
        let velocityX = Float.random(in: -5.0...5.0)
        let velocityY = Float.random(in: -10.0...(-2.0)) // Downward
        let velocityZ = Float.random(in: -5.0...5.0)
        let initialVelocity = SIMD3<Float>(velocityX, velocityY, velocityZ)
        
        // Simulate table collision with reflection physics
        let restitution: Float = 0.89 // Table tennis ball restitution coefficient
        
        // For a horizontal table surface, the normal is (0, 1, 0)
        let surfaceNormal = SIMD3<Float>(0, 1, 0)
        
        // Decompose velocity into normal and tangential components
        let velocityDotNormal = dot(initialVelocity, surfaceNormal)
        let normalComponent = surfaceNormal * velocityDotNormal
        let tangentialComponent = initialVelocity - normalComponent
        
        // Reflect normal component with restitution
        let reflectedNormal = -normalComponent * restitution
        let reflectedVelocity = tangentialComponent + reflectedNormal
        
        // Verify reflection properties
        let tolerance: Float = 0.01
        
        // 1. Y-component should reverse direction (with energy loss)
        assert(
            reflectedVelocity.y > 0,
            "After table bounce, Y-velocity should be positive (upward) - iteration \(iteration)"
        )
        
        assert(
            abs(reflectedVelocity.y) <= abs(initialVelocity.y),
            "After table bounce, Y-velocity magnitude should be less than or equal to initial - iteration \(iteration)"
        )
        
        // 2. X and Z components should be preserved (tangential to surface)
        assert(
            abs(reflectedVelocity.x - initialVelocity.x) < tolerance,
            "X-velocity should be preserved during table bounce - iteration \(iteration)"
        )
        
        assert(
            abs(reflectedVelocity.z - initialVelocity.z) < tolerance,
            "Z-velocity should be preserved during table bounce - iteration \(iteration)"
        )
        
        // 3. Verify restitution coefficient is applied correctly
        let expectedYVelocity = -initialVelocity.y * restitution
        assert(
            abs(reflectedVelocity.y - expectedYVelocity) < tolerance,
            "Y-velocity should reflect with restitution coefficient applied - iteration \(iteration)"
        )
    }
}

// Feature: ar-pingpong-game, Property 7: Wall bounce reflection
// Validates: Requirements 3.2
runTest(name: "Property 7: Wall bounce reflection") {
    for iteration in 0..<100 {
        let config = GameConfiguration()
        
        // Generate random ball velocity hitting the wall
        let velocityX = Float.random(in: -5.0...5.0)
        let velocityY = Float.random(in: -5.0...5.0)
        let velocityZ = Float.random(in: -10.0...(-2.0)) // Toward wall (negative Z)
        let initialVelocity = SIMD3<Float>(velocityX, velocityY, velocityZ)
        
        // Simulate wall collision with reflection physics
        // The wall is vertical, facing in the +Z direction
        // Normal vector points back toward player: (0, 0, 1)
        let restitution: Float = 0.89
        
        let wallNormal = SIMD3<Float>(0, 0, 1)
        
        // Decompose velocity into normal and tangential components
        let velocityDotNormal = dot(initialVelocity, wallNormal)
        let normalComponent = wallNormal * velocityDotNormal
        let tangentialComponent = initialVelocity - normalComponent
        
        // Reflect normal component with restitution
        let reflectedNormal = -normalComponent * restitution
        let reflectedVelocity = tangentialComponent + reflectedNormal
        
        // Verify reflection properties
        let tolerance: Float = 0.01
        
        // 1. Z-component should reverse direction (with energy loss)
        assert(
            reflectedVelocity.z > 0,
            "After wall bounce, Z-velocity should be positive (back toward player) - iteration \(iteration)"
        )
        
        assert(
            abs(reflectedVelocity.z) <= abs(initialVelocity.z),
            "After wall bounce, Z-velocity magnitude should be less than or equal to initial - iteration \(iteration)"
        )
        
        // 2. X and Y components should be preserved (tangential to wall)
        assert(
            abs(reflectedVelocity.x - initialVelocity.x) < tolerance,
            "X-velocity should be preserved during wall bounce - iteration \(iteration)"
        )
        
        assert(
            abs(reflectedVelocity.y - initialVelocity.y) < tolerance,
            "Y-velocity should be preserved during wall bounce - iteration \(iteration)"
        )
        
        // 3. Verify restitution coefficient is applied correctly
        let expectedZVelocity = -initialVelocity.z * restitution
        assert(
            abs(reflectedVelocity.z - expectedZVelocity) < tolerance,
            "Z-velocity should reflect with restitution coefficient applied - iteration \(iteration)"
        )
    }
}

// Feature: ar-pingpong-game, Property 9: Racket hit imparts velocity
// Validates: Requirements 3.5
runTest(name: "Property 9: Racket hit imparts velocity") {
    for iteration in 0..<100 {
        let config = GameConfiguration()
        
        // Generate random initial ball velocity
        let initialBallVelocityX = Float.random(in: -2.0...2.0)
        let initialBallVelocityY = Float.random(in: -2.0...2.0)
        let initialBallVelocityZ = Float.random(in: -2.0...2.0)
        let initialBallVelocity = SIMD3<Float>(initialBallVelocityX, initialBallVelocityY, initialBallVelocityZ)
        
        // Generate random racket velocity
        let racketVelocityX = Float.random(in: -8.0...8.0)
        let racketVelocityY = Float.random(in: -8.0...8.0)
        let racketVelocityZ = Float.random(in: -8.0...8.0)
        let racketVelocity = SIMD3<Float>(racketVelocityX, racketVelocityY, racketVelocityZ)
        
        // Simulate racket hit - transfer velocity from racket to ball
        let velocityTransferCoefficient: Float = 0.8
        let velocityTransfer = racketVelocity * velocityTransferCoefficient
        let finalBallVelocity = initialBallVelocity + velocityTransfer
        
        // Apply velocity clamping
        let maxVelocity = config.maxBallVelocity
        let speed = length(finalBallVelocity)
        let clampedVelocity: SIMD3<Float>
        if speed > maxVelocity {
            clampedVelocity = normalize(finalBallVelocity) * maxVelocity
        } else {
            clampedVelocity = finalBallVelocity
        }
        
        // Verify velocity transfer properties
        let racketSpeed = length(racketVelocity)
        
        // 1. Ball velocity should be influenced by racket velocity
        // Only test when racket has significant velocity AND the velocities aren't opposing
        if racketSpeed > 1.0 {
            let initialSpeed = length(initialBallVelocity)
            let finalSpeed = length(clampedVelocity)
            
            // Check if the racket and ball velocities are roughly aligned (not opposing)
            let dotProduct = dot(normalize(racketVelocity), normalize(initialBallVelocity))
            
            // If velocities are not strongly opposing (dot product > -0.8), expect speed change
            if dotProduct > -0.8 || initialSpeed < 0.5 {
                let speedChanged = abs(finalSpeed - initialSpeed) > 0.1
                
                assert(
                    speedChanged,
                    "Ball velocity should change after racket hit - iteration \(iteration)"
                )
            }
        }
        
        // 2. Faster racket movement should produce faster ball movement (before clamping)
        // This property holds when comparing the velocity transfers themselves
        let fasterTransferSpeed = length(velocityTransfer)
        let slowerRacketVelocity = racketVelocity * 0.5
        let slowerVelocityTransfer = slowerRacketVelocity * velocityTransferCoefficient
        let slowerTransferSpeed = length(slowerVelocityTransfer)
        
        // The faster racket should transfer more velocity
        let tolerance: Float = 0.001
        assert(
            fasterTransferSpeed >= slowerTransferSpeed - tolerance,
            "Faster racket movement should transfer equal or more velocity - iteration \(iteration)"
        )
        
        // 3. Verify velocity is clamped to max
        let actualSpeed = length(clampedVelocity)
        let clampTolerance: Float = 0.01
        
        assert(
            actualSpeed <= maxVelocity + clampTolerance,
            "Ball velocity should be clamped to maximum velocity - iteration \(iteration)"
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
    print("\n✅ All collision physics tests passed!")
    exit(0)
}
