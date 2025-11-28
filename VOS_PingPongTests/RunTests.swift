//
//  RunTests.swift
//  VOS_PingPongTests
//
//  Simple test runner for property-based tests
//

import Foundation
import Testing
@testable import VOS_PingPong

@main
struct TestRunner {
    static func main() async {
        print("Running Property-Based Tests...")
        print("=" * 60)
        
        await runGameManagerTests()
        await runHandTrackingTests()
        
        print("\n" + "=" * 60)
        print("All tests completed!")
    }
    
    @MainActor
    static func runGameManagerTests() async {
        let tests = GameManagerTests()
        
        do {
            print("\n🧪 Testing Property 10: Hit counter increments on collision")
            try tests.testHitCounterIncrementsOnCollision()
            print("✅ PASSED: Hit counter increments correctly")
        } catch {
            print("❌ FAILED: \(error)")
        }
        
        do {
            print("\n🧪 Testing Property 11: Score calculation from hits")
            try tests.testScoreCalculationFromHits()
            print("✅ PASSED: Score calculation is correct")
        } catch {
            print("❌ FAILED: \(error)")
        }
        
        do {
            print("\n🧪 Testing Property 14: Ground collision ends game")
            try tests.testGroundCollisionEndsGame()
            print("✅ PASSED: Ground collision handling is correct")
        } catch {
            print("❌ FAILED: \(error)")
        }
        
        do {
            print("\n🧪 Testing Property 15: Game reset restores initial state")
            try tests.testGameResetRestoresInitialState()
            print("✅ PASSED: Game reset works correctly")
        } catch {
            print("❌ FAILED: \(error)")
        }
        
        do {
            print("\n🧪 Testing Property 12: UI state synchronization")
            try tests.testUIStateSynchronization()
            print("✅ PASSED: UI state synchronization works correctly")
        } catch {
            print("❌ FAILED: \(error)")
        }
    }
    
    @MainActor
    static func runHandTrackingTests() async {
        let tests = HandTrackingTests()
        
        do {
            print("\n🧪 Testing Property 18: Tracking loss pauses game")
            try tests.testTrackingLossPausesGame()
            print("✅ PASSED: Tracking loss pauses game correctly")
        } catch {
            print("❌ FAILED: \(error)")
        }
        
        do {
            print("\n🧪 Testing Property 19: Tracking restoration resumes game")
            try tests.testTrackingRestorationResumesGame()
            print("✅ PASSED: Tracking restoration resumes game correctly")
        } catch {
            print("❌ FAILED: \(error)")
        }
    }
}

extension String {
    static func * (left: String, right: Int) -> String {
        return String(repeating: left, count: right)
    }
}
