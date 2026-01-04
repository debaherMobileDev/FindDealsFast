//
//  WishlistView.swift
//  Find Deals Fast
//

import SwiftUI

struct WishlistView: View {
    @StateObject private var viewModel = WishlistViewModel()
    @EnvironmentObject var userSettings: UserSettings
    @State private var selectedProduct: Product?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1a2c38")
                    .ignoresSafeArea()
                
                if userSettings.wishlist.isEmpty {
                    EmptyWishlistView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.wishlistProducts) { product in
                                ProductCard(product: product, isInWishlist: true)
                                    .onTapGesture {
                                        selectedProduct = product
                                    }
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        await viewModel.refresh(productIds: userSettings.wishlist)
                    }
                }
            }
            .navigationTitle("Wishlist")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedProduct) { product in
                ProductDetailView(product: product)
            }
            .task {
                await viewModel.loadWishlistProducts(productIds: userSettings.wishlist)
            }
            .onChange(of: userSettings.wishlist) { newWishlist in
                Task {
                    await viewModel.loadWishlistProducts(productIds: newWishlist)
                }
            }
        }
    }
}

struct EmptyWishlistView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 80))
                .foregroundColor(Color(hex: "2f4553"))
            
            Text("Your Wishlist is Empty")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(hex: "fcffff"))
            
            Text("Start adding products to your wishlist to keep track of items you love")
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "fcffff").opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

