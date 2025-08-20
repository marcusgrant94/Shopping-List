//
//  Shopping_ListApp.swift
//  Shopping List
//
//  Created by Marcus Grant on 3/25/22.
//

import SwiftUI
import RealmSwift

enum Theme: Int, CaseIterable, Identifiable {
    case system = 0, light, dark
    var id: Int { rawValue }

    /// nil = follow system
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}


@main
struct Shopping_ListApp: SwiftUI.App {
    @StateObject private var realmManager: RealmManager
    @StateObject private var suggestionManager: SuggestionManager
    @StateObject private var storeManager: StoreManager
    
    @AppStorage("theme") private var themeRaw: Int = Theme.system.rawValue
      private var theme: Theme { Theme(rawValue: themeRaw) ?? .system }

    init() {
        var config = Realm.Configuration(schemaVersion: 3) { migration, old in
            if old < 1 {
                migration.enumerateObjects(ofType: SuggestedItem.className()) { _, newObj in
                    newObj?["id"] = newObj?["id"] ?? ObjectId.generate()
                    newObj?["title"] = newObj?["title"] ?? ""
                }
            }
            if old < 2 {
                migration.enumerateObjects(ofType: SuggestionHistory.className()) { _, newObj in
                    newObj?["id"] = newObj?["id"] ?? ObjectId.generate()
                    newObj?["title"] = newObj?["title"] ?? ""
                    newObj?["count"] = newObj?["count"] ?? 0
                }
            }
            // v3: add steps if you changed ShoppingTask or renamed fields
        }
        Realm.Configuration.defaultConfiguration = config
        do { _ = try Realm() } catch { fatalError("Realm init failed: \(error)") }

        _realmManager       = StateObject(wrappedValue: RealmManager())
        _suggestionManager  = StateObject(wrappedValue: SuggestionManager())
        _storeManager       = StateObject(wrappedValue: StoreManager())
    }

    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
                .environmentObject(realmManager)
                .environmentObject(suggestionManager)
                .environmentObject(storeManager)
                .preferredColorScheme(theme.colorScheme)
                .onAppear {
                    storeManager.listenForTransactions()
                }
        }
    }
}
