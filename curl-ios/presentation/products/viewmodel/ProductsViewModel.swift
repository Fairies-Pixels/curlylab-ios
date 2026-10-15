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
    private let getUserFavoritesUseCase: GetUserFavoritesUseCase
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
    private let getReviewsUseCase: GetReviewsUseCase
    private let addReviewUseCase: AddReviewUseCase
    private let updateReviewUseCase: UpdateReviewUseCase
    private let deleteReviewUseCase: DeleteReviewUseCase

    private let currentUserId: UUID = UUID()
    private let currentUsername: String = "user"

    init(
        getProductsUseCase: GetProductsUseCase,
        getUserFavoritesUseCase: GetUserFavoritesUseCase,
        toggleFavoriteUseCase: ToggleFavoriteUseCase,
        getReviewsUseCase: GetReviewsUseCase,
        addReviewUseCase: AddReviewUseCase,
        updateReviewUseCase: UpdateReviewUseCase,
        deleteReviewUseCase: DeleteReviewUseCase
    ) {
        self.getProductsUseCase = getProductsUseCase
        self.getUserFavoritesUseCase = getUserFavoritesUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.getReviewsUseCase = getReviewsUseCase
        self.addReviewUseCase = addReviewUseCase
        self.updateReviewUseCase = updateReviewUseCase
        self.deleteReviewUseCase = deleteReviewUseCase

        Task { await loadInitialData() }
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

    private func loadInitialData() async {
        await loadProducts()
        await loadFavorites()
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

    private func loadFavorites() async {
        do {
            favorites = try await getUserFavoritesUseCase.execute(userId: currentUserId) ?? []
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
        do {
            try await toggleFavoriteUseCase.execute(userId: currentUserId, productId: productId)

            if let index = favorites.firstIndex(where: { $0.productId == productId }) {
                favorites.remove(at: index)
            } else if let product = products.first(where: { $0.id == productId }) {
                favorites.append(
                    Favorite(userId: currentUserId, productId: productId, product: product)
                )
            }
        } catch {
            self.error = error.localizedDescription
        }
    }

    func getCurrentUserId() -> UUID? {
        currentUserId
    }

    func getCurrentUsername() -> String? {
        currentUsername
    }

    func submitReview(productId: UUID, mark: Int, reviewText: String) async {
        do {
            try await addReviewUseCase.execute(
                userId: currentUserId,
                productId: productId,
                mark: mark,
                review: reviewText
            )
            await loadReviews(productId)
        } catch {
            self.error = error.localizedDescription
        }
    }

    func updateReview(productId: UUID, reviewId: UUID, mark: Int, reviewText: String) async {
        do {
            try await updateReviewUseCase.execute(
                userId: currentUserId,
                productId: productId,
                reviewId: reviewId,
                mark: mark,
                review: reviewText
            )
            await loadReviews(productId)
        } catch {
            self.error = error.localizedDescription
        }
    }

    func deleteReview(_ productId: UUID, _ reviewId: UUID) async {
        do {
            try await deleteReviewUseCase.execute(productId: productId, reviewId: reviewId)
            reviews.removeAll { $0.id == reviewId }
        } catch {
            self.error = error.localizedDescription
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
