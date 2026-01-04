//
//  HomeView.swift
//  Find Deals Fast
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = ProductViewModel()
    @EnvironmentObject var userSettings: UserSettings
    @State private var searchText = ""
    @State private var showingCategories = false
    @State private var selectedProduct: Product?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1a2c38")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search bar
                    HStack {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color(hex: "fcffff").opacity(0.6))
                            
                            TextField("Search products...", text: $searchText)
                                .foregroundColor(Color(hex: "fcffff"))
                                .onChange(of: searchText) { newValue in
                                    Task {
                                        try? await Task.sleep(nanoseconds: 500_000_000)
                                        if searchText == newValue {
                                            await viewModel.search(newValue)
                                        }
                                    }
                                }
                        }
                        .padding(12)
                        .background(Color(hex: "2f4553"))
                        .cornerRadius(12)
                        
                        Button(action: {
                            showingCategories = true
                        }) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.system(size: 24))
                                .foregroundColor(Color(hex: "1475e0"))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    
                    // Category chip
                    if let category = viewModel.selectedCategory {
                        HStack {
                            HStack {
                                Text(category.capitalized)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "fcffff"))
                                
                                Button(action: {
                                    Task {
                                        await viewModel.selectCategory(nil)
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Color(hex: "fcffff").opacity(0.7))
                                        .font(.system(size: 16))
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(hex: "1475e0"))
                            .cornerRadius(16)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                    
                    // Products list
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.products) { product in
                                ProductCard(product: product, isInWishlist: userSettings.isInWishlist(product.id))
                                    .onTapGesture {
                                        selectedProduct = product
                                    }
                                    .onAppear {
                                        if product.id == viewModel.products.last?.id {
                                            Task {
                                                await viewModel.loadMore()
                                            }
                                        }
                                    }
                            }
                            
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "1475e0")))
                                    .padding()
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
            .navigationTitle("Find Deals")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(Color(hex: "1475e0"))
                    }
                }
            }
            .sheet(item: $selectedProduct) { product in
                ProductDetailView(product: product)
            }
            .sheet(isPresented: $showingCategories) {
                CategorySelectionView(selectedCategory: viewModel.selectedCategory) { category in
                    Task {
                        await viewModel.selectCategory(category)
                    }
                    showingCategories = false
                }
            }
            .task {
                if viewModel.products.isEmpty {
                    await viewModel.loadProducts()
                }
            }
        }
    }
}

struct ProductCard: View {
    let product: Product
    let isInWishlist: Bool
    @EnvironmentObject var userSettings: UserSettings
    
    var body: some View {
        HStack(spacing: 12) {
            // Product image
            AsyncImage(url: URL(string: product.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color(hex: "2f4553")
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "1475e0")))
                    )
            }
            .frame(width: 100, height: 100)
            .cornerRadius(12)
            
            // Product info
            VStack(alignment: .leading, spacing: 6) {
                Text(product.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "fcffff"))
                    .lineLimit(2)
                
                Text(product.brand ?? product.store)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "fcffff").opacity(0.6))
                
                Spacer()
                
                HStack(alignment: .bottom, spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        if let discount = product.discount {
                            Text("\(discount)% OFF")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color(hex: "fb3ef4"))
                        }
                        
                        Text("$\(String(format: "%.2f", product.price))")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "1475e0"))
                        
                        if let originalPrice = product.originalPrice, product.discount != nil {
                            Text("$\(String(format: "%.2f", originalPrice))")
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "fcffff").opacity(0.5))
                                .strikethrough()
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            userSettings.toggleWishlist(product.id)
                        }
                    }) {
                        Image(systemName: isInWishlist ? "heart.fill" : "heart")
                            .font(.system(size: 20))
                            .foregroundColor(isInWishlist ? Color(hex: "fb3ef4") : Color(hex: "fcffff").opacity(0.6))
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .padding(12)
        .background(Color(hex: "2f4553"))
        .cornerRadius(16)
    }
}

struct CategorySelectionView: View {
    let selectedCategory: String?
    let onSelect: (String?) -> Void
    @Environment(\.dismiss) var dismiss
    @StateObject private var dataFetcher = DataFetcher.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1a2c38")
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        CategoryRow(
                            title: "All Categories",
                            isSelected: selectedCategory == nil,
                            action: {
                                onSelect(nil)
                            }
                        )
                        
                        ForEach(dataFetcher.categories, id: \.self) { category in
                            CategoryRow(
                                title: category.capitalized,
                                isSelected: selectedCategory == category,
                                action: {
                                    onSelect(category)
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "1475e0"))
                }
            }
            .task {
                if dataFetcher.categories.isEmpty {
                    await dataFetcher.loadCategories()
                }
            }
        }
    }
}

struct CategoryRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(Color(hex: "fcffff"))
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "1475e0"))
                }
            }
            .padding()
            .background(isSelected ? Color(hex: "1475e0").opacity(0.2) : Color(hex: "2f4553"))
            .cornerRadius(12)
        }
    }
}

