//
//  CollisionHandler.swift
//  VOS_PingPong
//
//  Handles collision physics for ball interactions with table, wall, and racket
//

import Foundation
import RealityKit

/// Handles collision events and applies appropriate physics responses
@MainActor
class CollisionHandler {
    
    // MARK: - Properties
    
    /// Game configuration for physics constants
    private let configuration: GameConfiguration
    
    /// Game manager for tracking hits and game state
    private weak var gameManager: GameManager?
    
    /// Audio manager for playing collision sounds
    private let audioManager: AudioManager
    
    /// Restitution coefficient for table tennis ball (bounciness)
    private let restitution: Float = 0.89
    
    /// Velocity transfer coefficient for racket hits
    private let velocityTransferCoefficient: Float = 0.8
    
    // MARK: - Initialization
    
    /// Creates a collision handler with the specified configuration
    /// - Parameters:
    ///   - configuration: Game configuration
    ///   - gameManager: Game manager for tracking game state
    ///   - audioManager: Audio manager for playing sounds
    init(configuration: GameConfiguration, gameManager: GameManager, audioManager: AudioManager) {
        self.configuration = configuration
        self.gameManager = gameManager
        self.audioManager = audioManager
    }
    
    // MARK: - Collision Handling Methods
    
    /// Handles collision between ball and table
    /// Applies reflection physics with restitution
    /// - Parameters:
    ///   - ball: The ball entity
    ///   - table: The table entity
    func handleBallTableCollision(ball: Entity, table: Entity) {
        guard var physicsMotion = ball.components[PhysicsMotionComponent.self] else {
            return
        }
        
        let velocity = physicsMotion.linearVelocity
        
        // Table surface normal points upward (0, 1, 0)
        let surfaceNormal = SIMD3<Float>(0, 1, 0)
        
        // Apply reflection physics
        let reflectedVelocity = reflectVelocity(
            velocity: velocity,
            surfaceNormal: surfaceNormal,
            restitution: restitution
        )
        
        physicsMotion.linearVelocity = reflectedVelocity
        ball.components[PhysicsMotionComponent.self] = physicsMotion
        
        // Clamp velocity to prevent unrealistic speeds
        clampBallVelocity(ball: ball)
        
        // Play table bounce sound at collision position
        audioManager.playTableBounceSound(at: ball.position)
    }
    
    /// Handles collision between ball and wall
    /// Applies reflection physics with restitution
    /// - Parameters:
    ///   - ball: The ball entity
    ///   - wall: The wall entity
    func handleBallWallCollision(ball: Entity, wall: Entity) {
        guard var physicsMotion = ball.components[PhysicsMotionComponent.self] else {
            return
        }
        
        let velocity = physicsMotion.linearVelocity
        
        // Wall normal points back toward player (0, 0, 1)
        let wallNormal = SIMD3<Float>(0, 0, 1)
        
        // Apply reflection physics
        let reflectedVelocity = reflectVelocity(
            velocity: velocity,
            surfaceNormal: wallNormal,
            restitution: restitution
        )
        
        physicsMotion.linearVelocity = reflectedVelocity
        ball.components[PhysicsMotionComponent.self] = physicsMotion
        
        // Clamp velocity to prevent unrealistic speeds
        clampBallVelocity(ball: ball)
        
        // Play wall bounce sound at collision position
        audioManager.playWallBounceSound(at: ball.position)
    }
    
    /// Handles collision between ball and racket
    /// Transfers velocity from racket to ball
    /// - Parameters:
    ///   - ball: The ball entity
    ///   - racket: The racket entity (should be RacketEntity)
    func handleBallRacketCollision(ball: Entity, racket: Entity) {
        guard var ballPhysicsMotion = ball.components[PhysicsMotionComponent.self] else {
            return
        }
        
        // Get racket velocity if it's a RacketEntity
        let racketVelocity: SIMD3<Float>
        if let racketEntity = racket as? RacketEntity {
            racketVelocity = racketEntity.velocity
        } else {
            // Fallback: no velocity transfer if we can't get racket velocity
            racketVelocity = .zero
        }
        
        let ballVelocity = ballPhysicsMotion.linearVelocity
        
        // Transfer velocity from racket to ball
        let velocityTransfer = racketVelocity * velocityTransferCoefficient
        let newVelocity = ballVelocity + velocityTransfer
        
        ballPhysicsMotion.linearVelocity = newVelocity
        ball.components[PhysicsMotionComponent.self] = ballPhysicsMotion
        
        // Clamp velocity to prevent unrealistic speeds
        clampBallVelocity(ball: ball)
        
        // Play ball hit sound at collision position
        audioManager.playBallHitSound(at: ball.position)
        
        // Record hit in game manager
        gameManager?.recordHit()
    }
    
