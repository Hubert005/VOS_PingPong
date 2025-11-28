#!/usr/bin/env swift
//
//  VerifyGroundDetection.swift
//  VOS_PingPongTests
//
//  Standalone test runner for ground detection property test
//

import Foundation

// MARK: - Copy of CollisionType enum
enum CollisionType: String {
    case ball = "ball"
    case racket = "racket"
    case table = "table"
    case wall = "wall"
    case ground = "ground"
}

// MARK: - Copy of GameConfiguration struct
struct GameConfiguration {
    let tableSize: SIMD3<Float>
    let wallSize: SIMD3<Float>
    let ballRadius: Float
    let gravity: SIMD3<Float>
    let maxBallVelocity: Float
    let tablePosition: SIMD3<Float>
    let wallPosition: SIMD3<Float>
    let groundLevel: Float
    
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
}

// MARK: - Simplified GroundEntity for testing
class GroundEntity {
    var position: SIMD3<Float>
    var name: String
    var hasCollisionComponent: Bool
    private let configuration: GameConfiguration
    
    init(at groundLevel: Float, configuration: GameConfiguration) {
        self.configuration = configuration
        self.position = SIMD3<Float>(0, groundLevel, 0)
        self.name = CollisionType.ground.rawValue
        self.hasCollisionComponent = true
    }
    
    static func create(with configuration: GameConfiguration) -> GroundEntity {
        return GroundEntity(
            at: configuration.groundLevel,
            configuration: configuration
        )
    }
    
    func isAtGroundLevel(_ yPosition: Float) -> Bool {
        return yPosition <= configuration.groundLevel
    }
}

// MARK: - Test Framework
struct TestResult {
    let name: String
    let passed: Bool
    let message: String?
}

var testResults: [TestResult] = []

func assert(_ condition: Bool, _ message: String, testName: String) {
    if !condition {
        testResults.append(TestResult(name: testName, passed: false, message: message))
        print("❌ FAILED: \(testName) - \(message)")
    }
}

func runTest(name: String, test: () -> Void) {
    print("Running: \(name)")
    test()
    if testResults.filter({ $0.name == name && !$0.passed }).isEmpty {
        testResults.append(TestResult(name: name, passed: true, message: nil))
        print("✅ PASSED: \(name)")
    }
}

// MARK: - Property 13: Ground collision detection
// Feature: ar-pingpong-game, Property 13: Ground collision detection
// Validates: Requirements 5.1

func runGroundDetectionTest() {
    print("=== Running Ground Detection Property Test ===\n")
    
    runTest(name: "Property 13: Ground collision detection") {
        for iteration in 0..<100 {
            // Generate random ground level
            let groundLevel = Float.random(in: -0.5...0.5)
            
            let config = GameConfiguration(groundLevel: groundLevel)
            
            // Create ground entity
            let ground = GroundEntity.create(with: config)
            
            // Verify ground is positioned at the correct level
            let tolerance: Float = 0.001
            assert(
                abs(ground.position.y - groundLevel) < tolerance,
                "Ground should be positioned at the specified ground level (expected: \(groundLevel), got: \(ground.position.y)) at iteration \(iteration)",
                testName: "Property 13: Ground collision detection"
            )
            
            // Verify ground has collision component
            assert(
                ground.hasCollisionComponent,
                "Ground should have a CollisionComponent for collision detection at iteration \(iteration)",
                testName: "Property 13: Ground collision detection"
            )
            
            // Verify ground is named correctly for identification
            assert(
                ground.name == CollisionType.ground.rawValue,
                "Ground should be named with the ground collision type at iteration \(iteration)",
                testName: "Property 13: Ground collision detection"
            )
            
            // Test the isAtGroundLevel helper method
            // Generate random Y positions and verify detection
            let numPositionTests = 10
            for posTest in 0..<numPositionTests {
                let testY = Float.random(in: (groundLevel - 2.0)...(groundLevel + 2.0))
                let shouldDetect = testY <= groundLevel
                let detected = ground.isAtGroundLevel(testY)
                
                assert(
                    detected == shouldDetect,
                    "isAtGroundLevel should return \(shouldDetect) for Y=\(testY) (groundLevel=\(groundLevel)) at iteration \(iteration), position test \(posTest)",
                    testName: "Property 13: Ground collision detection"
                )
            }
            
            // Specifically test boundary conditions
            assert(
                ground.isAtGroundLevel(groundLevel),
                "Position exactly at ground level (\(groundLevel)) should be detected at iteration \(iteration)",
                testName: "Property 13: Ground collision detection"
            )
            
            assert(
                ground.isAtGroundLevel(groundLevel - 0.001),
                "Position below ground level (\(groundLevel - 0.001)) should be detected at iteration \(iteration)",
                testName: "Property 13: Ground collision detection"
            )
            
            assert(
                !ground.isAtGroundLevel(groundLevel + 0.001),
                "Position above ground level (\(groundLevel + 0.001)) should not be detected at iteration \(iteration)",
                testName: "Property 13: Ground collision detection"
            )
        }
    }
    
    // Summary
    print("\n=== Test Summary ===")
    let passed = testResults.filter { $0.passed }.count
    let failed = testResults.filter { !$0.passed }.count
    print("Total: \(testResults.count)")
    print("Passed: \(passed)")
    print("Failed: \(failed)")
    
    if failed > 0 {
        print("\n❌ Some tests failed")
        exit(1)
    } else {
        print("\n✅ All tests passed!")
        exit(0)
    }
}

// Run tests
runGroundDetectionTest()
