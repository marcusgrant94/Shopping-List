//
//  ShareButton.swift
//  Shopping List
//
//  Created by Marcus Grant on 5/23/25.
//

import SwiftUI

struct ShareButton: View {
    var disabled: Bool = false
    @State private var showShareSheet = false
    @State private var shareText = ""
    @AppStorage("isPremiumUser") var isPremiumUser: Bool = false
    @State private var showPaywall = false
    @State private var showEmptyListAlert = false



    @EnvironmentObject var RealmManager: RealmManager

    var body: some View {
        Button {
            if RealmManager.tasks.isEmpty {
                showEmptyListAlert = true
                return
            }

            if isPremiumUser {
                shareText = formattedTaskList()
                showShareSheet = true
            } else {
                showPaywall = true
            }
        } label: {
            Image(systemName: "square.and.arrow.up")
                .foregroundColor((!isPremiumUser || RealmManager.tasks.isEmpty) ? .gray : .blue)
        }
        .alert("Please add items to your list to share", isPresented: $showEmptyListAlert) {
                    Button("OK", role: .cancel) { }
                }
        .sheet(isPresented: $showShareSheet) {
            ActivityView(activityItems: [shareText])
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }

    }

    func formattedTaskList() -> String {
        RealmManager.tasks.map {
            let qtyText = $0.quantity > 1 ? " (x\($0.quantity))" : ""
            return "- \($0.title)\(qtyText)"
        }.joined(separator: "\n")
    }
}

