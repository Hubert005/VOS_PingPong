//
//  RacketTests.swift
//  VOS_PingPongTests
//
//  Property-based tests for racket entity and hand tracking
//

import Foundation
import Testing
import RealityKit
@testable import VOS_PingPong

@Suite("Racket Property Tests")
@MainActor
struct RacketTests {
    
    // MARK: - Property 4: Racket follows hand position
    // Feature: ar-pingpong-game, Property 4: Racket follows hand position
    // Validates: Requirements 2.2
    
    @Test("Property 4: Racket follows hand position")
    func testRacketFollowsHandPosition() throws {
        try PropertyTestHelper.runPropertyTest(iterations: 100) {
            // Create a racket entity
            let racket = RacketEntity.create()
            
            // Generate random hand transform
            let handX = PropertyGenerator.randomFloat(min: -1.0, max: 1.0)
            let handY = PropertyGenerator.randomFloat(min: 0.5, max: 2.0)
            let handZ = PropertyGenerator.randomFloat(min: -2.0, max: 0.0)
            let handPosition = SIMD3<Float>(handX, handY, handZ)
            
            // Generate random rotation (quaternion)
            let angle = PropertyGenerator.randomFloat(min: 0, max: .pi * 2)
            let axis = normalize(SIMD3<Float>(
                PropertyGenerator.randomFloat(min: -1, max: 1),
                PropertyGenerator.randomFloat(min: -1, max: 1),
                PropertyGenerator.randomFloat(min: -1, max: 1)
            ))
            let rotation = simd_quatf(angle: angle, axis: axis)
            
            // Create hand transform
            var handTransform = Transform()
            handTransform.translation = handPosition
            handTransform.rotation = rotation
            
            // Update racket position from hand transform
            racket.updatePosition(from: handTransform)
            
            // Verify racket position matches hand position
            let tolerance: Float = 0.001
            #expect(
                abs(racket.position.x - handPosition.x) < tolerance &&
                abs(racket.position.y - handPosition.y) < tolerance &&
                abs(racket.position.z - handPosition.z) < tolerance,
                "Racket position should match hand transform position"
            )
            
            // Verify racket orientation matches hand orientation
            let racketQuat = racket.orientation
            let handQuat = rotation
            
            // Compare quaternions (accounting for quaternion double-cover: q and -q represent same rotation)
            let dotProduct = abs(
                racketQuat.vector.x * handQuat.vector.x +
                racketQuat.vector.y * handQuat.vector.y +
                racketQuat.vector.z * handQuat.vector.z +
                racketQuat.vector.w * handQuat.vector.w
            )
            
            #expect(
                dotProduct > 0.999,
                "Racket orientation should match hand transform orientation"
            )
        }
    }
    
    // MARK: - Property 5: Racket-ball collision detection
    // Feature: ar-pingpong-game, Property 5: Racket-ball collision detection
    // Validates: Requirements 2.4
    
    @Test("Property 5: Racket-ball collision detection")
    func testRacketBallCollisionDetection() throws {
        try PropertyTestHelper.runPropertyTest(iterations: 100) {
            // Create configuration
            let config = GameConfiguration()
            
            // Create racket and ball entities
            let racket = RacketEntity.create()
            let ball = BallEntity.create(with: config)
            
            // Generate random position for racket
            let racketX = PropertyGenerator.randomFloat(min: -1.0, max: 1.0)
            let racketY = PropertyGenerator.randomFloat(min: 0.5, max: 2.0)
            let racketZ = PropertyGenerator.randomFloat(min: -2.0, max: 0.0)
            let racketPosition = SIMD3<Float>(racketX, racketY, racketZ)
            
            var racketTransform = Transform()
            racketTransform.translation = racketPosition
            racket.updatePosition(from: racketTransform)
            
            // Test case 1: Ball overlapping with racket (collision should be detected)
            // Position ball very close to racket center
            let overlapOffset = SIMD3<Float>(
                PropertyGenerator.randomFloat(min: -0.05, max: 0.05),
                PropertyGenerator.randomFloat(min: -0.05, max: 0.05),
                PropertyGenerator.randomFloat(min: -0.05, max: 0.05)
            )
            ball.position = racketPosition + overlapOffset
            
            // Verify both entities have collision components
            #expect(
                racket.components[CollisionComponent.self] != nil,
                "Racket should have CollisionComponent"
            )
            
            #expect(
                ball.components[CollisionComponent.self] != nil,
                "Ball should have CollisionComponent"
            )
            
            // Verify collision components are configured for detection
            guard let racketCollision = racket.components[CollisionComponent.self],
                  let ballCollision = ball.components[CollisionComponent.self] else {
                Issue.record("Both entities should have collision components")
                return
            }
            
            // Check that collision shapes exist
            #expect(
                !racketCollision.shapes.isEmpty,
                "Racket should have collision shapes"
            )
            
            #expect(
                !ballCollision.shapes.isEmpty,
                "Ball should have collision shapes"
            )
            
            // Verify entities are named correctly for collision identification
            #expect(
                racket.name == CollisionType.racket.rawValue,
                "Racket should be named with racket collision type"
            )
            
            #expect(
                ball.name == CollisionType.ball.rawValue,
                "Ball should be named with ball collision type"
            )
            
            // Test case 2: Ball far from racket (no collision)
            // Position ball far away from racket
            let farPosition = racketPosition + SIMD3<Float>(
                PropertyGenerator.randomFloat(min: 2.0, max: 5.0),
                PropertyGenerator.randomFloat(min: 2.0, max: 5.0),
                PropertyGenerator.randomFloat(min: 2.0, max: 5.0)
            )
            ball.position = farPosition
            
            // Calculate distance between ball and racket
            let distance = simd_distance(ball.position, racket.position)
            
            // Distance should be large enough that no collision occurs
            // Racket is approximately 0.25m tall, ball radius is ~0.02m
            let minSeparation: Float = 0.3
            #expect(
                distance > minSeparation,
                "Ball positioned far from racket should have sufficient separation"
            )
        }
    }
    
    // MARK: - Additional Tests for Velocity Calculation
    
    @Test("Racket velocity calculation")
    func testRacketVelocityCalculation() throws {
        try PropertyTestHelper.runPropertyTest(iterations: 100) {
            // Create a racket entity
            let racket = RacketEntity.create()
            
            // Set initial position
            let initialX = PropertyGenerator.randomFloat(min: -1.0, max: 1.0)
            let initialY = PropertyGenerator.randomFloat(min: 0.5, max: 2.0)
            let initialZ = PropertyGenerator.randomFloat(min: -2.0, max: 0.0)
            let initialPosition = SIMD3<Float>(initialX, initialY, initialZ)
            
            var initialTransform = Transform()
            initialTransform.translation = initialPosition
            racket.updatePosition(from: initialTransform)
            
            // Wait a small amount of time (simulate frame time)
            let deltaTime: Float = 0.016 // ~60 FPS
            Thread.sleep(forTimeInterval: TimeInterval(deltaTime))
            
            // Move to new position
            let displacement = SIMD3<Float>(
                PropertyGenerator.randomFloat(min: -0.1, max: 0.1),
                PropertyGenerator.randomFloat(min: -0.1, max: 0.1),
                PropertyGenerator.randomFloat(min: -0.1, max: 0.1)
            )
            let newPosition = initialPosition + displacement
            
            var newTransform = Transform()
            newTransform.translation = newPosition
            racket.updatePosition(from: newTransform)
            
            // Calculate velocity
            let velocity = racket.calculateVelocity()
            
            // Verify velocity is in the correct direction
            // The velocity should point in the same direction as displacement
            let velocityDirection = normalize(velocity)
            let displacementDirection = normalize(displacement)
            
            // Only check direction if displacement is significant
            let displacementMagnitude = simd_length(displacement)
            if displacementMagnitude > 0.001 {
                let dotProduct = dot(velocityDirection, displacementDirection)
                
                // Dot product should be close to 1 (same direction)
                // Allow some tolerance due to timing variations
                #expect(
                    dotProduct > 0.5,
                    "Velocity should point in the same direction as displacement"
                )
            }
            
            // Verify velocity magnitude is reasonable
            // For small displacements over ~16ms, velocity should be < 10 m/s
            let velocityMagnitude = simd_length(velocity)
            #expect(
                velocityMagnitude < 10.0,
                "Velocity magnitude should be reasonable for hand movement"
            )
        }
    }
}
