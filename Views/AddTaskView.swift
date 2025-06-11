//
//  AddTaskView.swift
//  Shopping List
//
//  Created by Marcus Grant on 3/25/22.
//

import SwiftUI

struct AddTaskView: View {
    @EnvironmentObject var realmMaanger: RealmManager
    @EnvironmentObject var suggestionManager: SuggestionManager
    @State var recipeURL = ""
    @State var quantity: String = ""
    @State var isLoading = false
    @State var errorMessage: String?
    @State var showPaywall = false
    let freeTaskLimit = 6
    @AppStorage("isPremiumUser") var isPremiumUser: Bool = false




    @State private var title: String = ""
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Create a new item")
                .foregroundColor(.black)
                .font(.title3).bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("Enter your item here",
                      text: $title)
            .textFieldStyle(.roundedBorder)
            
            TextField("Quantity (optional)", text: $quantity)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: quantity) { newValue in
                                quantity = newValue.filter { $0.isNumber }
                            }


            
            Button {
                if title != "" {
                    let quantityValue = Int(quantity) ?? 1
                    
                    if realmMaanger.tasks.count >= freeTaskLimit && !isPremiumUser {
                        showPaywall = true
                    } else {
                        realmMaanger.addTask(taskTitle: title, quantity: quantityValue, suggestionManager: suggestionManager)
                        dismiss()
                    }
                }
            } label: {
                Text("Add item")
                    .foregroundColor(.white)
                    .padding()
                    .padding(.horizontal)
                    .background(Color(hue: 0.328, saturation: 0.796, brightness: 0.408))
                    .cornerRadius(30)
            }

            
            Text("Import Recipe (Optional)")
                .foregroundColor(.black)
                .font(.title3).bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("Enter Recipe URL", text: $recipeURL)
                .textFieldStyle(.roundedBorder)
                .font(.subheadline)
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                .lineLimit(1)
                .truncationMode(.middle) // shows beginning and end of the URL


            
            if isLoading {
                ProgressView()
            }
            
            Button("Import Ingredients") {
                if isPremiumUser {
                    Task {
                        await importRecipeIngredients(from: recipeURL)
                        if errorMessage == nil {
                            dismiss()
                        }
                    }
                } else {
                    showPaywall = true
                }
            }
            .disabled(recipeURL.isEmpty)
            .font(.subheadline) // smaller text
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(Color(hue: 0.328, saturation: 0.796, brightness: 0.408))
            .cornerRadius(20)

            if let error = errorMessage {
                HStack(alignment: .center, spacing: 8) {
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
        .background(Color(hue: 0.086, saturation: 0.141, brightness: 0.972))
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }

    }
    
    
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
            if let raw = String(data: data, encoding: .utf8) {
                print("Raw JSON: \(raw)")
            }

            let decoded = try JSONDecoder().decode(RecipeResponse.self, from: data)

            if decoded.extendedIngredients.isEmpty {
                errorMessage = "No ingredients found in the recipe. Try a different link."
            } else {
                let quantityValue = Int(quantity) ?? 1
                for ingredient in decoded.extendedIngredients {
                    realmMaanger.addTask(
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
