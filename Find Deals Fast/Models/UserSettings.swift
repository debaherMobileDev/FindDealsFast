//
//  UserSettings.swift
//  Find Deals Fast
//

import Foundation
import SwiftUI

class UserSettings: ObservableObject {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @AppStorage("wishlistItems") private var wishlistData: String = "[]"
    @AppStorage("preferredCurrency") var preferredCurrency: String = "USD"
    @AppStorage("enableNotifications") var enableNotifications: Bool = true
    @AppStorage("priceAlertThreshold") var priceAlertThreshold: Double = 10.0
    
    @Published var wishlist: [String] = []
    
    init() {
        loadWishlist()
    }
    
    func addToWishlist(_ productId: String) {
        if !wishlist.contains(productId) {
            wishlist.append(productId)
            saveWishlist()
        }
    }
    
    func removeFromWishlist(_ productId: String) {
        wishlist.removeAll { $0 == productId }
        saveWishlist()
    }
    
    func isInWishlist(_ productId: String) -> Bool {
        return wishlist.contains(productId)
    }
    
    func toggleWishlist(_ productId: String) {
        if isInWishlist(productId) {
            removeFromWishlist(productId)
        } else {
            addToWishlist(productId)
        }
    }
    
    private func saveWishlist() {
        if let encoded = try? JSONEncoder().encode(wishlist) {
            wishlistData = String(data: encoded, encoding: .utf8) ?? "[]"
        }
    }
    
    private func loadWishlist() {
        if let data = wishlistData.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            wishlist = decoded
        }
    }
    
    func resetApp() {
        hasCompletedOnboarding = false
        wishlist = []
        wishlistData = "[]"
        preferredCurrency = "USD"
        enableNotifications = true
        priceAlertThreshold = 10.0
    }
}

