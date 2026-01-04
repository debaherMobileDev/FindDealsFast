//
//  DataFetcher.swift
//  Find Deals Fast
//

import Foundation
import SwiftUI

class DataFetcher: ObservableObject {
    static let shared = DataFetcher()
    
    @Published var cachedProducts: [String: Product] = [:]
    @Published var categories: [String] = []
    
    private let apiService = APIService.shared
    
    private init() {}
    
    func loadCategories() async {
        do {
            let fetchedCategories = try await apiService.fetchCategories()
            await MainActor.run {
                self.categories = fetchedCategories
            }
        } catch {
            print("Failed to load categories: \(error)")
        }
    }
    
    func getProduct(id: String) async -> Product? {
        if let cached = cachedProducts[id] {
            return cached
        }
        
        do {
            let product = try await apiService.fetchProductById(id)
            await MainActor.run {
                cachedProducts[id] = product
            }
            return product
        } catch {
            print("Failed to fetch product \(id): \(error)")
            return nil
        }
    }
    
    func searchProducts(query: String) async throws -> [Product] {
        let products = try await apiService.fetchProducts(searchQuery: query)
        await MainActor.run {
            products.forEach { cachedProducts[$0.id] = $0 }
        }
        return products
    }
    
    func fetchProductsByCategory(_ category: String) async throws -> [Product] {
        let products = try await apiService.fetchProducts(category: category)
        await MainActor.run {
            products.forEach { cachedProducts[$0.id] = $0 }
        }
        return products
    }
    
    func fetchPriceComparisons(for product: Product) async -> [PriceComparison] {
        // Simulate price comparison across different stores
        let stores = ["Amazon", "eBay", "Walmart", "Target", "Best Buy"]
        let basePrice = product.price
        
        return stores.prefix(Int.random(in: 3...5)).map { store in
            let variance = Double.random(in: 0.85...1.15)
            let price = basePrice * variance
            let availability = Double.random(in: 0...1) > 0.2 ? "In Stock" : "Out of Stock"
            let deliveryDays = Int.random(in: 1...7)
            
            return PriceComparison(
                store: store,
                price: price,
                currency: product.currency,
                availability: availability,
                deliveryTime: "\(deliveryDays) days",
                url: "https://\(store.lowercased()).com/product/\(product.id)"
            )
        }.sorted { $0.price < $1.price }
    }
}

