//
//  ComparePricesViewModel.swift
//  Find Deals Fast
//

import Foundation
import SwiftUI

@MainActor
class ComparePricesViewModel: ObservableObject {
    @Published var priceComparisons: [PriceComparison] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let dataFetcher = DataFetcher.shared
    
    func loadPriceComparisons(for product: Product) async {
        isLoading = true
        error = nil
        
        let comparisons = await dataFetcher.fetchPriceComparisons(for: product)
        priceComparisons = comparisons
        
        isLoading = false
    }
    
    func refresh(for product: Product) async {
        await loadPriceComparisons(for: product)
    }
}

