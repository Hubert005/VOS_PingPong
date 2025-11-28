//
//  RunHandTrackingTests.swift
//  VOS_PingPongTests
//
//  Runner for hand tracking property tests
//

import Foundation
import Testing
@testable import VOS_PingPong

/// Runner for hand tracking property tests
/// This file exists to ensure tests are discovered and run
@Suite("Hand Tracking Test Runner")
struct RunHandTrackingTests {
    @Test("Run all hand tracking property tests")
    func runAllHandTrackingTests() async throws {
        // Tests are automatically discovered and run by Swift Testing framework
        // This runner ensures the test suite is included in the test bundle
    }
}
