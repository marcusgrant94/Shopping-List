//
//  RealmManager.swift
//  Shopping List
//
//  Created by Marcus Grant on 3/25/22.
//

import Foundation
import RealmSwift

class RealmManager: ObservableObject {
    private(set) var localRealm: Realm?
    @Published private(set) var tasks: [ShoppingTask] = []
    let suggestionManager = SuggestionManager()
    
    init() {
        openRealm()
        getTasks()
    }
    
    func openRealm() {
        do {
            let config = Realm.Configuration(
                schemaVersion: 3,
                migrationBlock: { _, _ in }
            )
            Realm.Configuration.defaultConfiguration = config
            
            localRealm = try Realm()
            
        } catch {
            print("Error opening Realm: \(error)")
        }
    }
    
    func addTask(taskTitle: String, quantity: Int, suggestionManager: SuggestionManager) {
        if let localRealm = localRealm {
            do {
                try localRealm.write {
                    let newTask = ShoppingTask()
                    newTask.title = taskTitle
                    newTask.quantity = quantity
                    newTask.completed = false
                    localRealm.add(newTask)
                    getTasks()
                    print("Added new task to Realm: \(newTask)")
                }
                suggestionManager.saveSuggestionIfNeeded(for: taskTitle)
            } catch {
                print("Error adding task to Realm: \(error)")
            }
        }
    }
        
        func getTasks() {
            if let localRealm = localRealm {
                let allTasks = localRealm.objects(ShoppingTask.self).sorted(byKeyPath: "completed")
                tasks = []
                allTasks.forEach { task in
                    tasks.append(task)
                }
            }
        }
    
    func updateTask(id: ObjectId, completed: Bool) {
        if let localRealm = localRealm {
            do {
                let taskToUpdate = localRealm.objects(ShoppingTask.self).filter(NSPredicate(format: "id == %@", id))
                guard !taskToUpdate.isEmpty else { return }
                
                try localRealm.write {
                    taskToUpdate[0].completed = completed
                    getTasks()
                    print("Updated task with id \(id)! Completed status: \(completed)")
                }
                
            } catch {
                print("Error updating task \(id) to realm \(error)")
            }
        }
    }
    
    func deleteTask(id: ObjectId) {
        if let localRealm = localRealm {
            do {
                let taskToDelete = localRealm.objects(ShoppingTask.self).filter(NSPredicate(format: "id == %@", id))
                guard !taskToDelete.isEmpty else { return }
                
                try localRealm.write {
                    localRealm.delete(taskToDelete)
                    getTasks()
                    print("Deleted task with id \(id)")
                }
            } catch {
                print("Error deleting task \(id) from Realm: \(error)")
            }
        }
    }
    
    func deleteAllTasks() {
        guard let localRealm = localRealm else { return }
        let allTasks = localRealm.objects(ShoppingTask.self)

        try! localRealm.write {
            localRealm.delete(allTasks)
        }
        getTasks()
    }

    
    func getMostFrequentItems(from tasks: [ShoppingTask], topN: Int = 3) -> [String] {
        let cleanedTitles = tasks.map { $0.title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
        let frequencies = Dictionary(grouping: cleanedTitles) { $0 }
            .mapValues { $0.count }

        return frequencies
            .sorted { $0.value > $1.value }
            .prefix(topN)
            .map { $0.key.capitalized } // Capitalize for UI display
    }
    
    func moveTask(fromOffsets: IndexSet, toOffset: Int) {
        guard let localRealm = localRealm else { return }
        let mutableTasks = tasks

        tasks.move(fromOffsets: fromOffsets, toOffset: toOffset)

        // Save updated order to Realm
        do {
            try localRealm.write {
                for (index, task) in tasks.enumerated() {
                    task.order = index
                }
            }
        } catch {
            print("Error updating order: \(error)")
        }
    }


}


