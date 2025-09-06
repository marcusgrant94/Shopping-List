//
//  WhatsNewView.swift
//  Shopping List
//
//  Created by Marcus Grant on 9/6/25.
//

import SwiftUI

struct WhatsNewView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "pencil")
                .font(.system(size: 40, weight: .bold))
            Text("Whats New: Swipe to Edit")
                .font(.title2.bold())
            Text("Quickly edit any item by swiping left and tapping Edit.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Got it") { dismiss() }
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .presentationDetents([.fraction(0.35)])
        .interactiveDismissDisabled(false)
    }
    @Environment(\.dismiss) private var dismiss
}
