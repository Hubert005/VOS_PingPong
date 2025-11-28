//
//  GameOverView.swift
//  VOS_PingPong
//
//  SwiftUI view for displaying game over screen with final score and restart option
//

import SwiftUI

/// Displays the game over screen with final score and restart functionality
struct GameOverView: View {
    let finalScore: Int
    let onRestart: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Game Over Title
            Text("GAME OVER")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(.red)
            
            // Final Score Display
            VStack(spacing: 8) {
                Text("Final Score")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                Text("\(finalScore)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
            }
            .padding(.vertical, 12)
            
            // Restart Button
            Button(action: onRestart) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title3)
                    Text("Play Again")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(.blue)
                .foregroundStyle(.white)
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
        .padding(40)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(radius: 20)
    }
}

#Preview {
    VStack(spacing: 40) {
        GameOverView(finalScore: 42) {
            print("Restart tapped")
        }
        
        GameOverView(finalScore: 0) {
            print("Restart tapped")
        }
        
        GameOverView(finalScore: 150) {
            print("Restart tapped")
        }
    }
    .padding()
}
