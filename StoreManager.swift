//
//  StoreManager.swift
//  Shopping List
//
//  Created by Marcus Grant on 5/23/25.
//

import Foundation
import StoreKit

@MainActor
class StoreManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    
    private let productIDs = ["Monthly", "Yearly"]
    
    init() {
        Task {
            await requestProducts()
            await updatePurchasedProducts()
        }
    }
    
    func requestProducts() async {
        do {
            products = try await Product.products(for: productIDs)
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    purchasedProductIDs.insert(product.id)
                    UserDefaults.standard.set(true, forKey: "isPremiumUser")
                    return true
                } else {
                    return false
                }
            default:
                return false
            }
        } catch {
            print("Purchase error: \(error)")
            return false
        }
    }
    
    @MainActor
    func listenForTransactions() {
        Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try result.payloadValue
                    if transaction.revocationDate == nil {
                        await transaction.finish()

                        // Update access rights
                        UserDefaults.standard.set(true, forKey: "isPremiumUser")
                        print("Transaction update received for product: \(transaction.productID)")
                    }
                } catch {
                    print("Failed to process transaction update: \(error)")
                }
            }
        }
    }


    
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               productIDs.contains(transaction.productID) {
                purchasedProductIDs.insert(transaction.productID)
                UserDefaults.standard.set(true, forKey: "isPremiumUser")
            }
        }
    }
    
    func restore() async {
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            print("Failed to restore purchases: \(error)")
        }
    }
}
