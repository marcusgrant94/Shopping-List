//
//  HeaderView.swift
//  Shopping List
//
//  Created by Marcus Grant on 5/23/25.
//

import SwiftUI


struct HeaderView: View {
    @EnvironmentObject var RealmManager: RealmManager
    @State var showPaywall: Bool = false
    @AppStorage("isPremiumUser") var isPremiumUser: Bool = false


    var body: some View {
        HStack {
            Text("My List")
                .font(.title3).bold()
                .foregroundColor(.black)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if isPremiumUser {
                PremiumButton()
                    .padding(.top)
                    .padding(.horizontal)
            } else {
                Button {
                    showPaywall.toggle()
                } label: {
                    PremiumButton()
                        .padding(.top)
                        .padding(.horizontal)
                }
                .sheet(isPresented: $showPaywall) {
                    PaywallView()
                }
            }
            
            
            ShareButton()
                .padding(.top)
            
            Button {
                RealmManager.deleteAllTasks()
            } label: {
                Label("", systemImage: "trash")
                    .foregroundColor(.red)
            }
            .padding(.horizontal)
            .padding(.top)
        }
    }
}

