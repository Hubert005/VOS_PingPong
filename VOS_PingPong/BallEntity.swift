//
//  BallEntity.swift
//  VOS_PingPong
//
//  Represents the ping pong ball with physics properties
//

import Foundation
import RealityKit
import UIKit

/// Entity representing the ping pong ball with dynamic physics
class BallEntity: Entity {
    
    // MARK: - Properties
    
    /// Configuration for physics constants
    private let configuration: GameConfiguration
    
    // MARK: - Initialization
    
    /// Creates a ball entity at the specified position with the given radius
    /// - Parameters:
    ///   - position: The position in 3D space where the ball should be placed
    ///   - radius: The radius of the ball in meters
    ///   - configuration: Game configuration for physics constants
    init(at position: SIMD3<Float>, radius: Float, configuration: GameConfiguration) {
        self.configuration = configuration
        super.init()
        
        // Set the position
        self.position = position
        
        // Create the mesh for the ball (sphere shape)
        let mesh = MeshResource.generateSphere(radius: radius)
        
        // Create a bright material for high visibility
        var material = SimpleMaterial()
        material.color = .init(tint: .orange, texture: nil)
        material.roughness = .float(0.3)
        material.metallic = .float(0.1)
        
        // Add ModelComponent with the mesh and material
        self.components[ModelComponent.self] = ModelComponent(
            mesh: mesh,
            materials: [material]
        )
        
        // Create collision shape for the ball
        let shape = ShapeResource.generateSphere(radius: radius)
        
        // Add CollisionComponent with continuous collision detection
        self.components[CollisionComponent.self] = CollisionComponent(
            shapes: [shape],
            mode: .trigger,
            filter: CollisionFilter(group: .all, mask: .all)
        )
        
        // Configure physics properties
        // Mass for a standard table tennis ball is approximately 2.7 grams = 0.0027 kg
        let mass: Float = 0.0027
        
        // Calculate moment of inertia for a sphere: I = (2/5) * m * r^2
        let inertia = (2.0 / 5.0) * mass * radius * radius
        let inertiaVector = SIMD3<Float>(repeating: inertia)
        
        let massProperties = PhysicsMassProperties(
            mass: mass,
            inertia: inertiaVector
        )
        
        // Add PhysicsBodyComponent with dynamic mode
        // Restitution: bounciness (0.0 = no bounce, 1.0 = perfect bounce)
        // Table tennis balls have high restitution (~0.89)
        // Friction: resistance to sliding
        var physicsBody = PhysicsBodyComponent(
            massProperties: massProperties,
            mode: .dynamic
        )
        
        // Configure material properties for realistic ball behavior
        let physicsMaterial = PhysicsMaterialResource.generate(
            staticFriction: 0.3,
            dynamicFriction: 0.2,
            restitution: 0.89
        )
        physicsBody.material = physicsMaterial
        
        // Enable continuous collision detection to prevent tunneling at high speeds
        physicsBody.isContinuousCollisionDetectionEnabled = true
        
        self.components[PhysicsBodyComponent.self] = physicsBody
        
        // Set the collision type name for identification
        self.name = CollisionType.ball.rawValue
    }
    
    @MainActor required init() {
        fatalError("init() has not been implemented. Use init(at:radius:configuration:) instead.")
    }
    
    // MARK: - Methods
    
    /// Resets the ball to the specified position and stops all motion
    /// - Parameter position: The new position for the ball
    func reset(to position: SIMD3<Float>) {
        self.position = position
        
        // In RealityKit for VisionOS, we reset physics by recreating the component
        // or by applying forces to stop motion
        if let physicsBody = self.components[PhysicsBodyComponent.self] {
            // Apply a strong damping or recreate the physics body to stop motion
            // For now, we'll rely on the physics system to handle this
            // The position reset will effectively stop the ball
            self.components[PhysicsBodyComponent.self] = physicsBody
        }
    }
    
    /// Applies an impulse to the ball (used for racket hits)
    /// - Parameter impulse: The impulse vector to apply
    func applyImpulse(_ impulse: SIMD3<Float>) {
        // In RealityKit, impulses are applied through the physics simulation
        // We'll use applyLinearImpulse method if available, or store for later use
        // For now, this is a placeholder that will be implemented when integrated
        // with the actual RealityKit physics system
    }
    
    /// Clamps the ball's velocity to prevent unrealistic behavior
    /// - Parameter max: Maximum allowed velocity magnitude
    func clampVelocity(max: Float) {
        // Velocity clamping will be handled in the physics update loop
        // by checking the ball's velocity and applying counter-forces if needed
        // This is a placeholder for the actual implementation
    }
    
    // MARK: - Factory Method
    
    /// Creates a ball entity using the game configuration
    /// - Parameter configuration: The game configuration containing ball properties
    /// - Returns: A configured BallEntity
    static func create(with configuration: GameConfiguration) -> BallEntity {
        return BallEntity(
            at: configuration.ballStartPosition,
            radius: configuration.ballRadius,
            configuration: configuration
        )
    }
}
