//
//  EntityTests.swift
//  VOS_PingPongTests
//
//  Property-based tests for game entities (Table, Wall)
//

import Foundation
import Testing
import RealityKit
@testable import VOS_PingPong

@Suite("Entity Property Tests")
@MainActor
struct EntityTests {
    
    // MARK: - Property 1: Wall positioning relative to table
    // Feature: ar-pingpong-game, Property 1: Wall positioning relative to table
    // Validates: Requirements 1.2
    
    @Test("Property 1: Wall positioning relative to table")
    func testWallPositioningRelativeToTable() throws {
        try PropertyTestHelper.runPropertyTest(iterations: 100) {
            // Generate random table configuration
            let tableLength = PropertyGenerator.randomFloat(min: 2.0, max: 3.5)
            let tableWidth = PropertyGenerator.randomFloat(min: 1.0, max: 2.0)
            let tableHeight = PropertyGenerator.randomFloat(min: 0.5, max: 1.0)
            let tableSize = SIMD3<Float>(tableLength, tableHeight, tableWidth)
            
            let tableX = PropertyGenerator.randomFloat(min: -2.0, max: 2.0)
            let tableY = PropertyGenerator.randomFloat(min: 0.5, max: 1.5)
            let tableZ = PropertyGenerator.randomFloat(min: -3.0, max: -1.0)
            let tablePosition = SIMD3<Float>(tableX, tableY, tableZ)
            
            // Generate wall configuration
            let wallWidth = tableWidth // Wall width should match table width
            let wallHeight = PropertyGenerator.randomFloat(min: 0.8, max: 1.5)
            let wallThickness = PropertyGenerator.randomFloat(min: 0.03, max: 0.1)
            let wallSize = SIMD3<Float>(wallWidth, wallHeight, wallThickness)
            
            // Wall should be at one end of the table
            // Position it at the far end (negative Z direction)
            let wallPosition = SIMD3<Float>(
                tableX, // Same X as table (centered)
                tableY + tableHeight / 2 + wallHeight / 2, // Above table surface
                tableZ - tableLength / 2 - wallThickness / 2 // At the end of table
            )
            
            // Create configuration
            let config = GameConfiguration(
                tableSize: tableSize,
                wallSize: wallSize,
                tablePosition: tablePosition,
                wallPosition: wallPosition
            )
            
            // Create entities
            let table = TableEntity.create(with: config)
            let wall = WallEntity.create(with: config)
            
            // Verify wall is positioned at one end of the table
            let tableEndZ = table.position.z - tableSize.x / 2
            let wallZ = wall.position.z
            
            // Wall should be at the end of the table (within tolerance)
            let tolerance: Float = 0.1
            #expect(
                abs(wallZ - tableEndZ) < tolerance,
                "Wall should be positioned at the end of the table"
            )
            
            // Wall should be centered horizontally with the table
            #expect(
                abs(wall.position.x - table.position.x) < tolerance,
                "Wall should be horizontally centered with the table"
            )
            
