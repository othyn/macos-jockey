//
//  ContentView.swift
//  jockey
//
//  Created by Ben Tindall on 26/03/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Jockey")
                .font(.title)
            Text("SMB Share Manager")
                .font(.subheadline)
            Text("This application runs in the menu bar.")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
