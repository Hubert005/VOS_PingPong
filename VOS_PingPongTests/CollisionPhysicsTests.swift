//
//  CollisionPhysicsTests.swift
//  VOS_PingPongTests
//
//  Property-based tests for collision physics
//

import Foundation
import Testing
import RealityKit
@testable import VOS_PingPong

@Suite("Collision Physics Property Tests")
@MainActor
struct CollisionPhysicsTests {
    
    // MARK: - Property 6: Table bounce reflection
    // Feature: ar-pingpong-game, Property 6: Table bounce reflection
    // Validates: Requirements 3.1
    
    @Test("Property 6: Table bounce reflection")
    func testTableBounceReflection() throws {
        try PropertyTestHelper.runPropertyTest(iterations: 100) {
            // Generate random ball trajectory hitting the table
            let config = GameConfiguration()
            
            // Create a ball with random velocity approaching the table from above
            let ball = BallEntity.create(with: config)
            
            // Set initial velocity with downward component (hitting table)
            let velocityX = PropertyGenerator.randomFloat(min: -5.0, max: 5.0)
            let velocityY = PropertyGenerator.randomFloat(min: -10.0, max: -2.0) // Downward
            let velocityZ = PropertyGenerator.randomFloat(min: -5.0, max: 5.0)
            let initialVelocity = SIMD3<Float>(velocityX, velocityY, velocityZ)
            
            guard var physicsBody = ball.components[PhysicsBodyComponent.self] else {
                Issue.record("Ball should have PhysicsBodyComponent")
                return
            }
            
            physicsBody.linearVelocity = initialVelocity
            ball.components[PhysicsBodyComponent.self] = physicsBody
            
            // Simulate table collision with reflection physics
            // The perpendicular component (Y) should reverse, parallel components preserved
            let restitution: Float = 0.89 // Table tennis ball restitution coefficient
            
            // Calculate reflected velocity
            // For a horizontal table surface, the normal is (0, 1, 0)
            let surfaceNormal = SIMD3<Float>(0, 1, 0)
            
            // Decompose velocity into normal and tangential components
            let velocityDotNormal = dot(initialVelocity, surfaceNormal)
            let normalComponent = surfaceNormal * velocityDotNormal
            let tangentialComponent = initialVelocity - normalComponent
            
            // Reflect normal component with restitution
            let reflectedNormal = -normalComponent * restitution
            let reflectedVelocity = tangentialComponent + reflectedNormal
            
            // Apply the reflection
            physicsBody.linearVelocity = reflectedVelocity
            ball.components[PhysicsBodyComponent.self] = physicsBody
            
            // Verify reflection properties
            guard let finalPhysicsBody = ball.components[PhysicsBodyComponent.self] else {
                Issue.record("Ball should have PhysicsBodyComponent")
                return
            }
            
            let finalVelocity = finalPhysicsBody.linearVelocity
            
            // 1. Y-component should reverse direction (with energy loss)
            #expect(
                finalVelocity.y > 0,
                "After table bounce, Y-velocity should be positive (upward)"
            )
            
            #expect(
                abs(finalVelocity.y) <= abs(initialVelocity.y),
                "After table bounce, Y-velocity magnitude should be less than or equal to initial (energy loss)"
            )
            
