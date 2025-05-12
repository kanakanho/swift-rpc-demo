//
//  ContentView.swift
//  swift-rpc-demo
//
//  Created by blueken on 2025/05/12.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            main()
        }
    }
}

#Preview {
    ContentView()
}
