//
//  PaywallView.swift
//  Shopping List
//
//  Created by Marcus Grant on 5/23/25.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject var storeManager: StoreManager
    @State private var selectedPlan: PlanType = .monthly
    @AppStorage("hasUsedFreeTrial") var hasUsedFreeTrial: Bool = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hue: 0.08, saturation: 0.15, brightness: 0.97),
                        Color(hue: 0.08, saturation: 0.10, brightness: 0.92)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 24) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.black)

                    Text("Go Premium")
                        .font(.largeTitle.bold())
                        .foregroundColor(.black)

                    Text("Unlock all the app features by subscribing to the Premium version.")
                        .font(.subheadline)
                        .foregroundColor(.black.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineLimit(nil) // allow unlimited lines
                        .fixedSize(horizontal: false, vertical: true) // force wrapping
                        .padding(.horizontal)



                    VStack(alignment: .leading, spacing: 12) {
                        Label("Unlimited Items", systemImage: "checkmark.circle")
                        Label("Import recipes from any website", systemImage: "list.clipboard")
                        Label("Smart Suggestions", systemImage: "lightbulb")
                        Label("Export your list to share or print", systemImage: "square.and.arrow.up")
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                    Button {
                        if let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Text("Terms of Service and Privacy Policy")
                            .font(.footnote)
                            .foregroundColor(.black.opacity(0.6))
                    }

                    VStack(spacing: 12) {
                        ForEach(storeManager.products, id: \.id) { product in
                            planOption(
                                title: product.displayName,
                                price: Text(product.displayPrice),
                                isSelected: selectedPlan == (product.id == "Monthly" ? .monthly : .yearly)
                            ) {
                                selectedPlan = (product.id == "Monthly" ? .monthly : .yearly)
                            }
                        }
                    }


                    if !hasUsedFreeTrial {
                        Button(action: {
                            if let selectedProduct = storeManager.products.first(where: {
                                $0.id == (selectedPlan == .monthly ? "Monthly" : "Yearly")
                            }) {
                                Task {
                                    let success = await storeManager.purchase(selectedProduct)
                                    if success {
                                        hasUsedFreeTrial = true
                                        dismiss()
                                    }
                                }
                            }
                        }) {
                            Text("Start Free Trial")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)

                        Text(
                            selectedPlan == .monthly
                            ? "Free for 3 days, then $1.99/month. Cancel anytime."
                            : "Free for 3 days, then $14.99/year. Cancel anytime."
                        )
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                        .padding(.bottom)
                    } else {
                        Button(action: {
                            if let selectedProduct = storeManager.products.first(where: {
                                $0.id == (selectedPlan == .monthly ? "Monthly" : "Yearly")
                            }) {
                                Task {
                                    let success = await storeManager.purchase(selectedProduct)
                                    if success {
                                        hasUsedFreeTrial = true
                                        dismiss()
                                    }

                                }
                            }
                        }) {
                            Text("Subscribe")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)

                        Text("You’ve already used your free trial. Subscribe to continue.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    }


                    HStack(spacing: 24) {
                        Button("Redeem Code") {
                            if let url = URL(string: "https://apps.apple.com/account/redeem") {
                                UIApplication.shared.open(url)
                            }
                        }
                        .font(.footnote)
                        .foregroundColor(.black.opacity(0.8))

                        Button("Restore Subscription") {
                            Task {
                                await storeManager.restore()
                            }
                        }
                        .font(.footnote)
                        .foregroundColor(.black.opacity(0.8))
                    }
                }
                .padding()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }

    @ViewBuilder
    func planOption(title: String, price: Text, isSelected: Bool, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                    Text("Unlock extra features")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                price // ← now using a Text view directly
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Circle()
                        .stroke(Color.gray, lineWidth: 1)
                        .frame(width: 20, height: 20)
                }
            }
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(10)
            .foregroundColor(.black)
        }
        .padding(.horizontal)
    }



    enum PlanType {
        case monthly, yearly
    }
}

struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView()
            .environmentObject(StoreManager())
    }
}



