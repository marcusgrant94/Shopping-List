//
//  TasksView.swift
//  Shopping List
//
//  Created by Marcus Grant on 3/25/22.
//

import SwiftUI

struct TasksView: View {
    @AppStorage("hasShownSuggestionHint") private var hasShownHint = false
    @AppStorage("isPremiumUser") private var isPremiumUser = false

    @EnvironmentObject var realmManager: RealmManager
    @EnvironmentObject var suggestionManager: SuggestionManager
    @Environment(\.colorScheme) private var colorScheme

    @State private var showHint = false
    @State private var suggestionToDelete: SuggestedItem?
    @State private var showingDeleteConfirmation = false

    // Use your original light color, switch only in dark mode
    private var pageBackground: Color {
        if colorScheme == .dark {
            return Color(.systemGroupedBackground)   // or Color.black.opacity(0.95) if you want darker
        } else {
            return Color(hue: 0.086, saturation: 0.141, brightness: 0.972) // your old light bg
        }
    }

    var body: some View {
        ZStack {
            pageBackground.ignoresSafeArea()

            VStack(spacing: 12) {
                HeaderView()

                if isPremiumUser && !suggestionManager.suggestions.isEmpty {
                    Text("Suggested Items")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(suggestionManager.suggestions, id: \.id) { item in
                                suggestionChip(for: item)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                    }
                    .onAppear {
                        if !hasShownHint {
                            showHint = true
                            hasShownHint = true
                        }
                    }
                    .alert("Tip", isPresented: $showHint) {
                        Button("Got it", role: .cancel) { }
                    } message: {
                        Text("Long-press a suggestion to remove it from this list.")
                    }
                }

                if realmManager.tasks.isEmpty {
                    Text("Your list is empty")
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 20)
                }

                TaskListSection(suggestionManager: suggestionManager)
                    .scrollContentBackground(.hidden) // lets our bg show through if it's a List
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .confirmationDialog("Delete this suggestion?",
                            isPresented: $showingDeleteConfirmation,
                            titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let item = suggestionToDelete {
                    suggestionManager.deleteSuggestion(id: item.id)
                    suggestionToDelete = nil
                }
            }
            Button("Cancel", role: .cancel) { suggestionToDelete = nil }
        }
    }

    // keeps chips dynamic (light: subtle gray; dark: dark surface)
    private func suggestionChip(for item: SuggestedItem) -> some View {
        Text(item.title)
            .font(.callout)
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color(.separator), lineWidth: 0.5)
            )
            .onTapGesture {
                realmManager.addTask(taskTitle: item.title, quantity: 1, suggestionManager: suggestionManager)
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

