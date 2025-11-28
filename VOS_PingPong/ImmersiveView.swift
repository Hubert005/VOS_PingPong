//
//  ImmersiveView.swift
//  VOS_PingPong
//
//  Created by Elias on 21.11.25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @Environment(AppModel.self) var appModel
    
    // Game components
    @State private var handTrackingManager: HandTrackingManager?
    @State private var audioManager = AudioManager()
    @State private var collisionHandler: CollisionHandler?
    @State private var collisionSubscription: EventSubscription?
    @State private var ball: BallEntity?
    @State private var racket: RacketEntity?
    
    // Use shared game manager from AppModel
    private var gameManager: GameManager {
        appModel.gameManager
    }

    var body: some View {
        RealityView { content, attachments in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                content.add(immersiveContentEntity)
            }
            
            // Create game configuration
            let configuration = GameConfiguration()
            
            // Initialize collision handler with audio manager
            let handler = CollisionHandler(configuration: configuration, gameManager: gameManager, audioManager: audioManager)
            collisionHandler = handler
            
            // Create game entities
            let table = TableEntity.create(with: configuration)
            let wall = WallEntity.create(with: configuration)
            let ballEntity = BallEntity.create(with: configuration)
            let ground = GroundEntity.create(with: configuration)
            let racketEntity = RacketEntity.create()
            
            // Store references for updates
            ball = ballEntity
            racket = racketEntity
            
            // Add entities to the scene
            content.add(table)
            content.add(wall)
            content.add(ballEntity)
            content.add(ground)
            content.add(racketEntity)
            
            // Initialize hand tracking manager
            let handTracking = HandTrackingManager(gameManager: gameManager)
            handTrackingManager = handTracking
            
            // Start hand tracking
            Task {
                await handTracking.startTracking()
            }
            
            // Add score display attachment
            if let scoreAttachment = attachments.entity(for: "scoreDisplay") {
                // Position the score display in the upper field of view
                // Place it 1.5 meters in front and 0.5 meters above the player
                scoreAttachment.position = SIMD3<Float>(0, 0.5, -1.5)
                content.add(scoreAttachment)
            }
            
            // Subscribe to collision events
            let subscription = content.subscribe(to: CollisionEvents.Began.self) { event in
                Task { @MainActor in
                    handler.handleCollisionEvent(event)
                }
            }
            collisionSubscription = subscription
            
            // Start the game
            gameManager.startGame()
        } update: { content, attachments in
            // Update racket position from hand tracking
            if let handTracking = handTrackingManager,
               let racket = racket,
               let handTransform = handTracking.getHandTransform() {
                racket.updatePosition(from: handTransform)
            }
            
            // Update loop for boundary checking and velocity clamping
            if let ball = ball, gameManager.isGameActive {
                // Check and reposition ball if out of bounds
                ball.repositionIfOutOfBounds()
                
                // Clamp ball velocity to prevent unrealistic behavior
                let configuration = GameConfiguration()
                ball.clampVelocity(max: configuration.maxBallVelocity)
            }
            
            // Update score display attachment position if needed
            if let scoreAttachment = attachments.entity(for: "scoreDisplay") {
                // Keep the score display in the upper field of view
                scoreAttachment.position = SIMD3<Float>(0, 0.5, -1.5)
            }
            
            // Update game over view attachment position if needed
            if let gameOverAttachment = attachments.entity(for: "gameOverView") {
                // Position the game over view in the center of the field of view
                gameOverAttachment.position = SIMD3<Float>(0, 0, -1.5)
            }
            
            // Update tracking lost view attachment position if needed
            if let trackingLostAttachment = attachments.entity(for: "trackingLostView") {
                // Position the tracking lost view in the center of the field of view
                trackingLostAttachment.position = SIMD3<Float>(0, 0, -1.5)
            }
        } attachments: {
            Attachment(id: "scoreDisplay") {
                ScoreDisplayView(
                    score: gameManager.score,
                    consecutiveHits: gameManager.consecutiveHits,
                    gameState: gameManager.gameState
                )
            }
            
            // Game Over View - only shown when game state is .gameOver
            if gameManager.gameState == .gameOver {
                Attachment(id: "gameOverView") {
                    GameOverView(finalScore: gameManager.score) {
                        // Reset the game and restart
                        gameManager.resetGame()
                        
                        // Reset the ball position
                        if let ball = ball {
                            let configuration = GameConfiguration()
                            ball.reset(to: configuration.ballStartPosition)
                        }
                        
                        // Start a new game
                        gameManager.startGame()
                    }
                }
            }
            
            // Tracking Lost View - only shown when hand tracking is lost during gameplay
            if let handTracking = handTrackingManager, handTracking.trackingLost {
                Attachment(id: "trackingLostView") {
                    TrackingLostView()
                }
            }
        }
        .onDisappear {
            // Clean up hand tracking when view disappears
            handTrackingManager?.stopTracking()
        }
    }
}

#Preview(immersionStyle: .progressive) {
    ImmersiveView()
        .environment(AppModel())
}
