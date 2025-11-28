//
//  WallEntity.swift
//  VOS_PingPong
//
//  Represents the wall at the end of the table
//

import Foundation
import RealityKit
import UIKit

/// Entity representing the wall at the end of the ping pong table
class WallEntity: Entity {
    
    // MARK: - Initialization
    
    /// Creates a wall entity at the specified position with the given size
    /// - Parameters:
    ///   - position: The position in 3D space where the wall should be placed
    ///   - size: The dimensions of the wall (width x height x thickness)
    init(at position: SIMD3<Float>, size: SIMD3<Float>) {
        super.init()
        
        // Set the position
        self.position = position
        
        // Create the mesh for the wall (box shape)
        let mesh = MeshResource.generateBox(size: size)
        
        // Create a material for the wall (light gray/white surface)
        var material = SimpleMaterial()
        material.color = .init(tint: .white, texture: nil)
        material.roughness = .float(0.6)
        material.metallic = .float(0.0)
        
        // Add ModelComponent with the mesh and material
        self.components[ModelComponent.self] = ModelComponent(
            mesh: mesh,
            materials: [material]
        )
        
        // Add CollisionComponent with static physics body
        let shape = ShapeResource.generateBox(size: size)
        self.components[CollisionComponent.self] = CollisionComponent(
            shapes: [shape],
            mode: .default,
            filter: CollisionFilter(group: .all, mask: .all)
        )
        
        // Add PhysicsBodyComponent with static mode (wall doesn't move)
        self.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(
            massProperties: .default,
            mode: .static
        )
        
        // Set the collision type name for identification
        self.name = CollisionType.wall.rawValue
    }
    
    @MainActor required init() {
        fatalError("init() has not been implemented. Use init(at:size:) instead.")
    }
    
    // MARK: - Factory Method
    
    /// Creates a wall entity using the game configuration
    /// - Parameter configuration: The game configuration containing wall size and position
    /// - Returns: A configured WallEntity
    static func create(with configuration: GameConfiguration) -> WallEntity {
        return WallEntity(
            at: configuration.wallPosition,
            size: configuration.wallSize
        )
    }
}