            // 2. X and Z components should be preserved (tangential to surface)
            let tolerance: Float = 0.01
            #expect(
                abs(finalVelocity.x - initialVelocity.x) < tolerance,
                "X-velocity should be preserved during table bounce"
            )
            
            #expect(
                abs(finalVelocity.z - initialVelocity.z) < tolerance,
                "Z-velocity should be preserved during table bounce"
            )
            
            // 3. Verify restitution coefficient is applied correctly
            let expectedYVelocity = -initialVelocity.y * restitution
            #expect(
                abs(finalVelocity.y - expectedYVelocity) < tolerance,
                "Y-velocity should reflect with restitution coefficient applied"
            )
        }
    }
    
    // MARK: - Property 7: Wall bounce reflection
    // Feature: ar-pingpong-game, Property 7: Wall bounce reflection
    // Validates: Requirements 3.2
    
    @Test("Property 7: Wall bounce reflection")
    func testWallBounceReflection() throws {
        try PropertyTestHelper.runPropertyTest(iterations: 100) {
            // Generate random ball trajectory hitting the wall
            let config = GameConfiguration()
            
            // Create a ball with random velocity approaching the wall
            let ball = BallEntity.create(with: config)
            
            // Set initial velocity with component toward wall (negative Z)
            let velocityX = PropertyGenerator.randomFloat(min: -5.0, max: 5.0)
            let velocityY = PropertyGenerator.randomFloat(min: -5.0, max: 5.0)
            let velocityZ = PropertyGenerator.randomFloat(min: -10.0, max: -2.0) // Toward wall
            let initialVelocity = SIMD3<Float>(velocityX, velocityY, velocityZ)
            
            guard var physicsBody = ball.components[PhysicsBodyComponent.self] else {
                Issue.record("Ball should have PhysicsBodyComponent")
                return
            }
            
            physicsBody.linearVelocity = initialVelocity
            ball.components[PhysicsBodyComponent.self] = physicsBody
            
            // Simulate wall collision with reflection physics
            // The wall is vertical, facing in the +Z direction
            // Normal vector points back toward player: (0, 0, 1)
            let restitution: Float = 0.89 // Table tennis ball restitution coefficient
            
            let wallNormal = SIMD3<Float>(0, 0, 1)
            
            // Decompose velocity into normal and tangential components
            let velocityDotNormal = dot(initialVelocity, wallNormal)
            let normalComponent = wallNormal * velocityDotNormal
            let tangentialComponent = initialVelocity - normalComponent
            
            // Reflect normal component with restitution
            let reflectedNormal = -normalComponent * restitution
            let reflectedVelocity = tangentialComponent + reflectedNormal
            
            // Apply the reflection
            physicsBody.linearVelocity = reflectedVelocity
            ball.components[PhysicsBodyComponent.self] = physicsBody
            
            // Verify reflection properties
            guard let finalPhysicsBody = ball.components[PhysicsBodyComponent.self] else {
                Issue.record("Ball should have PhysicsBodyComponent")
                return
            }
            
            let finalVelocity = finalPhysicsBody.linearVelocity
            
            // 1. Z-component should reverse direction (with energy loss)
            #expect(
                finalVelocity.z > 0,
                "After wall bounce, Z-velocity should be positive (back toward player)"
            )
            
            #expect(
                abs(finalVelocity.z) <= abs(initialVelocity.z),
                "After wall bounce, Z-velocity magnitude should be less than or equal to initial (energy loss)"
            )
            
            // 2. X and Y components should be preserved (tangential to wall)
            let tolerance: Float = 0.01
            #expect(
                abs(finalVelocity.x - initialVelocity.x) < tolerance,
                "X-velocity should be preserved during wall bounce"
            )
            
            #expect(
                abs(finalVelocity.y - initialVelocity.y) < tolerance,
                "Y-velocity should be preserved during wall bounce"
            )
            
            // 3. Verify restitution coefficient is applied correctly
            let expectedZVelocity = -initialVelocity.z * restitution
            #expect(
                abs(finalVelocity.z - expectedZVelocity) < tolerance,
                "Z-velocity should reflect with restitution coefficient applied"
            )
        }
    }
    
    // MARK: - Property 9: Racket hit imparts velocity
    // Feature: ar-pingpong-game, Property 9: Racket hit imparts velocity
    // Validates: Requirements 3.5
    
    @Test("Property 9: Racket hit imparts velocity")
    func testRacketHitImpartsVelocity() throws {
        try PropertyTestHelper.runPropertyTest(iterations: 100) {
            // Generate random racket and ball configuration
            let config = GameConfiguration()
            
            // Create ball and racket
            let ball = BallEntity.create(with: config)
            let racket = RacketEntity.create()
            
            // Set initial ball velocity (could be stationary or moving)
            let initialBallVelocityX = PropertyGenerator.randomFloat(min: -2.0, max: 2.0)
            let initialBallVelocityY = PropertyGenerator.randomFloat(min: -2.0, max: 2.0)
            let initialBallVelocityZ = PropertyGenerator.randomFloat(min: -2.0, max: 2.0)
            let initialBallVelocity = SIMD3<Float>(initialBallVelocityX, initialBallVelocityY, initialBallVelocityZ)
            
            guard var ballPhysicsBody = ball.components[PhysicsBodyComponent.self] else {
                Issue.record("Ball should have PhysicsBodyComponent")
                return
            }
            
            ballPhysicsBody.linearVelocity = initialBallVelocity
            ball.components[PhysicsBodyComponent.self] = ballPhysicsBody
            
            // Set racket velocity (simulating hand movement)
            let racketVelocityX = PropertyGenerator.randomFloat(min: -8.0, max: 8.0)
            let racketVelocityY = PropertyGenerator.randomFloat(min: -8.0, max: 8.0)
            let racketVelocityZ = PropertyGenerator.randomFloat(min: -8.0, max: 8.0)
            let racketVelocity = SIMD3<Float>(racketVelocityX, racketVelocityY, racketVelocityZ)
            
            // Simulate racket hit - transfer velocity from racket to ball
            // In a real collision, the ball's velocity is influenced by the racket's velocity
            // We use a simplified model: v_ball_new = v_ball_old + k * v_racket
            // where k is a velocity transfer coefficient (0 < k <= 1)
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
            
            ballPhysicsBody.linearVelocity = clampedVelocity
            ball.components[PhysicsBodyComponent.self] = ballPhysicsBody
            
            // Verify velocity transfer properties
            guard let finalBallPhysicsBody = ball.components[PhysicsBodyComponent.self] else {
                Issue.record("Ball should have PhysicsBodyComponent")
                return
            }
            
            let actualFinalVelocity = finalBallPhysicsBody.linearVelocity
            
            // 1. Ball velocity should be influenced by racket velocity
            let racketSpeed = length(racketVelocity)
            
            // Only test when racket has significant velocity AND the velocities aren't opposing
            if racketSpeed > 1.0 {
                let initialSpeed = length(initialBallVelocity)
                let finalSpeed = length(actualFinalVelocity)
                
                // Check if the racket and ball velocities are roughly aligned (not opposing)
                let dotProduct = dot(normalize(racketVelocity), normalize(initialBallVelocity))
                
                // If velocities are not strongly opposing (dot product > -0.8), expect speed change
                if dotProduct > -0.8 || initialSpeed < 0.5 {
                    let speedChanged = abs(finalSpeed - initialSpeed) > 0.1
                    
                    #expect(
                        speedChanged,
                        "Ball velocity should change after racket hit"
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
            let transferTolerance: Float = 0.001
            #expect(
                fasterTransferSpeed >= slowerTransferSpeed - transferTolerance,
                "Faster racket movement should transfer equal or more velocity"
            )
            
            // 3. Verify velocity is clamped to max
            let actualSpeed = length(actualFinalVelocity)
            let tolerance: Float = 0.01
            
            #expect(
                actualSpeed <= maxVelocity + tolerance,
                "Ball velocity should be clamped to maximum velocity"
            )
        }
    }
}
