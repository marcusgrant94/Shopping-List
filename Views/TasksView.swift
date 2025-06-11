//
//  TasksView.swift
//  Shopping List
//
//  Created by Marcus Grant on 3/25/22.
//

import SwiftUI

struct TasksView: View {
    @AppStorage("hasShownSuggestionHint") var hasShownHint = false
    @AppStorage("isPremiumUser") var isPremiumUser: Bool = false
    @State var showHint = false
    @EnvironmentObject var RealmManager: RealmManager
    @EnvironmentObject var suggestionManager: SuggestionManager
    @State var suggestionToDelete: SuggestedItem?
    @State var showingDeleteConfirmation = false
    let freeTaskLimit = 0
    @State var showPaywall = false


    
    var body: some View {
        ZStack {
            Color(hue: 0.086, saturation: 0.141, brightness: 0.972)
                .ignoresSafeArea()
            VStack {
                HeaderView()
                
                if isPremiumUser && !suggestionManager.suggestions.isEmpty {
                    Text("Suggested Items")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            let suggestions = suggestionManager.suggestions
                            
                            
                            ForEach(suggestions, id: \.id) { item in
                                suggestionView(for: item)
                            }
                        }
                        .padding(.vertical, 1)
                        .padding(.horizontal)
                        .padding(.bottom, 1)
                    }
                    .onAppear {
                        if !hasShownHint && !suggestionManager.suggestions.isEmpty {
                            showHint.toggle()
                            hasShownHint.toggle()
                        }
                    }
                    .alert("Tip", isPresented: $showHint) {
                        Button("Got it", role: .cancel) { }
                    } message: {
                        Text("Long-press a suggestion item to remove it from this list.")
                    }

                }
                    
                if RealmManager.tasks.isEmpty {
                       Text("Your list is empty")
                        .padding(.vertical, 20)
                   }

                
                TaskListSection(suggestionManager: suggestionManager)
//                .onAppear() {
//                    UITableView.appearance().backgroundColor = UIColor.clear
//                    UITableViewCell.appearance().backgroundColor = UIColor.clear
//                }
            }
            .confirmationDialog("Delete this suggestion?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    if let item = suggestionToDelete {
                        suggestionManager.deleteSuggestion(id: item.id)
                        suggestionToDelete = nil
                    }
                }
                Button("Cancel", role: .cancel) {
                    suggestionToDelete = nil
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hue: 0.086, saturation: 0.141, brightness: 0.972))
        }
    }
    
    
    
    
    
    @ViewBuilder
    func suggestionView(for item: SuggestedItem) -> some View {
        Text(item.title)
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 1)
            .onTapGesture {
                RealmManager.addTask(taskTitle: item.title, quantity: 1, suggestionManager: suggestionManager)
            }
            .onLongPressGesture {
                suggestionToDelete = item
                showingDeleteConfirmation = true
            }
    }

}
struct TasksView_Previews: PreviewProvider {
    static var previews: some View {
        TasksView()
            .environmentObject(RealmManager())
            .environmentObject(SuggestionManager())
    }
}

