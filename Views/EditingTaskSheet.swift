//
//  EditingTaskView.swift
//  Shopping List
//
//  Created by Marcus Grant on 9/5/25.
//
import SwiftUI


struct EditingTaskSheet: View {
    @ObservedObject var realmManager: RealmManager
    var task: ShoppingTask
    @State private var isEditing = ""
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var nameFieldFocused: Bool

    
    private var pageBackground: Color {
        colorScheme == .dark
        ? Color(.systemGroupedBackground)
        : Color(hue: 0.086, saturation: 0.141, brightness: 0.972) // your original
    }
    var body: some View {
        ZStack {
            pageBackground.ignoresSafeArea()
            VStack {
                TextField("Edit Item...", text: $isEditing)
                    .textFieldStyle(.roundedBorder)
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.9) : .secondary)
                    .focused($nameFieldFocused)
                    .padding()
                
                
                Button {
                    realmManager.updateTaskName(id: task.id, newTask: isEditing)
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    dismiss()
                } label: {
                    Text("Change Item")
                        .foregroundColor(.white)
                        .padding()
                        .padding(.horizontal)
                        .background(Color(hue: 0.328, saturation: 0.796, brightness: 0.408))
                        .cornerRadius(30)
                }
            }
            .background(pageBackground)
            .onAppear {
                isEditing = task.title
                DispatchQueue.main.async { nameFieldFocused = true }
            }
        }
    }
}
