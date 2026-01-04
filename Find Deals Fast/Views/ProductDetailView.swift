//
//  ProductDetailView.swift
//  Find Deals Fast
//

import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userSettings: UserSettings
    @State private var showingComparePrices = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1a2c38")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Product image
                        AsyncImage(url: URL(string: product.imageURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Color(hex: "2f4553")
                                .aspectRatio(1, contentMode: .fit)
                                .overlay(
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "1475e0")))
                                )
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                        .cornerRadius(20)
                        
                        // Product info
                        VStack(alignment: .leading, spacing: 12) {
                            // Brand and category
                            HStack {
                                if let brand = product.brand {
                                    Text(brand)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(hex: "1475e0"))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color(hex: "1475e0").opacity(0.2))
                                        .cornerRadius(8)
                                }
                                
                                Text(product.category.capitalized)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "fcffff").opacity(0.7))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color(hex: "2f4553"))
                                    .cornerRadius(8)
                                
                                Spacer()
                            }
                            
                            // Title
                            Text(product.title)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(hex: "fcffff"))
                            
                            // Rating
                            if let rating = product.rating {
                                HStack(spacing: 4) {
                                    ForEach(0..<5) { index in
                                        Image(systemName: index < Int(rating.rounded()) ? "star.fill" : "star")
                                            .foregroundColor(Color(hex: "fb3ef4"))
                                            .font(.system(size: 14))
                                    }
                                    
                                    Text(String(format: "%.1f", rating))
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(hex: "fcffff").opacity(0.7))
                                }
                            }
                            
                            // Price
                            HStack(alignment: .bottom, spacing: 12) {
                                Text("$\(String(format: "%.2f", product.price))")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(Color(hex: "1475e0"))
                                
                                if let originalPrice = product.originalPrice, let discount = product.discount {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("$\(String(format: "%.2f", originalPrice))")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color(hex: "fcffff").opacity(0.5))
                                            .strikethrough()
                                        
                                        Text("\(discount)% OFF")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(Color(hex: "fb3ef4"))
                                    }
                                }
                                
                                Spacer()
                            }
                            
                            // Availability
                            HStack {
                                Circle()
                                    .fill(product.availability == "In Stock" ? Color.green : Color.red)
                                    .frame(width: 8, height: 8)
                                
                                Text(product.availability)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "fcffff").opacity(0.8))
                            }
                            
                            Divider()
                                .background(Color(hex: "2f4553"))
                                .padding(.vertical, 8)
                            
                            // Description
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Description")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color(hex: "fcffff"))
                                
                                Text(product.description)
                                    .font(.system(size: 15))
                                    .foregroundColor(Color(hex: "fcffff").opacity(0.8))
                                    .lineSpacing(4)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Action buttons
                        VStack(spacing: 12) {
                            Button(action: {
                                showingComparePrices = true
                            }) {
                                HStack {
                                    Image(systemName: "chart.bar.fill")
                                    Text("Compare Prices")
                                        .font(.system(size: 17, weight: .semibold))
                                }
                                .foregroundColor(Color(hex: "fcffff"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(hex: "1475e0"))
                                .cornerRadius(16)
                            }
                            
                            Button(action: {
                                withAnimation {
                                    userSettings.toggleWishlist(product.id)
                                }
                            }) {
                                HStack {
                                    Image(systemName: userSettings.isInWishlist(product.id) ? "heart.fill" : "heart")
                                    Text(userSettings.isInWishlist(product.id) ? "Remove from Wishlist" : "Add to Wishlist")
                                        .font(.system(size: 17, weight: .semibold))
                                }
                                .foregroundColor(Color(hex: "fcffff"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(hex: "2f4553"))
                                .cornerRadius(16)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                    .padding(.top)
                }
            }
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
            .sheet(isPresented: $showingComparePrices) {
                ComparePricesView(product: product)
            }
        }
    }
}

