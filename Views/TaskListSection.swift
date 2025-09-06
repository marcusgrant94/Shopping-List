//
//  SuggestionsSection.swift
//  Shopping List
//
//  Created by Marcus Grant on 5/23/25.
//

import SwiftUI

struct TaskListSection: View {
    @EnvironmentObject var RealmManager: RealmManager
    @EnvironmentObject var SuggestionManager: SuggestionManager
    var suggestionManager: SuggestionManager
    @State var isEditing: ShoppingTask?
    
    var body: some View {
        if #available(iOS 16.0, *) {
            List {
                ForEach(RealmManager.tasks, id: \.id) {
                    task in
                    if !task.isInvalidated {
                        TaskRow(task: task.title, quantity: task.quantity, completed: task.completed)
                            .onTapGesture {
                                UINotificationFeedbackGenerator().notificationOccurred(.success) 
                                RealmManager.updateTask(id: task.id, completed: !task.completed)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                                    RealmManager.deleteTask(id: task.id)
                                    
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                
                                Button {
                                    isEditing = task
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                            }
                    }
                }
                .onMove(perform: moveTask)
                .listRowSeparator(.hidden)
            }
            .onAppear {
                print("Suggestions: \(suggestionManager.suggestions.map { $0.title })")
            }
            .sheet(item: $isEditing) { task in
                EditingTaskSheet(realmManager: RealmManager, task: task)
            }

            .scrollContentBackground(.hidden)
        } else {
            List {
                ForEach(RealmManager.tasks, id: \.id) {
                    task in
                    if !task.isInvalidated {
                        TaskRow(task: task.title, quantity: task.quantity, completed: task.completed)
                            .onTapGesture {
                                RealmManager.updateTask(id: task.id, completed: !task.completed)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    RealmManager.deleteTask(id: task.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .listRowSeparator(.hidden)
            }
        }
    }
    
    func moveTask(from source: IndexSet, to destination: Int) {
        RealmManager.moveTask(fromOffsets: source, toOffset: destination)
    }
}


