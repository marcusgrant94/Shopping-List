//
//  PreimumButton.swift
//  Shopping List
//
//  Created by Marcus Grant on 6/5/25.
//

import SwiftUI

struct PremiumButton: View {
    @AppStorage("isPremiumUser") var isPremiumUser: Bool = false
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "crown.fill")
            if isPremiumUser {
                Text("Premium")
            } else {
                Text("Get Premium")
            }
        }
        .font(.subheadline.bold())
        .foregroundColor(.green)
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.green, lineWidth: 1)
        )
        .fixedSize() // 👈 prevents multiline wrapping
    }
}





#Preview {
    PremiumButton()
}
