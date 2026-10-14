//
//  ProductsViewModel.swift
//  curl-ios
//
//  Created by lina on 15.10.2026.
//


import Foundation
import Combine

@MainActor
final class ProductsViewModel: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var favorites: [Favorite] = []
    @Published private(set) var reviews: [Review] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: String?
    @Published private(set) var selectedTab: ProductsTab = .allProducts

    @Published private(set) var porosityTag: String?
    @Published private(set) var coloringTag: String?
    @Published private(set) var thicknessTag: String?

    private let getProductsUseCase: GetProductsUseCase
    private let getReviewsUseCase: GetReviewsUseCase

    init(
        getProductsUseCase: GetProductsUseCase,
        getReviewsUseCase: GetReviewsUseCase
    ) {
        self.getProductsUseCase = getProductsUseCase
        self.getReviewsUseCase = getReviewsUseCase

        Task { await loadProducts() }
    }

    var filteredProducts: [Product] {
        products.filter { product in
            let tags = Set(product.tags)
            let porosityMatch = porosityTag == nil || tags.contains(porosityTag!)
            let coloringMatch = coloringTag == nil || tags.contains(coloringTag!)
            let thicknessMatch = thicknessTag == nil || tags.contains(thicknessTag!)
            return porosityMatch && coloringMatch && thicknessMatch
        }
    }

    var favoriteProducts: [Product] {
        products.filter { product in
            favorites.contains { $0.productId == product.id }
        }
    }

    private func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            products = try await getProductsUseCase.execute()
            error = nil
        } catch {
            self.error = error.localizedDescription
        }
    }

    func loadReviews(_ productId: UUID) async {
        isLoading = true
        defer { isLoading = false }

        do {
            reviews = try await getReviewsUseCase.execute(productId: productId)
            error = nil
        } catch {
            self.error = error.localizedDescription
        }
    }

    func toggleFavorite(productId: UUID) async {
        let isCurrentlyFavorite = favorites.contains { $0.productId == productId }
        if isCurrentlyFavorite {
            favorites = favorites.filter { $0.productId != productId }
        } else {
            favorites.append(Favorite(userId: UUID(), productId: productId))
        }
    }

    func toggleTag(category: String, tag: String) {
        switch category {
        case "Пористость":
            porosityTag = porosityTag == tag ? nil : tag
        case "Окрашенность":
            coloringTag = coloringTag == tag ? nil : tag
        case "Толщина":
            thicknessTag = thicknessTag == tag ? nil : tag
        default:
            break
        }
    }

    func selectTab(_ tab: ProductsTab) {
        selectedTab = tab
    }

    func clearAllFilters() {
        porosityTag = nil
        coloringTag = nil
        thicknessTag = nil
    }

    func clearError() {
        error = nil
    }
}

enum ProductsTab {
    case allProducts
    case favoriteProducts
}