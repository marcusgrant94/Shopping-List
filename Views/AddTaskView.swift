//
//  AddTaskView.swift
//  Shopping List
//
//  Created by Marcus Grant on 3/25/22.
//

import SwiftUI

struct AddTaskView: View {
    @EnvironmentObject var realmManager: RealmManager
    @EnvironmentObject var suggestionManager: SuggestionManager

    @State private var title: String = ""
    @State private var recipeURL = ""
    @State private var quantity: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showPaywall = false

    let freeTaskLimit = 6
    @AppStorage("isPremiumUser") private var isPremiumUser = false
    @Environment(\.colorScheme) private var colorScheme

    private var pageBackground: Color {
        colorScheme == .dark
        ? Color(.systemGroupedBackground)
        : Color(hue: 0.086, saturation: 0.141, brightness: 0.972) // your original
    }

    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            // Heading → dynamic (black in light, white in dark)
            Text("Create a new item")
                .font(.title3.bold())
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Title field with white placeholder in dark mode
            TextField(
                "",
                text: $title,
                prompt: Text("Enter your item here")
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.9) : .secondary)
            )
            .textFieldStyle(.roundedBorder)

            // Quantity field with white placeholder in dark mode
            TextField(
                "",
                text: $quantity,
                prompt: Text("Quantity (optional)")
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.9) : .secondary)
            )
            .keyboardType(.numberPad)
            .textFieldStyle(.roundedBorder)
            .onChange(of: quantity) { newValue in
                quantity = newValue.filter { $0.isNumber }
            }

            Button {
                guard !title.isEmpty else { return }
                let quantityValue = Int(quantity) ?? 1

                if realmManager.tasks.count >= freeTaskLimit && !isPremiumUser {
                    showPaywall = true
                } else {
                    realmManager.addTask(
                        taskTitle: title,
                        quantity: quantityValue,
                        suggestionManager: suggestionManager
                    )
                    dismiss()
                }
            } label: {
                Text("Add item")
                    .foregroundColor(.white)
                    .padding()
                    .padding(.horizontal)
                    .background(Color(hue: 0.328, saturation: 0.796, brightness: 0.408))
                    .cornerRadius(30)
            }

            // Heading → dynamic color
            Text("Import Recipe (Optional)")
                .font(.title3.bold())
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Recipe URL with white placeholder in dark mode
            TextField(
                "",
                text: $recipeURL,
                prompt: Text("Enter Recipe URL")
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.9) : .secondary)
            )
            .textFieldStyle(.roundedBorder)
            .font(.subheadline)
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .lineLimit(1)
            .truncationMode(.middle)

            if isLoading {
                ProgressView()
            }

            Button("Import Ingredients") {
                if isPremiumUser {
                    Task {
                        await importRecipeIngredients(from: recipeURL)
                        if errorMessage == nil { dismiss() }
                    }
                } else {
                    showPaywall = true
                }
            }
            .disabled(recipeURL.isEmpty)
            .font(.subheadline)
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(Color(hue: 0.328, saturation: 0.796, brightness: 0.408))
            .cornerRadius(20)

            if let error = errorMessage {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
                .padding(.top, 6)
                .padding(.horizontal, 12)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }

            Spacer()
        }
        .padding(.top, 40)
        .padding(.horizontal)
        .background(pageBackground)
        .sheet(isPresented: $showPaywall) { PaywallView() }
    }

    // MARK: - Networking

    func importRecipeIngredients(from url: String) async {
        isLoading = true
        errorMessage = nil

        let apiKey = "113d9bd629ca41c6938d5dc82c04a3ba"

        guard !url.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter a recipe URL."
            isLoading = false
            return
        }

        guard let encodedURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let requestURL = URL(string: "https://api.spoonacular.com/recipes/extract?url=\(encodedURL)&apiKey=\(apiKey)") else {
            errorMessage = "Invalid URL format. Please check and try again."
            isLoading = false
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: requestURL)
            let decoded = try JSONDecoder().decode(RecipeResponse.self, from: data)

            if decoded.extendedIngredients.isEmpty {
                errorMessage = "No ingredients found in the recipe. Try a different link."
            } else {
                let quantityValue = Int(quantity) ?? 1
                for ingredient in decoded.extendedIngredients {
                    realmManager.addTask(
                        taskTitle: ingredient.name,
                        quantity: quantityValue,
                        suggestionManager: suggestionManager
                    )
                }
            }
        } catch {
            errorMessage = "Something went wrong. Please try again later."
            print("Import error: \(error.localizedDescription)")
        }

        isLoading = false
    }
}



struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView()
            .environmentObject(RealmManager())
            .environmentObject(SuggestionManager())

    }
}
