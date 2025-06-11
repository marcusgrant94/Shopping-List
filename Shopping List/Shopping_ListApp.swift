//
//  Shopping_ListApp.swift
//  Shopping List
//
//  Created by Marcus Grant on 3/25/22.
//

import SwiftUI

@main
struct Shopping_ListApp: App {
    @StateObject var realmManager = RealmManager()
    @StateObject var suggestionManager = SuggestionManager()
    @StateObject var storeManager = StoreManager()
    @AppStorage("isPremiumUser") var isPremiumUser: Bool = false

    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
                .environmentObject(realmManager)
                .environmentObject(suggestionManager)
                .environmentObject(storeManager)
                .onAppear {
                    storeManager.listenForTransactions()
                }
//                .preferredColorScheme(isPremiumUser ? nil : .light)
//            PaywallView()
        }
    }
}
