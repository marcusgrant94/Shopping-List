//
//  RealmManager.swift
//  Shopping List
//
//  Created by Marcus Grant on 3/25/22.
//

import Foundation
import RealmSwift

@MainActor
final class RealmManager: ObservableObject {
    private(set) var localRealm: Realm?
    @Published private(set) var tasks: [ShoppingTask] = []

    init() {
        openRealm()
        getTasks()
    }

    // MARK: - Setup

    private func openRealm() {
        do {
            localRealm = try Realm()   // uses the defaultConfiguration you set at app launch
        } catch {
            assertionFailure("Error opening Realm: \(error)")
        }
    }

    // MARK: - Queries

    func getTasks() {
        guard let localRealm else { return }
        // Sort: incomplete first, then by manual order, then title
        let results = localRealm.objects(ShoppingTask.self)
            .sorted(by: [
                SortDescriptor(keyPath: "completed", ascending: true),
                SortDescriptor(keyPath: "order",     ascending: true),
                SortDescriptor(keyPath: "title",     ascending: true)
            ])
        tasks = Array(results)
    }

    // MARK: - Mutations

    func addTask(taskTitle: String,
                 quantity: Int,
                 suggestionManager: SuggestionManager? = nil) {
        guard let localRealm else { return }

        let cleanedTitle = taskTitle.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            try localRealm.write {
                let newTask = ShoppingTask()
                newTask.title = cleanedTitle
                newTask.quantity = quantity
                newTask.completed = false

                // place at end of current order
                let lastOrder = localRealm.objects(ShoppingTask.self)
                    .sorted(byKeyPath: "order", ascending: false)
                    .first?.order ?? -1
                newTask.order = lastOrder + 1

                localRealm.add(newTask)
            }
            getTasks()
        } catch {
            assertionFailure("Error adding task: \(error)")
        }
        AppReviewManager.recordItemAddedAndMaybePrompt()
        suggestionManager?.saveSuggestionIfNeeded(for: cleanedTitle)
    }

    func updateTask(id: ObjectId,
                    title: String? = nil,
                    quantity: Int? = nil,
                    completed: Bool? = nil) {
        guard let localRealm,
              let task = localRealm.object(ofType: ShoppingTask.self, forPrimaryKey: id) else { return }
        do {
            try localRealm.write {
                if let title { task.title = title }
                if let quantity { task.quantity = quantity }
                if let completed { task.completed = completed }
                
            }
            getTasks()
        } catch {
            assertionFailure("Error updating task \(id): \(error)")
        }
    }
    
    func updateTaskName(id: ObjectId,
                    title: String? = nil,
                    quantity: Int? = nil,
                    completed: Bool? = nil,
                        newTask: String) {
        let cleaned = newTask.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let localRealm,
              let task = localRealm.object(ofType: ShoppingTask.self, forPrimaryKey: id) else { return }
        do {
            try localRealm.write {
                if let title { task.title = title }
                if let quantity { task.quantity = quantity }
                if let completed { task.completed = completed }
                task.title = cleaned
            }
            getTasks()
        } catch {
            assertionFailure("Error updating task \(id): \(error)")
        }
    }

    func deleteTask(id: ObjectId) {
        guard let localRealm,
              let task = localRealm.object(ofType: ShoppingTask.self, forPrimaryKey: id) else { return }
        do {
            try localRealm.write {
                localRealm.delete(task)
            }
            getTasks()
        } catch {
            assertionFailure("Error deleting task \(id): \(error)")
        }
    }

    func deleteAllTasks() {
        guard let localRealm else { return }
        do {
            try localRealm.write {
                localRealm.delete(localRealm.objects(ShoppingTask.self))
            }
            getTasks()
        } catch {
            assertionFailure("Error deleting all tasks: \(error)")
        }
    }

    // Reorder list (persist new `.order` values)
    func moveTask(fromOffsets: IndexSet, toOffset: Int) {
        guard let localRealm else { return }

        var snapshot = tasks
        snapshot.move(fromOffsets: fromOffsets, toOffset: toOffset)

        do {
            try localRealm.write {
                for (index, task) in snapshot.enumerated() {
                    task.order = index
                }
            }
            tasks = snapshot
        } catch {
            assertionFailure("Error updating order: \(error)")
        }
    }

    // MARK: - Helpers

    func getMostFrequentItems(from tasks: [ShoppingTask], topN: Int = 3) -> [String] {
        let cleaned = tasks.map { $0.title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
        var counts: [String: Int] = [:]
        for t in cleaned { counts[t, default: 0] += 1 }
        return counts.sorted { $0.value > $1.value }
            .prefix(topN)
            .map { $0.key.capitalized }
    }
}



