//
//  WishlistViewModel.swift
//  Find Deals Fast
//

import Foundation
import SwiftUI

@MainActor
class WishlistViewModel: ObservableObject {
    @Published var wishlistProducts: [Product] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let dataFetcher = DataFetcher.shared
    
    func loadWishlistProducts(productIds: [String]) async {
        isLoading = true
        error = nil
        
        var products: [Product] = []
        
        for id in productIds {
            if let product = await dataFetcher.getProduct(id: id) {
                products.append(product)
            }
        }
        
        wishlistProducts = products
        isLoading = false
    }
    
    func refresh(productIds: [String]) async {
        await loadWishlistProducts(productIds: productIds)
    }
}

