#!/usr/bin/env swift
//
//  RunBoundaryTests.swift
//  VOS_PingPongTests
//
//  Runner for boundary enforcement property tests
//

import Foundation

// Execute the boundary tests
let task = Process()
task.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
task.arguments = ["VOS_PingPongTests/BoundaryTests.swift"]

do {
    try task.run()
    task.waitUntilExit()
    
    let exitCode = task.terminationStatus
    exit(exitCode)
} catch {
    print("Error running boundary tests: \(error)")
    exit(1)
}
