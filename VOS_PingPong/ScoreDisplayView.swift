//
//  ScoreDisplayView.swift
//  VOS_PingPong
//
//  SwiftUI view for displaying score and consecutive hits in AR space
//

import SwiftUI

/// Displays the current score and consecutive hits in AR space
struct ScoreDisplayView: View {
    let score: Int
    let consecutiveHits: Int
    let gameState: GameState
    
    var body: some View {
        VStack(spacing: 12) {
            // Score display
            VStack(spacing: 4) {
                Text("SCORE")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                Text("\(score)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
            }
            
            // Consecutive hits display
            VStack(spacing: 4) {
                Text("CONSECUTIVE HITS")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                Text("\(consecutiveHits)")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundStyle(.blue)
            }
            
            // Game state indicator
            if gameState != .playing {
                gameStateIndicator
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 10)
    }
    
    @ViewBuilder
    private var gameStateIndicator: some View {
        switch gameState {
        case .idle:
            Text("Ready to Play")
                .font(.caption)
                .foregroundStyle(.green)
        case .paused:
            Text("⏸ Paused")
                .font(.caption)
                .foregroundStyle(.orange)
        case .gameOver:
            Text("Game Over")
                .font(.caption)
                .foregroundStyle(.red)
        case .playing:
            EmptyView()
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ScoreDisplayView(score: 42, consecutiveHits: 15, gameState: .playing)
        ScoreDisplayView(score: 0, consecutiveHits: 0, gameState: .idle)
        ScoreDisplayView(score: 100, consecutiveHits: 0, gameState: .gameOver)
        ScoreDisplayView(score: 25, consecutiveHits: 8, gameState: .paused)
    }
    .padding()
}
