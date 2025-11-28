//
//  GameConfiguration.swift
//  VOS_PingPong
//
//  Game configuration with table dimensions, physics constants, and positioning
//

import Foundation
import RealityKit

/// Configuration struct containing all game constants and positioning data
struct GameConfiguration {
    // MARK: - Table Dimensions (Standard Table Tennis)
    
    /// Table size in meters (length x width x height)
    /// Standard table tennis table: 2.74m x 1.525m x 0.76m
    let tableSize: SIMD3<Float>
    
    /// Wall size in meters (width x height x thickness)
    /// Wall at end of table: 1.525m x 1.0m x 0.05m
    let wallSize: SIMD3<Float>
    
    // MARK: - Ball Properties
    
    /// Ball radius in meters (40mm diameter = 0.02m radius)
    let ballRadius: Float
    
    // MARK: - Physics Constants
    
    /// Gravity vector in m/s² (Earth gravity: -9.81 m/s² on Y-axis)
    let gravity: SIMD3<Float>
    
    /// Maximum ball velocity in m/s to prevent unrealistic behavior
    let maxBallVelocity: Float
    
    // MARK: - Positioning
    
    /// Table position relative to player (in meters)
    let tablePosition: SIMD3<Float>
    
    /// Wall position at end of table (in meters)
    let wallPosition: SIMD3<Float>
    
    /// Ground level Y-coordinate threshold (in meters)
    /// Ball hitting this level triggers game over
    let groundLevel: Float
    
    // MARK: - Initialization
    
    /// Creates a game configuration with default values
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
    
    // MARK: - Computed Properties
    
    /// Starting position for the ball (above table center)
    var ballStartPosition: SIMD3<Float> {
        SIMD3<Float>(
            tablePosition.x,
            tablePosition.y + tableSize.y + ballRadius + 0.5,
            tablePosition.z
        )
    }
    
    /// Play area boundaries (min and max coordinates)
    var playAreaBounds: (min: SIMD3<Float>, max: SIMD3<Float>) {
        let margin: Float = 2.0
        let min = SIMD3<Float>(
            tablePosition.x - tableSize.x / 2 - margin,
            groundLevel,
            wallPosition.z - margin
        )
        let max = SIMD3<Float>(
            tablePosition.x + tableSize.x / 2 + margin,
            tablePosition.y + 3.0,
            tablePosition.z + tableSize.z / 2 + margin
        )
        return (min, max)
    }
}
