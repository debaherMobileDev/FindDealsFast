//
//  ProductViewModel.swift
//  Find Deals Fast
//

import Foundation
import SwiftUI

@MainActor
class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var searchQuery = ""
    @Published var selectedCategory: String?
    @Published var hasMoreProducts = true
    
    private let apiService = APIService.shared
    private let dataFetcher = DataFetcher.shared
    private var currentSkip = 0
    private let limit = 30
    
    func loadProducts(refresh: Bool = false) async {
        if refresh {
            currentSkip = 0
            hasMoreProducts = true
        }
        
        guard !isLoading && hasMoreProducts else { return }
        
        isLoading = true
        error = nil
        
        do {
            let fetchedProducts: [Product]
            
            if !searchQuery.isEmpty {
                fetchedProducts = try await apiService.fetchProducts(searchQuery: searchQuery, limit: limit, skip: currentSkip)
            } else if let category = selectedCategory {
                fetchedProducts = try await apiService.fetchProducts(category: category, limit: limit, skip: currentSkip)
            } else {
                fetchedProducts = try await apiService.fetchProducts(limit: limit, skip: currentSkip)
            }
            
            if refresh {
                products = fetchedProducts
            } else {
                products.append(contentsOf: fetchedProducts)
            }
            
            currentSkip += fetchedProducts.count
            hasMoreProducts = fetchedProducts.count >= limit
        } catch let apiError as APIError {
            error = apiError.localizedDescription
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func search(_ query: String) async {
        searchQuery = query
        await loadProducts(refresh: true)
    }
    
    func selectCategory(_ category: String?) async {
        selectedCategory = category
        await loadProducts(refresh: true)
    }
    
    func refresh() async {
        await loadProducts(refresh: true)
    }
    
    func loadMore() async {
        await loadProducts(refresh: false)
    }
}

