//
//  TableEntity.swift
//  VOS_PingPong
//
//  Represents the table surface with collision detection
//

import Foundation
import RealityKit

/// Entity representing the ping pong table surface
class TableEntity: Entity {
    
    // MARK: - Initialization
    
    /// Creates a table entity at the specified position with the given size
    /// - Parameters:
    ///   - position: The position in 3D space where the table should be placed
    ///   - size: The dimensions of the table (length x height x width)
    init(at position: SIMD3<Float>, size: SIMD3<Float>) {
        super.init()
        
        // Set the position
        self.position = position
        
        // Create the mesh for the table (box shape)
        let mesh = MeshResource.generateBox(size: size)
        
        // Create a material for the table (green surface like a real table tennis table)
        var material = SimpleMaterial()
        material.color = .init(tint: .green, texture: nil)
        material.roughness = .float(0.8)
        material.metallic = .float(0.1)
        
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
        
        // Add PhysicsBodyComponent with static mode (table doesn't move)
        self.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(
            massProperties: .default,
            mode: .static
        )
        
        // Set the collision type name for identification
        self.name = CollisionType.table.rawValue
    }
    
    @MainActor required init() {
        fatalError("init() has not been implemented. Use init(at:size:) instead.")
    }
    
    // MARK: - Factory Method
    
    /// Creates a table entity using the game configuration
    /// - Parameter configuration: The game configuration containing table size and position
    /// - Returns: A configured TableEntity
    static func create(with configuration: GameConfiguration) -> TableEntity {
        return TableEntity(
            at: configuration.tablePosition,
            size: configuration.tableSize
        )
    }
}
