//
//  GroundEntity.swift
//  VOS_PingPong
//
//  Represents the ground plane for collision detection
//

import Foundation
import RealityKit

/// Entity representing the ground plane at floor level
/// Used to detect when the ball hits the ground and trigger game over
class GroundEntity: Entity {
    
    // MARK: - Properties
    
    /// Configuration for ground level
    private let configuration: GameConfiguration
    
    // MARK: - Initialization
    
    /// Creates a ground entity at the specified level
    /// - Parameters:
    ///   - groundLevel: The Y-coordinate of the ground plane
    ///   - configuration: Game configuration for ground properties
    init(at groundLevel: Float, configuration: GameConfiguration) {
        self.configuration = configuration
        super.init()
        
        // Position the ground plane at the specified level
        self.position = SIMD3<Float>(0, groundLevel, 0)
        
        // Create a large horizontal plane for ground collision detection
        // Make it large enough to cover the entire play area
        let planeSize: Float = 20.0 // 20m x 20m plane
        let planeThickness: Float = 0.01 // Very thin plane
        
        // Create collision shape for the ground (large horizontal box)
        let shape = ShapeResource.generateBox(
            width: planeSize,
            height: planeThickness,
            depth: planeSize
        )
        
        // Add CollisionComponent with trigger mode
        // We use trigger mode so the ball passes through but we still detect collision
        self.components[CollisionComponent.self] = CollisionComponent(
            shapes: [shape],
            mode: .trigger,
            filter: CollisionFilter(group: .all, mask: .all)
        )
        
        // No physics body needed - ground is static and invisible
        // We only need collision detection
        
        // Set the collision type name for identification
        self.name = CollisionType.ground.rawValue
    }
    
    @MainActor required init() {
        fatalError("init() has not been implemented. Use init(at:configuration:) instead.")
    }
    
    // MARK: - Factory Method
    
    /// Creates a ground entity using the game configuration
    /// - Parameter configuration: The game configuration containing ground level
    /// - Returns: A configured GroundEntity
    static func create(with configuration: GameConfiguration) -> GroundEntity {
        return GroundEntity(
            at: configuration.groundLevel,
            configuration: configuration
        )
    }
    
    // MARK: - Collision Detection Helper
    
    /// Checks if a given Y-coordinate is at or below ground level
    /// - Parameter yPosition: The Y-coordinate to check
    /// - Returns: True if the position is at or below ground level
    func isAtGroundLevel(_ yPosition: Float) -> Bool {
        return yPosition <= configuration.groundLevel
    }
}
