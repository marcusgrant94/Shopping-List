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
    @AppStorage("appTheme") private var appThemeRaw: Int = Theme.system.rawValue
    @State var theme: Theme = .system

    var body: some View {
        HStack {
            Text("My List")
                .font(.title3.bold())
                .foregroundStyle(.primary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)

            if isPremiumUser {
                PremiumButton()
                    .padding(.top)
                    .padding(.horizontal)
                    .tint(.primary)
            } else {
                Button { showPaywall = true; UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                } label: {
                    
                    PremiumButton()
                        .padding(.top)
                        .padding(.horizontal)
                }
                .tint(.primary)
                .sheet(isPresented: $showPaywall) {
                    PaywallView()
                }
            }
            
//            Button {
//                theme = (theme == .dark ? .light : .dark)
//                       } label: {
//                           Image(systemName: theme == .dark ? "sun.min.fill" : "moon.fill")
//                       }
                       

            // Ensure ShareButton respects tint (if it uses SF Symbols)
            ShareButton()
                .padding(.top)
                .tint(.primary)

            Button {
                realmManager.deleteAllTasks()
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
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