            // Wall should be vertical (perpendicular to table)
            // This is verified by checking that the wall's Y position is above the table
            #expect(
                wall.position.y > table.position.y,
                "Wall should be positioned above the table surface"
            )
        }
    }
    
    // MARK: - Property 2: Table horizontal alignment
    // Feature: ar-pingpong-game, Property 2: Table horizontal alignment
    // Validates: Requirements 1.3
    
    @Test("Property 2: Table horizontal alignment")
    func testTableHorizontalAlignment() throws {
        try PropertyTestHelper.runPropertyTest(iterations: 100) {
            // Generate random table configuration
            let tableSize = SIMD3<Float>(
                PropertyGenerator.randomFloat(min: 2.0, max: 3.5),
                PropertyGenerator.randomFloat(min: 0.5, max: 1.0),
                PropertyGenerator.randomFloat(min: 1.0, max: 2.0)
            )
            
            let tablePosition = SIMD3<Float>(
                PropertyGenerator.randomFloat(min: -2.0, max: 2.0),
                PropertyGenerator.randomFloat(min: 0.5, max: 1.5),
                PropertyGenerator.randomFloat(min: -3.0, max: -1.0)
            )
            
            let config = GameConfiguration(
                tableSize: tableSize,
                tablePosition: tablePosition
            )
            
            // Create table entity
            let table = TableEntity.create(with: config)
            
            // Get the table's transform
            let transform = table.transform
            
            // The table's up vector should align with world up (Y-axis)
            // In RealityKit, the default orientation has Y-axis pointing up
            // We check that the table hasn't been rotated
            let worldUp = SIMD3<Float>(0, 1, 0)
            let tableUp = transform.matrix.columns.1 // Y column of transform matrix
            let tableUpNormalized = normalize(SIMD3<Float>(tableUp.x, tableUp.y, tableUp.z))
            
            // Calculate dot product to check alignment
            let dotProduct = dot(tableUpNormalized, worldUp)
            
            // Dot product should be close to 1.0 (vectors pointing same direction)
            let tolerance: Float = 0.01
            #expect(
                abs(dotProduct - 1.0) < tolerance,
                "Table's up vector should align with world up vector (Y-axis)"
            )
        }
    }
    
    // MARK: - Property 3: Entity dimensions match specifications
    // Feature: ar-pingpong-game, Property 3: Entity dimensions match specifications
    // Validates: Requirements 1.4
    
    @Test("Property 3: Entity dimensions match specifications")
    func testEntityDimensionsMatchSpecifications() throws {
        try PropertyTestHelper.runPropertyTest(iterations: 100) {
            // Generate random but valid table tennis dimensions
            // Standard table: 2.74m x 1.525m, but we'll test with variations
            let tableLength = PropertyGenerator.randomFloat(min: 2.5, max: 3.0)
            let tableHeight = PropertyGenerator.randomFloat(min: 0.7, max: 0.85)
            let tableWidth = PropertyGenerator.randomFloat(min: 1.4, max: 1.7)
            let tableSize = SIMD3<Float>(tableLength, tableHeight, tableWidth)
            
            // Wall dimensions
            let wallWidth = PropertyGenerator.randomFloat(min: 1.4, max: 1.7)
            let wallHeight = PropertyGenerator.randomFloat(min: 0.9, max: 1.2)
            let wallThickness = PropertyGenerator.randomFloat(min: 0.04, max: 0.06)
            let wallSize = SIMD3<Float>(wallWidth, wallHeight, wallThickness)
            
            let config = GameConfiguration(
                tableSize: tableSize,
                wallSize: wallSize
            )
            
            // Create entities
            let table = TableEntity.create(with: config)
            let wall = WallEntity.create(with: config)
            
            // Get the model components
            guard let tableModel = table.components[ModelComponent.self],
                  let wallModel = wall.components[ModelComponent.self] else {
                Issue.record("Entities should have ModelComponent")
                return
            }
            
            // Get the mesh bounds
            let tableBounds = tableModel.mesh.bounds
            let wallBounds = wallModel.mesh.bounds
            
            // Calculate actual dimensions from bounds
            let tableActualSize = tableBounds.extents
            let wallActualSize = wallBounds.extents
            
            // Verify dimensions match specifications (within tolerance)
            let tolerance: Float = 0.01
            
            #expect(
                abs(tableActualSize.x - tableSize.x) < tolerance &&
                abs(tableActualSize.y - tableSize.y) < tolerance &&
                abs(tableActualSize.z - tableSize.z) < tolerance,
                "Table dimensions should match specified size"
            )
            
            #expect(
                abs(wallActualSize.x - wallSize.x) < tolerance &&
                abs(wallActualSize.y - wallSize.y) < tolerance &&
                abs(wallActualSize.z - wallSize.z) < tolerance,
                "Wall dimensions should match specified size"
            )
        }
    }
}
