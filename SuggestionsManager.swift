//
//  SuggestionsManager.swift
//  Shopping List
//
//  Created by Marcus Grant on 5/20/25.
//

import Foundation
import RealmSwift
import SwiftUI

class SuggestedItem: Object, Identifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title: String = ""

    
}


class SuggestionManager: ObservableObject {
    @Published var suggestions: [SuggestedItem] = []

    init() {
        fetchSuggestions()
    }
    

    func fetchSuggestions() {
        let config = Realm.Configuration(
            schemaVersion: 3, // bump this to 2 if needed
            migrationBlock: { migration, oldSchemaVersion in
                // Optional: Handle changes between versions here
            }
        )

        Realm.Configuration.defaultConfiguration = config
        let realm = try! Realm()
        suggestions = Array(realm.objects(SuggestedItem.self))
    }

    func saveSuggestionIfNeeded(for title: String) {
        @AppStorage("isPremiumUser") var isPremiumUser: Bool = false

        guard isPremiumUser else { return }
        let cleaned = title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let realm = try! Realm()

        if let existingHistory = realm.objects(SuggestionHistory.self).first(where: { $0.title.lowercased() == cleaned }) {
            try! realm.write {
                existingHistory.count += 1
            }
            
            if existingHistory.count > 2 {
                addToSuggestionsIfNeeded(cleaned.capitalized)
            }

        } else {
            let history = SuggestionHistory()
            history.title = cleaned.capitalized
            history.count = 1

            try! realm.write {
                realm.add(history)
            }
        }
    }
    
    func addToSuggestionsIfNeeded(_ title: String) {
        let realm = try! Realm()
        let alreadyExists = realm.objects(SuggestedItem.self).contains {
            $0.title.lowercased() == title.lowercased()
        }
        
        if !alreadyExists {
            let newItem = SuggestedItem()
            newItem.title = title
            try! realm.write {
                realm.add(newItem)
            }
            fetchSuggestions()
        }
    }


    func deleteSuggestion(id: ObjectId) {
        let realm = try! Realm()
        if let item = realm.object(ofType: SuggestedItem.self, forPrimaryKey: id) {
            let itemTitle = item.title.lowercased() // 👈 Save the title first
            
            try! realm.write {
                realm.delete(item) // ✅ Now it's safe to delete
                
                if let history = realm.objects(SuggestionHistory.self).first(where: {
                    $0.title.lowercased() == itemTitle
                }) {
                    history.count = 0
                }
            }
            
            fetchSuggestions()
        }
    }
}

class SuggestionHistory: Object, Identifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title: String = ""
    @Persisted var count: Int = 0
}

