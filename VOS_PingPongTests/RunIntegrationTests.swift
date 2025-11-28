#!/usr/bin/env swift

//
//  RunIntegrationTests.swift
//  VOS_PingPongTests
//
//  Standalone integration tests for complete game flow
//  Run with: swift VOS_PingPongTests/RunIntegrationTests.swift
//

import Foundation

// MARK: - Test Infrastructure

struct TestResult {
    let name: String
    let passed: Bool
    let message: String?
}

var testResults: [TestResult] = []
var totalAssertions = 0

func assert(_ condition: Bool, _ message: String, file: String = #file, line: Int = #line) {
    totalAssertions += 1
    if !condition {
        print("❌ Assertion failed at \(file):\(line): \(message)")
        testResults.append(TestResult(name: "Assertion", passed: false, message: message))
        exit(1)
    }
}

func runTest(name: String, test: () throws -> Void) {
    print("Running: \(name)")
    do {
        try test()
        testResults.append(TestResult(name: name, passed: true, message: nil))
        print("✅ PASSED: \(name)\n")
    } catch {
        testResults.append(TestResult(name: name, passed: false, message: error.localizedDescription))
        print("❌ FAILED: \(name) - \(error)\n")
    }
}

// MARK: - Game State

enum GameState {
    case idle
    case playing
    case paused
    case gameOver
}

// MARK: - GameManager (Simplified for testing)

class GameManager {
    var gameState: GameState = .idle
    var score: Int = 0
    var consecutiveHits: Int = 0
    
    var isGameActive: Bool {
        gameState == .playing
    }
    
    func startGame() {
        gameState = .playing
    }
    
    func endGame() {
        gameState = .gameOver
    }
    
    func pauseGame() {
        guard gameState == .playing else { return }
        gameState = .paused
    }
    
