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
    @State private var collisionHandler: CollisionHandler?
    @State private var collisionSubscription: EventSubscription?

    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                content.add(immersiveContentEntity)
            }
            
            // Create game configuration
            let configuration = GameConfiguration()
            
            // Initialize collision handler
            let handler = CollisionHandler(configuration: configuration, gameManager: gameManager)
            collisionHandler = handler
            
            // Create game entities
            let table = TableEntity.create(with: configuration)
            let wall = WallEntity.create(with: configuration)
            let ball = BallEntity.create(with: configuration)
            let ground = GroundEntity.create(with: configuration)
            let racket = RacketEntity.create()
            
            // Add entities to the scene
            content.add(table)
            content.add(wall)
            content.add(ball)
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
        }
    }
}

#Preview(immersionStyle: .progressive) {
    ImmersiveView()
        .environment(AppModel())
}
