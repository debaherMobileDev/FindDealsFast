//
//  ComparePricesView.swift
//  Find Deals Fast
//

import SwiftUI

struct ComparePricesView: View {
    let product: Product
    @StateObject private var viewModel = ComparePricesViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1a2c38")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Product header
                    HStack(spacing: 12) {
                        AsyncImage(url: URL(string: product.imageURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color(hex: "2f4553")
                        }
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(product.title)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "fcffff"))
                                .lineLimit(2)
                            
                            Text("Comparing prices across stores")
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "fcffff").opacity(0.6))
                        }
                    }
                    .padding()
                    .background(Color(hex: "2f4553"))
                    
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "1475e0")))
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(Array(viewModel.priceComparisons.enumerated()), id: \.element.id) { index, comparison in
                                    PriceComparisonCard(
                                        comparison: comparison,
                                        isBestPrice: index == 0
                                    )
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Compare Prices")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color(hex: "fcffff").opacity(0.7))
                            .font(.system(size: 24))
                    }
                }
            }
            .task {
                await viewModel.loadPriceComparisons(for: product)
            }
        }
    }
}

struct PriceComparisonCard: View {
    let comparison: PriceComparison
    let isBestPrice: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(comparison.store)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "fcffff"))
                        
                        if isBestPrice {
                            Text("BEST PRICE")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color(hex: "fcffff"))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(hex: "fb3ef4"))
                                .cornerRadius(4)
                        }
                    }
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(comparison.availability == "In Stock" ? Color.green : Color.red)
                            .frame(width: 6, height: 6)
                        
                        Text(comparison.availability)
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "fcffff").opacity(0.7))
                    }
                    
                    if let delivery = comparison.deliveryTime {
                        HStack(spacing: 4) {
                            Image(systemName: "shippingbox")
                                .font(.system(size: 12))
                            Text("Delivery: \(delivery)")
                                .font(.system(size: 13))
                        }
                        .foregroundColor(Color(hex: "fcffff").opacity(0.7))
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(String(format: "%.2f", comparison.price))")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "1475e0"))
                    
                    Button(action: {
                        if let url = URL(string: comparison.url) {
                            // In a real app, open the URL
                            print("Opening: \(url)")
                        }
                    }) {
                        Text("View Deal")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "fcffff"))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(hex: "1475e0"))
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
        }
        .background(isBestPrice ? Color(hex: "1475e0").opacity(0.1) : Color(hex: "2f4553"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isBestPrice ? Color(hex: "1475e0") : Color.clear, lineWidth: 2)
        )
    }
}

