//
//  PropertyTestHelper.swift
//  VOS_PingPongTests
//
//  Helper utilities for property-based testing
//

import Foundation
import Testing

/// Helper for running property-based tests with multiple iterations
struct PropertyTestHelper {
    /// Default number of iterations for property tests
    static let defaultIterations = 100
    
    /// Runs a property test with the specified number of iterations
    /// - Parameters:
    ///   - iterations: Number of test iterations (default: 100)
    ///   - test: The test closure to execute for each iteration
    static func runPropertyTest(
        iterations: Int = defaultIterations,
        test: () throws -> Void
    ) rethrows {
        for iteration in 0..<iterations {
            do {
                try test()
            } catch {
                Issue.record("Property test failed at iteration \(iteration + 1): \(error)")
                throw error
            }
        }
    }
}

/// Random value generators for property testing
enum PropertyGenerator {
    /// Generates a random integer in the specified range
    static func randomInt(min: Int = 0, max: Int = 100) -> Int {
        Int.random(in: min...max)
    }
    
    /// Generates a random float in the specified range
    static func randomFloat(min: Float = 0.0, max: Float = 1.0) -> Float {
        Float.random(in: min...max)
    }
    
    /// Generates a random boolean
    static func randomBool() -> Bool {
        Bool.random()
    }
    
    /// Generates a random game state
    static func randomGameState() -> GameState {
        [GameState.idle, .playing, .gameOver].randomElement()!
    }
}
