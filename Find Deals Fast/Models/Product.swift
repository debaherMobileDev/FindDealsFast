//
//  Product.swift
//  Find Deals Fast
//

import Foundation

struct Product: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let price: Double
    let originalPrice: Double?
    let currency: String
    let imageURL: String
    let category: String
    let brand: String?
    let rating: Double?
    let reviewCount: Int?
    let availability: String
    let store: String
    
    var discount: Int? {
        guard let originalPrice = originalPrice, originalPrice > price else { return nil }
        return Int(((originalPrice - price) / originalPrice) * 100)
    }
    
    var formattedPrice: String {
        return String(format: "%.2f %@", price, currency)
    }
    
    var formattedOriginalPrice: String? {
        guard let originalPrice = originalPrice else { return nil }
        return String(format: "%.2f %@", originalPrice, currency)
    }
    
    init(id: String = UUID().uuidString,
         title: String,
         description: String,
         price: Double,
         originalPrice: Double? = nil,
         currency: String = "USD",
         imageURL: String,
         category: String,
         brand: String? = nil,
         rating: Double? = nil,
         reviewCount: Int? = nil,
         availability: String = "In Stock",
         store: String) {
        self.id = id
        self.title = title
        self.description = description
        self.price = price
        self.originalPrice = originalPrice
        self.currency = currency
        self.imageURL = imageURL
        self.category = category
        self.brand = brand
        self.rating = rating
        self.reviewCount = reviewCount
        self.availability = availability
        self.store = store
    }
}

struct PriceComparison: Identifiable {
    let id = UUID()
    let store: String
    let price: Double
    let currency: String
    let availability: String
    let deliveryTime: String?
    let url: String
    
    var formattedPrice: String {
        return String(format: "%.2f %@", price, currency)
    }
}

