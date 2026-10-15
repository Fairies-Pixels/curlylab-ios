import Foundation

final class ProductRepositoryImpl: ProductsRepository {
    static let shared = ProductRepositoryImpl()

    private let apiClient: ApiService

    private var localFavorites: [UUID: Set<UUID>] = [:]
    private var localReviews: [UUID: [Review]] = [:]

    init(apiClient: ApiService = .shared) {
        self.apiClient = apiClient
    }

    func getProducts() async throws -> [Product] {
        let response: ProductsResponseDTO = try await apiClient.get(
            "/products",
            queryItems: [
                URLQueryItem(name: "limit", value: "30"),
                URLQueryItem(
                    name: "select",
                    value: "id,title,description,category,price,rating,brand,thumbnail,tags"
                )
            ]
        )

        return response.products.map { dto in
            Product(
                id: UUID(),
                name: dto.title,
                description: dto.description,
                tags: dto.tags ?? [dto.category],
                imageUrlString: dto.thumbnail
            )
        }
    }

    func getProductById(_ productId: UUID) async throws -> Product {
        let all = try await getProducts()
        guard let product = all.first(where: { $0.id == productId }) else {
            throw ApiError.unknown
        }
        return product
    }

    func getUserFavorites(userId: UUID) async throws -> [Favorite]? {
        let ids = localFavorites[userId] ?? []
        let all = try await getProducts()
        return all
            .filter { ids.contains($0.id) }
            .map { Favorite(userId: userId, productId: $0.id, product: $0) }
    }

    func isFavorite(userId: UUID, productId: UUID) async throws -> Bool {
        localFavorites[userId]?.contains(productId) ?? false
    }

    func addToFavorites(userId: UUID, productId: UUID) async throws {
        localFavorites[userId, default: []].insert(productId)
    }

    func removeFromFavorites(userId: UUID, productId: UUID) async throws {
        localFavorites[userId]?.remove(productId)
    }

    func getReviews(productId: UUID) async throws -> [Review] {
        localReviews[productId] ?? []
    }

    func addReview(userId: UUID, productId: UUID, mark: Int, review: String) async throws {
        let request = AddPostRequestDTO(
            title: "Review for \(productId)",
            body: review,
            userId: 1
        )

        let response: AddPostResponseDTO = try await apiClient.post(
            "/posts/add",
            body: request
        )

        let newReview = Review(
            id: UUID(),
            productId: productId,
            userId: userId,
            userName: "user",
            rating: mark,
            comment: response.body,
            createdAt: Date()
        )
        localReviews[productId, default: []].insert(newReview, at: 0)
    }

    func updateReview(
        userId: UUID,
        productId: UUID,
        reviewId: UUID,
        mark: Int,
        review: String
    ) async throws {
        guard var reviews = localReviews[productId],
              let index = reviews.firstIndex(where: { $0.id == reviewId }) else {
            return
        }

        let old = reviews[index]
        reviews[index] = Review(
            id: old.id,
            productId: old.productId,
            userId: old.userId,
            userName: old.userName,
            rating: mark,
            comment: review,
            createdAt: old.createdAt
        )
        localReviews[productId] = reviews
    }

    func deleteReview(productId: UUID, reviewId: UUID) async throws {
        localReviews[productId]?.removeAll { $0.id == reviewId }
    }
}
