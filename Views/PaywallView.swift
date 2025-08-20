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
    @AppStorage("hasUsedFreeTrial") private var hasUsedFreeTrial = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    // Light keeps your original gradient; Dark uses system surfaces
    private var backgroundView: some View {
        Group {
            if colorScheme == .dark {
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            } else {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hue: 0.08, saturation: 0.15, brightness: 0.97),
                        Color(hue: 0.08, saturation: 0.10, brightness: 0.92)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
        .ignoresSafeArea()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundView

                VStack(spacing: 24) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.primary)

                    Text("Go Premium")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.primary)

                    Text("Unlock all the app features by subscribing to the Premium version.")
                        .font(.subheadline)
                            .foregroundStyle(.secondary)            // replaces .black.opacity(0.7)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .fixedSize(horizontal: false, vertical: true) // keep if you liked the old behavior
                            .lineLimit(nil) 

                    VStack(alignment: .leading, spacing: 12) {
                        Label("Unlimited Items", systemImage: "checkmark.circle")
                        Label("Import recipes from any website", systemImage: "list.clipboard")
                        Label("Smart Suggestions", systemImage: "lightbulb")
                        Label("Export your list to share or print", systemImage: "square.and.arrow.up")
                    }
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                    Button {
                        if let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Text("Terms of Service and Privacy Policy")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    // Plans
                    VStack(spacing: 12) {
                        ForEach(storeManager.products, id: \.id) { product in
                            let isMonthly = product.id == "Monthly"
                            planOption(
                                title: product.displayName,
                                subtitle: isMonthly ? "Billed monthly" : "Billed annually",
                                price: Text(product.displayPrice),
                                isSelected: selectedPlan == (isMonthly ? .monthly : .yearly)
                            ) {
                                selectedPlan = isMonthly ? .monthly : .yearly
                            }
                        }
                    }

                    // CTA
                    if !hasUsedFreeTrial {
                        Button(action: startSelectedPurchase) {
                            Text("Start Free Trial")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .padding(.horizontal)

                        Text(
                            selectedPlan == .monthly
                            ? "Free for 3 days, then $1.99/month. Cancel anytime."
                            : "Free for 3 days, then $14.99/year. Cancel anytime."
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                        .padding(.bottom)
                    } else {
                        Button(action: startSelectedPurchase) {
                            Text("Subscribe")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .padding(.horizontal)

                        Text("You’ve already used your free trial. Subscribe to continue.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                    }

                    HStack(spacing: 24) {
                        Button("Redeem Code") {
                            if let url = URL(string: "https://apps.apple.com/account/redeem") {
                                UIApplication.shared.open(url)
                            }
                        }
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                        Button("Restore Subscription") {
                            Task { await storeManager.restore() }
                        }
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
    }

    // MARK: - Plan Option Row

    @ViewBuilder
    func planOption(
        title: String,
        subtitle: String,
        price: Text,
        isSelected: Bool,
        onTap: @escaping () -> Void
    ) -> some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                price
                    .foregroundStyle(.primary)
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                } else {
                    Circle()
                        .strokeBorder(Color(.separator), lineWidth: 1)
                        .frame(width: 20, height: 20)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.secondarySystemBackground)) // dynamic surface
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isSelected ? Color.green.opacity(0.7) : Color(.separator), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }

    // MARK: - Purchase

    private func startSelectedPurchase() {
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
    }

    enum PlanType { case monthly, yearly }
}




