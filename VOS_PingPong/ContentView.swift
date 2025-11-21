//
//  ContentView.swift
//  VOS_PingPong
//
//  Created by Elias on 21.11.25.
//

import SwiftUI
import RealityKit

struct ContentView: View {

    var body: some View {
        VStack {
            ToggleImmersiveSpaceButton()
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