    /// Handles collision between ball and ground
    /// Ends the game
    /// - Parameters:
    ///   - ball: The ball entity
    ///   - ground: The ground entity
    func handleBallGroundCollision(ball: Entity, ground: Entity) {
        // Stop ball physics
        if var physicsMotion = ball.components[PhysicsMotionComponent.self] {
            physicsMotion.linearVelocity = .zero
            physicsMotion.angularVelocity = .zero
            ball.components[PhysicsMotionComponent.self] = physicsMotion
        }
        
        // Play game over sound
        audioManager.playGameOverSound()
        
        // Notify game manager
        gameManager?.handleGroundCollision()
    }
    
    // MARK: - Helper Methods
    
    /// Reflects a velocity vector off a surface with the given normal
    /// - Parameters:
    ///   - velocity: The incoming velocity vector
    ///   - surfaceNormal: The surface normal vector (should be normalized)
    ///   - restitution: The restitution coefficient (0 = no bounce, 1 = perfect bounce)
    /// - Returns: The reflected velocity vector
    private func reflectVelocity(
        velocity: SIMD3<Float>,
        surfaceNormal: SIMD3<Float>,
        restitution: Float
    ) -> SIMD3<Float> {
        // Decompose velocity into normal and tangential components
        let velocityDotNormal = dot(velocity, surfaceNormal)
        let normalComponent = surfaceNormal * velocityDotNormal
        let tangentialComponent = velocity - normalComponent
        
        // Reflect normal component with restitution
        let reflectedNormal = -normalComponent * restitution
        
        // Combine reflected normal with preserved tangential component
        return tangentialComponent + reflectedNormal
    }
    
    /// Clamps the ball's velocity to the maximum allowed velocity
    /// - Parameter ball: The ball entity
    private func clampBallVelocity(ball: Entity) {
        guard var physicsMotion = ball.components[PhysicsMotionComponent.self] else {
            return
        }
        
        let velocity = physicsMotion.linearVelocity
        let speed = length(velocity)
        
        if speed > configuration.maxBallVelocity {
            let direction = normalize(velocity)
            physicsMotion.linearVelocity = direction * configuration.maxBallVelocity
            ball.components[PhysicsMotionComponent.self] = physicsMotion
        }
    }
    
    /// Processes a collision event and routes it to the appropriate handler
    /// - Parameter event: The collision event from RealityKit
    func handleCollisionEvent(_ event: CollisionEvents.Began) {
        let entityA = event.entityA
        let entityB = event.entityB
        
        // Determine which entities are involved
        let ballEntity: Entity?
        let otherEntity: Entity?
        
        if entityA.name == CollisionType.ball.rawValue {
            ballEntity = entityA
            otherEntity = entityB
        } else if entityB.name == CollisionType.ball.rawValue {
            ballEntity = entityB
            otherEntity = entityA
        } else {
            // No ball involved, ignore
            return
        }
        
        guard let ball = ballEntity, let other = otherEntity else {
            return
        }
        
        // Route to appropriate handler based on collision type
        switch other.name {
        case CollisionType.table.rawValue:
            handleBallTableCollision(ball: ball, table: other)
            
        case CollisionType.wall.rawValue:
            handleBallWallCollision(ball: ball, wall: other)
            
        case CollisionType.racket.rawValue:
            handleBallRacketCollision(ball: ball, racket: other)
            
        case CollisionType.ground.rawValue:
            handleBallGroundCollision(ball: ball, ground: other)
            
        default:
            break
        }
    }
}
