//
//  TrackingLostView.swift
//  VOS_PingPong
//
//  Notification UI for hand tracking loss
//

import SwiftUI

/// View displayed when hand tracking is lost
struct TrackingLostView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "hand.raised.slash")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Hand Tracking Lost")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Please raise your hand into view")
                .font(.body)
                .foregroundColor(.secondary)
            
            Text("Game Paused")
                .font(.caption)
                .foregroundColor(.orange)
                .padding(.top, 10)
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
        .shadow(radius: 10)
    }
}

#Preview {
    TrackingLostView()
}
