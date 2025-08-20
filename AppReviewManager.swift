//
//  AppReviewManager.swift
//  Shopping List
//
//  Created by Marcus Grant on 8/20/25.
//

import UIKit
import StoreKit

enum AppReviewManager {
    // Tune these as you like (we'll use 4 to match your request)
    private static let threshold = 4
    private static let actionCountKey = "review.itemsAddedCount"
    private static let lastVersionPromptedKey = "review.lastVersionPrompted"

    /// Call this whenever an item is added.
    static func recordItemAddedAndMaybePrompt() {
        let defaults = UserDefaults.standard
        let newCount = defaults.integer(forKey: actionCountKey) + 1
        defaults.set(newCount, forKey: actionCountKey)

        guard newCount >= threshold else { return }

        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let lastVersion = defaults.string(forKey: lastVersionPromptedKey)

        // Only prompt once per app version
        guard lastVersion != currentVersion else { return }

        requestReviewIfPossible()
        defaults.set(currentVersion, forKey: lastVersionPromptedKey)
    }

    /// Ask the system to show the in-app review dialog (rate-limited by iOS).
    private static func requestReviewIfPossible() {
        // Prefer the active foreground scene in SwiftUI apps
        if let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) {
            SKStoreReviewController.requestReview(in: scene)
        } else {
            // Fallback (rare): no active scene; skip or open the App Store page instead.
            // openWriteReviewPage(appID: "YOUR_APP_ID") // optional fallback
        }
    }

    /// Optional: Directly open the App Store review page (e.g., from Settings)
    static func openWriteReviewPage(appID: String) {
        guard let url = URL(string: "https://apps.apple.com/app/id\(appID)?action=write-review") else { return }
        UIApplication.shared.open(url)
    }

    // For testing: reset counters (don’t ship this)
    static func _resetCountersForDebug() {
        let d = UserDefaults.standard
        d.removeObject(forKey: actionCountKey)
        d.removeObject(forKey: lastVersionPromptedKey)
    }
}
