//
//  APIService.swift
//  Find Deals Fast
//

import Foundation

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int)
    case noData
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let code):
            return "Server error: \(code)"
        case .noData:
            return "No data received"
        }
    }
}

class APIService {
    static let shared = APIService()
    
    private let baseURL = "https://dummyjson.com"
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
    }
    
    func fetchProducts(category: String? = nil, searchQuery: String? = nil, limit: Int = 30, skip: Int = 0) async throws -> [Product] {
        var urlString = "\(baseURL)/products"
        
        if let searchQuery = searchQuery, !searchQuery.isEmpty {
            urlString = "\(baseURL)/products/search?q=\(searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        } else if let category = category, !category.isEmpty {
            urlString = "\(baseURL)/products/category/\(category.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")"
        }
        
        urlString += searchQuery != nil ? "&limit=\(limit)&skip=\(skip)" : "?limit=\(limit)&skip=\(skip)"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.noData
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.serverError(httpResponse.statusCode)
            }
            
            let apiResponse = try JSONDecoder().decode(ProductsResponse.self, from: data)
            return apiResponse.products.map { convertToProduct($0) }
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func fetchProductById(_ id: String) async throws -> Product {
        guard let url = URL(string: "\(baseURL)/products/\(id)") else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.noData
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.serverError(httpResponse.statusCode)
            }
            
            let apiProduct = try JSONDecoder().decode(APIProduct.self, from: data)
            return convertToProduct(apiProduct)
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func fetchCategories() async throws -> [String] {
        guard let url = URL(string: "\(baseURL)/products/categories") else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.noData
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.serverError(httpResponse.statusCode)
            }
            
            let categories = try JSONDecoder().decode([String].self, from: data)
            return categories
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    private func convertToProduct(_ apiProduct: APIProduct) -> Product {
        return Product(
            id: String(apiProduct.id),
            title: apiProduct.title,
            description: apiProduct.description,
            price: apiProduct.price,
            originalPrice: apiProduct.price * (1 + apiProduct.discountPercentage / 100),
            currency: "USD",
            imageURL: apiProduct.thumbnail,
            category: apiProduct.category,
            brand: apiProduct.brand,
            rating: apiProduct.rating,
            reviewCount: nil,
            availability: apiProduct.stock > 0 ? "In Stock" : "Out of Stock",
            store: apiProduct.brand ?? "Online Store"
        )
    }
}

// MARK: - API Response Models
struct ProductsResponse: Codable {
    let products: [APIProduct]
    let total: Int
    let skip: Int
    let limit: Int
}

struct APIProduct: Codable {
    let id: Int
    let title: String
    let description: String
    let price: Double
    let discountPercentage: Double
    let rating: Double
    let stock: Int
    let brand: String?
    let category: String
    let thumbnail: String
    let images: [String]?
}

