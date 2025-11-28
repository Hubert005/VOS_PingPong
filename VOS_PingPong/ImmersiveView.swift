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
        RealityView { content in
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
            
            // Subscribe to collision events
            let subscription = content.subscribe(to: CollisionEvents.Began.self) { event in
                Task { @MainActor in
                    handler.handleCollisionEvent(event)
                }
            }
            collisionSubscription = subscription
            
            // Start the game
            gameManager.startGame()
        } update: { content in
            // Update loop for boundary checking
            if let ball = ball, gameManager.isGameActive {
                ball.repositionIfOutOfBounds()
            }
        }
    }
}

#Preview(immersionStyle: .progressive) {
    ImmersiveView()
        .environment(AppModel())
}
