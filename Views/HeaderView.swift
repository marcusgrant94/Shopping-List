//
//  HeaderView.swift
//  Shopping List
//
//  Created by Marcus Grant on 5/23/25.
//

import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var realmManager: RealmManager
    @State private var showPaywall = false
    @AppStorage("isPremiumUser") var isPremiumUser = false

    var body: some View {
        HStack {
            Text("My List")
                .font(.title3.bold())
                .foregroundStyle(.primary) // auto black/white
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)

            if isPremiumUser {
                PremiumButton()
                    .padding(.top)
                    .padding(.horizontal)
                    .tint(.primary) // adapts in dark mode
            } else {
                Button { showPaywall = true } label: {
                    PremiumButton()
                        .padding(.top)
                        .padding(.horizontal)
                }
                .tint(.primary)
                .sheet(isPresented: $showPaywall) {
                    PaywallView()
                }
            }

            // Ensure ShareButton respects tint (if it uses SF Symbols)
            ShareButton()
                .padding(.top)
                .tint(.primary)

            Button {
                realmManager.deleteAllTasks()
            } label: {
                Image(systemName: "trash")
                    .imageScale(.medium)
            }
            .tint(.red) // red works in both modes
            .padding(.horizontal)
            .padding(.top)
        }
    }
}


