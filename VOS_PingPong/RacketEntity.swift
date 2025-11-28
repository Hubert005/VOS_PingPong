//
//  RacketEntity.swift
//  VOS_PingPong
//
//  Represents the player's racket controlled by hand tracking
//

import Foundation
import RealityKit
import UIKit

/// Entity representing the player's table tennis racket
class RacketEntity: Entity {
    
    // MARK: - Properties
    
    /// Previous position for velocity calculation
    private var previousPosition: SIMD3<Float>
    
    /// Previous timestamp for velocity calculation
    private var previousTime: TimeInterval
    
    /// Current calculated velocity
    private(set) var velocity: SIMD3<Float> = .zero
    
    // MARK: - Initialization
    
    /// Creates a racket entity at the specified position
    /// - Parameter position: The initial position in 3D space
    init(at position: SIMD3<Float>) {
        self.previousPosition = position
        self.previousTime = Date().timeIntervalSince1970
        
        super.init()
        
        // Set the initial position
        self.position = position
        
        // Create the mesh for the racket (paddle shape)
        // Using a box to represent the paddle: width x thickness x height
        let paddleWidth: Float = 0.15  // 15cm wide
        let paddleThickness: Float = 0.01  // 1cm thick
        let paddleHeight: Float = 0.25  // 25cm tall
        
        let mesh = MeshResource.generateBox(
            size: SIMD3<Float>(paddleWidth, paddleHeight, paddleThickness)
        )
        
        // Create a material for the racket (red rubber surface)
        var material = SimpleMaterial()
        material.color = .init(tint: .red, texture: nil)
        material.roughness = .float(0.7)
        material.metallic = .float(0.0)
        
        // Add ModelComponent with the mesh and material
        self.components[ModelComponent.self] = ModelComponent(
            mesh: mesh,
            materials: [material]
        )
        
        // Create collision shape for the racket
        let shape = ShapeResource.generateBox(
            size: SIMD3<Float>(paddleWidth, paddleHeight, paddleThickness)
        )
        
        // Add CollisionComponent for ball collision detection
        self.components[CollisionComponent.self] = CollisionComponent(
            shapes: [shape],
            mode: .trigger,
            filter: CollisionFilter(group: .all, mask: .all)
        )
        
        // Set the collision type name for identification
        self.name = CollisionType.racket.rawValue
    }
    
    @MainActor required init() {
        fatalError("init() has not been implemented. Use init(at:) instead.")
    }
    
    // MARK: - Methods
    
    /// Updates the racket position from hand transform
    /// - Parameter handTransform: The transform from hand tracking
    func updatePosition(from handTransform: Transform) {
        // Store previous position and time for velocity calculation
        previousPosition = self.position
        previousTime = Date().timeIntervalSince1970
        
        // Update position from hand transform
        self.position = handTransform.translation
        
        // Update orientation from hand transform
        self.orientation = handTransform.rotation
        
        // Calculate velocity after position update
        calculateVelocity()
    }
    
    /// Calculates the racket's velocity based on position change
    /// - Returns: The velocity vector in m/s
    @discardableResult
    func calculateVelocity() -> SIMD3<Float> {
        let currentTime = Date().timeIntervalSince1970
        let deltaTime = Float(currentTime - previousTime)
        
        // Avoid division by zero
        guard deltaTime > 0.0001 else {
            velocity = .zero
            return velocity
        }
        
        // Calculate velocity: (current position - previous position) / time
        let displacement = self.position - previousPosition
        velocity = displacement / deltaTime
        
        return velocity
    }
    
    // MARK: - Factory Method
    
    /// Creates a racket entity at the default starting position
    /// - Returns: A configured RacketEntity
    static func create() -> RacketEntity {
        // Default position in front of the player
        let defaultPosition = SIMD3<Float>(0.3, 1.2, -0.5)
        return RacketEntity(at: defaultPosition)
    }
}
