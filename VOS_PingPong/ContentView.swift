//
//  ContentView.swift
//  VOS_PingPong
//
//  Created by Elias on 21.11.25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    @Environment(AppModel.self) var appModel
    
    private var gameManager: GameManager {
        appModel.gameManager
    }

    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text("PingPong3D")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Current game state display
            GameStateView(gameState: gameManager.gameState)
            
            // Score display (when game is active or over)
            if gameManager.gameState != .idle {
                VStack(spacing: 8) {
                    Text("Score: \(gameManager.score)")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Consecutive Hits: \(gameManager.consecutiveHits)")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.regularMaterial)
                .cornerRadius(12)
            }
            
            // Game instructions
            InstructionsView()
            
            // Game controls
            VStack(spacing: 12) {
                // Start/Restart game button
                Button {
                    if gameManager.gameState == .idle || gameManager.gameState == .gameOver {
                        gameManager.resetGame()
                        gameManager.startGame()
                    }
                } label: {
                    Text(gameManager.gameState == .idle ? "Start Game" : "Restart Game")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(gameManager.gameState == .playing ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(gameManager.gameState == .playing)
                
                // Toggle immersive space
                ToggleImmersiveSpaceButton()
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

/// Displays the current game state with appropriate styling
struct GameStateView: View {
    let gameState: GameState
    
    var body: some View {
        HStack {
            Circle()
                .fill(stateColor)
                .frame(width: 12, height: 12)
            
            Text(stateText)
                .font(.headline)
                .foregroundStyle(stateColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(stateColor.opacity(0.1))
        .cornerRadius(20)
    }
    
    private var stateText: String {
        switch gameState {
        case .idle:
            return "Ready to Start"
        case .playing:
            return "Playing"
        case .paused:
            return "Paused"
        case .gameOver:
            return "Game Over"
        }
    }
    
    private var stateColor: Color {
        switch gameState {
        case .idle:
            return .blue
        case .playing:
            return .green
        case .paused:
            return .orange
        case .gameOver:
            return .red
        }
    }
}

/// Displays game instructions for the player
struct InstructionsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How to Play")
                .font(.headline)
                .fontWeight(.semibold)
            
            InstructionRow(
                icon: "hand.raised.fill",
                text: "Use your hand to control the racket"
            )
            
            InstructionRow(
                icon: "tennisball.fill",
                text: "Hit the ball to keep it in play"
            )
            
            InstructionRow(
                icon: "arrow.up.circle.fill",
                text: "Earn points for consecutive hits"
            )
            
            InstructionRow(
                icon: "exclamationmark.triangle.fill",
                text: "Game ends when ball hits the ground"
            )
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}

/// A single instruction row with icon and text
struct InstructionRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)
            
            Text(text)
                .font(.body)
                .foregroundStyle(.primary)
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