    func resumeGame() {
        guard gameState == .paused else { return }
        gameState = .playing
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

// MARK: - HandTrackingManager (Simplified for testing)

class HandTrackingManager {
    var isTrackingActive: Bool = false
    var trackingLost: Bool = false
    weak var gameManager: GameManager?
    
    init(gameManager: GameManager? = nil) {
        self.gameManager = gameManager
    }
    
    func simulateTrackingLoss() {
        isTrackingActive = false
        trackingLost = true
        gameManager?.pauseGame()
    }
    
    func simulateTrackingRestoration() {
        isTrackingActive = true
        trackingLost = false
        gameManager?.resumeGame()
    }
}

// MARK: - Integration Tests

print("========================================")
print("Integration Tests - Complete Game Flow")
print("========================================\n")

// Test 1: Complete game session from start to game over
runTest(name: "Complete game session from start to game over") {
    let gameManager = GameManager()
    
    // Verify initial state
    assert(gameManager.gameState == .idle, "Game should start in idle state")
    assert(gameManager.score == 0, "Initial score should be 0")
    assert(gameManager.consecutiveHits == 0, "Initial consecutive hits should be 0")
    
    // Start the game
    gameManager.startGame()
    assert(gameManager.gameState == .playing, "Game should be in playing state after start")
    assert(gameManager.isGameActive == true, "Game should be active")
    
    // Simulate gameplay: record several hits
    let numberOfHits = 10
    for i in 1...numberOfHits {
        gameManager.recordHit()
        assert(gameManager.consecutiveHits == i, "Consecutive hits should be \(i)")
        assert(gameManager.score == i, "Score should be \(i)")
        assert(gameManager.gameState == .playing, "Game should remain in playing state")
    }
    
    // Simulate ball hitting ground (game over)
    let finalScore = gameManager.score
    gameManager.handleGroundCollision()
    
    // Verify game over state
    assert(gameManager.gameState == .gameOver, "Game should be in gameOver state")
    assert(gameManager.isGameActive == false, "Game should not be active")
    assert(gameManager.consecutiveHits == 0, "Consecutive hits should be reset to 0")
    assert(gameManager.score == finalScore, "Score should be preserved")
}

// Test 2: Multiple consecutive games
runTest(name: "Multiple consecutive games") {
    let gameManager = GameManager()
    let numberOfGames = 5
    
    for gameNumber in 1...numberOfGames {
        // Start game
        gameManager.startGame()
        assert(gameManager.gameState == .playing, "Game \(gameNumber) should start in playing state")
        
        // Play game with random number of hits
        let hitsInThisGame = Int.random(in: 5...20)
        for _ in 1...hitsInThisGame {
            gameManager.recordHit()
        }
        
        assert(gameManager.consecutiveHits == hitsInThisGame, "Game \(gameNumber) should have \(hitsInThisGame) hits")
        
        // End game
        gameManager.handleGroundCollision()
        assert(gameManager.gameState == .gameOver, "Game \(gameNumber) should end in gameOver state")
        
        // Reset for next game
        gameManager.resetGame()
        assert(gameManager.gameState == .idle, "Game \(gameNumber) should reset to idle state")
        assert(gameManager.score == 0, "Score should be reset to 0 after game \(gameNumber)")
        assert(gameManager.consecutiveHits == 0, "Consecutive hits should be reset to 0 after game \(gameNumber)")
    }
}

// Test 3: Pause and resume functionality
runTest(name: "Pause and resume functionality") {
    let gameManager = GameManager()
    
    // Start game
    gameManager.startGame()
    assert(gameManager.gameState == .playing, "Game should be playing")
    
    // Record some hits
    gameManager.recordHit()
    gameManager.recordHit()
    gameManager.recordHit()
    let hitsBeforePause = gameManager.consecutiveHits
    let scoreBeforePause = gameManager.score
    
    assert(hitsBeforePause == 3, "Should have 3 hits before pause")
    
    // Pause the game
    gameManager.pauseGame()
    assert(gameManager.gameState == .paused, "Game should be paused")
    assert(gameManager.isGameActive == false, "Game should not be active when paused")
    
    // Try to record hits while paused (should not work)
    gameManager.recordHit()
    gameManager.recordHit()
    assert(gameManager.consecutiveHits == hitsBeforePause, "Hits should not be recorded while paused")
    assert(gameManager.score == scoreBeforePause, "Score should not change while paused")
    
    // Resume the game
    gameManager.resumeGame()
    assert(gameManager.gameState == .playing, "Game should be playing after resume")
    assert(gameManager.isGameActive == true, "Game should be active after resume")
    
    // Record more hits after resume
    gameManager.recordHit()
    gameManager.recordHit()
    assert(gameManager.consecutiveHits == hitsBeforePause + 2, "Hits should continue from where they left off")
    assert(gameManager.score == scoreBeforePause + 2, "Score should continue from where it left off")
}

// Test 4: Hand tracking integration with pause/resume
runTest(name: "Hand tracking loss triggers pause and restoration triggers resume") {
    let gameManager = GameManager()
    let handTrackingManager = HandTrackingManager(gameManager: gameManager)
    
    // Start game
    gameManager.startGame()
    assert(gameManager.gameState == .playing, "Game should be playing")
    
    // Simulate hand tracking active
    handTrackingManager.isTrackingActive = true
    
    // Record some hits
    gameManager.recordHit()
    gameManager.recordHit()
    let hitsBeforeTrackingLoss = gameManager.consecutiveHits
    
    // Simulate tracking loss
    handTrackingManager.simulateTrackingLoss()
    
    assert(gameManager.gameState == .paused, "Game should pause when tracking is lost")
    assert(handTrackingManager.trackingLost == true, "Tracking lost flag should be set")
    
    // Try to record hits while tracking is lost (should not work)
    gameManager.recordHit()
    assert(gameManager.consecutiveHits == hitsBeforeTrackingLoss, "Hits should not be recorded when tracking is lost")
    
    // Simulate tracking restoration
    handTrackingManager.simulateTrackingRestoration()
    
    assert(gameManager.gameState == .playing, "Game should resume when tracking is restored")
    
    // Record hits after restoration
    gameManager.recordHit()
    assert(gameManager.consecutiveHits == hitsBeforeTrackingLoss + 1, "Hits should continue after tracking restoration")
}

// Test 5: Edge case - rapid state transitions
runTest(name: "Edge case: rapid state transitions") {
    let gameManager = GameManager()
    
    // Rapid start/pause/resume/end cycles
    for _ in 1...10 {
        gameManager.startGame()
        assert(gameManager.gameState == .playing, "Should be playing")
        
        gameManager.pauseGame()
        assert(gameManager.gameState == .paused, "Should be paused")
        
        gameManager.resumeGame()
        assert(gameManager.gameState == .playing, "Should be playing again")
        
        gameManager.endGame()
        assert(gameManager.gameState == .gameOver, "Should be game over")
        
        gameManager.resetGame()
        assert(gameManager.gameState == .idle, "Should be idle")
    }
}

// Test 6: Edge case - operations in wrong state
runTest(name: "Edge case: operations in wrong state") {
    let gameManager = GameManager()
    
    // Try to pause when not playing
    gameManager.pauseGame()
    assert(gameManager.gameState == .idle, "Should remain idle when pausing from idle")
    
    // Try to resume when not paused
    gameManager.resumeGame()
    assert(gameManager.gameState == .idle, "Should remain idle when resuming from idle")
    
    // Try to record hits when not playing
    gameManager.recordHit()
    assert(gameManager.consecutiveHits == 0, "Should not record hits when not playing")
    
    // Try to handle ground collision when not playing
    gameManager.handleGroundCollision()
    assert(gameManager.gameState == .idle, "Should remain idle when handling collision from idle")
    
    // Start game, end it, then try operations
    gameManager.startGame()
    gameManager.endGame()
    
    gameManager.recordHit()
    assert(gameManager.consecutiveHits == 0, "Should not record hits when game is over")
    
    gameManager.pauseGame()
    assert(gameManager.gameState == .gameOver, "Should remain gameOver when pausing from gameOver")
}

// Test 7: Stress test - many hits in one game
runTest(name: "Stress test: many hits in one game") {
    let gameManager = GameManager()
    
    gameManager.startGame()
    
    let manyHits = 1000
    for i in 1...manyHits {
        gameManager.recordHit()
        
        // Verify state consistency (sample every 100 hits to avoid too much output)
        if i % 100 == 0 {
            assert(gameManager.consecutiveHits == i, "Consecutive hits should be \(i)")
            assert(gameManager.score == i, "Score should be \(i)")
            assert(gameManager.gameState == .playing, "Game should remain playing")
        }
    }
    
    // Final verification
    assert(gameManager.consecutiveHits == manyHits, "Final consecutive hits should be \(manyHits)")
    assert(gameManager.score == manyHits, "Final score should be \(manyHits)")
    
    // End game
    gameManager.handleGroundCollision()
    assert(gameManager.gameState == .gameOver, "Game should end")
    assert(gameManager.consecutiveHits == 0, "Consecutive hits should reset")
    assert(gameManager.score == manyHits, "Score should be preserved")
}

// Test 8: Integration - full game with state transitions
runTest(name: "Integration: full game with state transitions") {
    let gameManager = GameManager()
    
    // Start game
    gameManager.startGame()
    
    // Play several rounds with pauses
    for round in 1...5 {
        // Record some hits
        for _ in 1...3 {
            gameManager.recordHit()
        }
        
        // Pause and resume
        gameManager.pauseGame()
        assert(gameManager.gameState == .paused, "Game should be paused in round \(round)")
        
        gameManager.resumeGame()
        assert(gameManager.gameState == .playing, "Game should be playing in round \(round)")
        
        // Continue playing
        gameManager.recordHit()
    }
    
    // End game
    gameManager.handleGroundCollision()
    assert(gameManager.gameState == .gameOver, "Game should be over")
    assert(gameManager.score > 0, "Score should be greater than 0")
}

// Test 9: Game state consistency across operations
runTest(name: "Game state consistency across operations") {
    let gameManager = GameManager()
    
    // Test that score and hits are always consistent
    gameManager.startGame()
    
    for i in 1...50 {
        gameManager.recordHit()
        assert(gameManager.score == gameManager.consecutiveHits, "Score should always equal consecutive hits")
        assert(gameManager.score == i, "Score should be \(i)")
    }
    
    // Test that reset clears everything
    gameManager.resetGame()
    assert(gameManager.score == 0, "Score should be 0 after reset")
    assert(gameManager.consecutiveHits == 0, "Consecutive hits should be 0 after reset")
    assert(gameManager.gameState == .idle, "State should be idle after reset")
    
    // Test that ground collision preserves score but resets hits
    gameManager.startGame()
    for _ in 1...25 {
        gameManager.recordHit()
    }
    let scoreBeforeCollision = gameManager.score
    gameManager.handleGroundCollision()
    assert(gameManager.score == scoreBeforeCollision, "Score should be preserved after ground collision")
    assert(gameManager.consecutiveHits == 0, "Consecutive hits should be reset after ground collision")
}

// Test 10: Boundary conditions
runTest(name: "Boundary conditions") {
    let gameManager = GameManager()
    
    // Test with zero hits
    gameManager.startGame()
    gameManager.handleGroundCollision()
    assert(gameManager.score == 0, "Score should be 0 with no hits")
    
    // Test with exactly one hit
    gameManager.resetGame()
    gameManager.startGame()
    gameManager.recordHit()
    assert(gameManager.score == 1, "Score should be 1 with one hit")
    gameManager.handleGroundCollision()
    assert(gameManager.score == 1, "Score should remain 1 after game over")
    
    // Test multiple resets
    for _ in 1...10 {
        gameManager.resetGame()
        assert(gameManager.score == 0, "Score should be 0 after each reset")
        assert(gameManager.consecutiveHits == 0, "Hits should be 0 after each reset")
        assert(gameManager.gameState == .idle, "State should be idle after each reset")
    }
}

// MARK: - Print Summary

print("========================================")
print("Test Summary")
print("========================================\n")

let passedTests = testResults.filter { $0.passed }
let failedTests = testResults.filter { !$0.passed }

print("Total Tests: \(testResults.count)")
print("Passed: \(passedTests.count)")
print("Failed: \(failedTests.count)")
print("Total Assertions: \(totalAssertions)")
print("")

if failedTests.isEmpty {
    print("✅ All integration tests passed!")
    print("")
    print("Integration test coverage:")
    print("  ✅ Complete game session from start to game over")
    print("  ✅ Multiple consecutive games")
    print("  ✅ Pause and resume functionality")
    print("  ✅ Hand tracking integration")
    print("  ✅ Rapid state transitions")
    print("  ✅ Operations in wrong state")
    print("  ✅ Stress test with many hits")
    print("  ✅ Full game with state transitions")
    print("  ✅ Game state consistency")
    print("  ✅ Boundary conditions")
    exit(0)
} else {
    print("❌ Some tests failed:")
    for test in failedTests {
        print("  - \(test.name): \(test.message ?? "Unknown error")")
    }
    exit(1)
}
