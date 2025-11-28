#!/usr/bin/env swift
//
//  RunTests.swift
//  VOS_PingPongTests
//
//  Standalone test runner for property-based tests
//

import Foundation

// MARK: - Copy of GameState enum
enum GameState {
    case idle
    case playing
    case gameOver
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

// MARK: - Copy of GameManager class
@MainActor
class GameManager {
    var gameState: GameState = .idle
    var score: Int = 0
    var consecutiveHits: Int = 0
    
    var isGameActive: Bool {
        gameState == .playing
    }
    
    private let configuration: GameConfiguration
    
    init(configuration: GameConfiguration = GameConfiguration()) {
        self.configuration = configuration
    }
    
    func startGame() {
        gameState = .playing
    }
    
    func endGame() {
        gameState = .gameOver
    }
    
    func resetGame() {
        score = 0
        consecutiveHits = 0
        gameState = .idle
    }
    
    func recordHit() {
        guard isGameActive else { return }
        consecutiveHits += 1
        score = consecutiveHits
    }
    
    func handleGroundCollision() {
        guard isGameActive else { return }
        consecutiveHits = 0
        endGame()
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

// MARK: - Property Tests

@MainActor
func runAllTests() {
    print("=== Running GameManager Property Tests ===\n")
    
    // Property 15: Game reset restores initial state
    runTest(name: "Property 15: Game reset restores initial state") {
        for iteration in 0..<100 {
            let manager = GameManager()
            
            // Generate random state
            let randomScore = Int.random(in: 0...1000)
            let randomHits = Int.random(in: 0...100)
            let randomState = [GameState.idle, .playing, .gameOver].randomElement()!
            
            manager.score = randomScore
            manager.consecutiveHits = randomHits
            manager.gameState = randomState
            
            // Reset
            manager.resetGame()
            
            // Verify
            assert(manager.score == 0, "Score should be 0, got \(manager.score) at iteration \(iteration)", testName: "Property 15: Game reset restores initial state")
            assert(manager.consecutiveHits == 0, "Consecutive hits should be 0, got \(manager.consecutiveHits) at iteration \(iteration)", testName: "Property 15: Game reset restores initial state")
            assert(manager.gameState == .idle, "Game state should be idle at iteration \(iteration)", testName: "Property 15: Game reset restores initial state")
            assert(manager.isGameActive == false, "Game should not be active at iteration \(iteration)", testName: "Property 15: Game reset restores initial state")
        }
    }
    
    // Property 11: Score calculation from hits
    runTest(name: "Property 11: Score calculation from hits") {
        for iteration in 0..<100 {
            let manager = GameManager()
            manager.startGame()
            
            let numberOfHits = Int.random(in: 1...50)
            
            for _ in 0..<numberOfHits {
                manager.recordHit()
            }
            
            assert(manager.score == numberOfHits, "Score should be \(numberOfHits), got \(manager.score) at iteration \(iteration)", testName: "Property 11: Score calculation from hits")
            assert(manager.consecutiveHits == numberOfHits, "Consecutive hits should be \(numberOfHits), got \(manager.consecutiveHits) at iteration \(iteration)", testName: "Property 11: Score calculation from hits")
        }
    }
    
    // Property 14: Ground collision ends game
    runTest(name: "Property 14: Ground collision ends game") {
        for iteration in 0..<100 {
            let manager = GameManager()
            manager.startGame()
            
            let randomHits = Int.random(in: 1...100)
            for _ in 0..<randomHits {
                manager.recordHit()
            }
            
            let scoreBeforeCollision = manager.score
            
            manager.handleGroundCollision()
            
            assert(manager.gameState == .gameOver, "Game state should be gameOver at iteration \(iteration)", testName: "Property 14: Ground collision ends game")
            assert(manager.consecutiveHits == 0, "Consecutive hits should be 0, got \(manager.consecutiveHits) at iteration \(iteration)", testName: "Property 14: Ground collision ends game")
            assert(manager.isGameActive == false, "Game should not be active at iteration \(iteration)", testName: "Property 14: Ground collision ends game")
            assert(manager.score == scoreBeforeCollision, "Score should be preserved (\(scoreBeforeCollision)), got \(manager.score) at iteration \(iteration)", testName: "Property 14: Ground collision ends game")
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
await runAllTests()
