//
//  HandTrackingManager.swift
//  VOS_PingPong
//
//  Manages hand tracking using ARKit hand anchors
//

import Foundation
import ARKit
import RealityKit
import Observation

/// Manages hand tracking for racket control
@MainActor
@Observable
class HandTrackingManager {
    // MARK: - Properties
    
    /// Whether hand tracking is currently active
    var isTrackingActive: Bool = false
    
    /// Current hand transform (position and orientation)
    var handTransform: Transform?
    
    /// Whether tracking was lost during active gameplay
    var trackingLost: Bool = false
    
    /// ARKit session for hand tracking
    private var arSession: ARKitSession?
    
    /// Hand tracking provider
    private var handTracking: HandTrackingProvider?
    
    /// Reference to game manager for pause/resume functionality
    private weak var gameManager: GameManager?
    
    // MARK: - Initialization
    
    init(gameManager: GameManager? = nil) {
        self.gameManager = gameManager
    }
    
    /// Sets the game manager reference
    /// - Parameter gameManager: The game manager to control
    func setGameManager(_ gameManager: GameManager) {
        self.gameManager = gameManager
    }
    
    // MARK: - Methods
    
    /// Starts hand tracking
    func startTracking() async {
        // Check if hand tracking is supported
        guard HandTrackingProvider.isSupported else {
            print("Hand tracking is not supported on this device")
            isTrackingActive = false
            return
        }
        
        do {
            // Create ARKit session
            let session = ARKitSession()
            let handTrackingProvider = HandTrackingProvider()
            
            // Request authorization
            print("Requesting hand tracking authorization...")
            
            // Run the session with hand tracking
            try await session.run([handTrackingProvider])
            
            self.arSession = session
            self.handTracking = handTrackingProvider
            self.isTrackingActive = true
            
            print("Hand tracking started successfully")
            
            // Start monitoring hand anchors
            await monitorHandAnchors()
            
        } catch {
            print("Failed to start hand tracking: \(error)")
            isTrackingActive = false
        }
    }
    
    /// Stops hand tracking
    func stopTracking() {
        arSession?.stop()
        arSession = nil
        handTracking = nil
        handTransform = nil
        isTrackingActive = false
        print("Hand tracking stopped")
    }
    
    /// Gets the current hand transform
    /// - Returns: The current hand transform, or nil if not available
    func getHandTransform() -> Transform? {
        return handTransform
    }
    
    // MARK: - Private Methods
    
    /// Monitors hand anchor updates
    private func monitorHandAnchors() async {
        guard let handTracking = handTracking else { return }
        
        // Monitor hand anchor updates
        for await update in handTracking.anchorUpdates {
            switch update.event {
            case .added, .updated:
                // Get the hand anchor (using right hand by default)
                let anchor = update.anchor
                
                // We'll use the wrist position as the racket position
                // Get the wrist joint
                if let wristJoint = anchor.handSkeleton?.joint(.wrist) {
                    // Get the transform from the anchor's origin transform and joint transform
                    let anchorTransform = Transform(matrix: anchor.originFromAnchorTransform)
                    let jointTransform = Transform(matrix: wristJoint.anchorFromJointTransform)
                    
                    // Combine transforms
                    let worldTransform = anchorTransform * jointTransform
                    
                    // Update hand transform
                    self.handTransform = worldTransform
                    
                    // If tracking was previously lost and is now restored, resume the game
                    if trackingLost {
                        trackingLost = false
                        gameManager?.resumeGame()
                        print("Hand tracking restored - game resumed")
                    }
                    
                    // Ensure tracking is marked as active
                    if !self.isTrackingActive {
                        self.isTrackingActive = true
                    }
                }
                
            case .removed:
                // Hand tracking lost
                self.handTransform = nil
                let wasActive = self.isTrackingActive
                self.isTrackingActive = false
                
                // If tracking was active during gameplay, pause the game
                if wasActive {
                    trackingLost = true
                    gameManager?.pauseGame()
                    print("Hand tracking lost - game paused")
                }
            }
        }
    }
}

// MARK: - Transform Extension

extension Transform {
    /// Creates a Transform from a 4x4 matrix
    init(matrix: simd_float4x4) {
        self.init()
        self.matrix = matrix
    }
    
    /// Combines two transforms
    static func * (lhs: Transform, rhs: Transform) -> Transform {
        var result = Transform()
        result.matrix = lhs.matrix * rhs.matrix
        return result
    }
}
