//
//  Untitled.swift
//  Shopping List
//
//  Created by Marcus Grant on 5/22/25.
//

import Foundation

struct RecipeResponse: Codable {
    let extendedIngredients: [Ingredient]
}

struct Ingredient: Codable {
    let name: String
}
