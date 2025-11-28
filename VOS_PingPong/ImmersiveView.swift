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
    @State private var gameManager = GameManager()
    @State private var audioManager = AudioManager()
    @State private var collisionHandler: CollisionHandler?
    @State private var collisionSubscription: EventSubscription?
    @State private var ball: BallEntity?

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
            let racket = RacketEntity.create()
            
            // Store ball reference for boundary checking
            ball = ballEntity
            
            // Add entities to the scene
            content.add(table)
            content.add(wall)
            content.add(ballEntity)
            content.add(ground)
            content.add(racket)
            
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
            // Update loop for boundary checking
            if let ball = ball, gameManager.isGameActive {
                ball.repositionIfOutOfBounds()
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
        }
    }
}

#Preview(immersionStyle: .progressive) {
    ImmersiveView()
        .environment(AppModel())
}
