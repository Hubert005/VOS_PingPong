//
//  TestHandTracking.swift
//  VOS_PingPongTests
//
//  Standalone runner for hand tracking tests
//

import Foundation
@testable import VOS_PingPong

@main
@MainActor
struct TestHandTracking {
    static func main() async {
        print("Running Hand Tracking Property Tests...")
        print("=" * 60)
        
        let tests = HandTrackingTests()
        
        // Test Property 18
        do {
            print("\n🧪 Testing Property 18: Tracking loss pauses game")
            try tests.testTrackingLossPausesGame()
            print("✅ PASSED: Tracking loss pauses game correctly")
        } catch {
            print("❌ FAILED: \(error)")
        }
        
        // Test Property 19
        do {
            print("\n🧪 Testing Property 19: Tracking restoration resumes game")
            try tests.testTrackingRestorationResumesGame()
            print("✅ PASSED: Tracking restoration resumes game correctly")
        } catch {
            print("❌ FAILED: \(error)")
        }
        
        // Edge case tests
        do {
            print("\n🧪 Testing edge case: pauseGame only works when playing")
            tests.testPauseOnlyWorksWhenPlaying()
            print("✅ PASSED: Pause guard works correctly")
        } catch {
            print("❌ FAILED: \(error)")
        }
        
        do {
            print("\n🧪 Testing edge case: resumeGame only works when paused")
            tests.testResumeOnlyWorksWhenPaused()
            print("✅ PASSED: Resume guard works correctly")
        } catch {
            print("❌ FAILED: \(error)")
        }
        
        do {
            print("\n🧪 Testing edge case: game actions don't work when paused")
            tests.testGameActionsWhenPaused()
            print("✅ PASSED: Game actions blocked when paused")
        } catch {
            print("❌ FAILED: \(error)")
        }
        
        print("\n" + "=" * 60)
        print("All hand tracking tests completed!")
    }
}

extension String {
    static func * (left: String, right: Int) -> String {
        return String(repeating: left, count: right)
    }
}
