import Foundation

final class ToggleFavoriteUseCase {
    private let repository: ProductsRepository

    init(repository: ProductsRepository) {
        self.repository = repository
    }

    func execute(userId: UUID, productId: UUID) async throws {
        let isFav = try await repository.isFavorite(userId: userId, productId: productId)
        if isFav {
            try await repository.removeFromFavorites(userId: userId, productId: productId)
        } else {
            try await repository.addToFavorites(userId: userId, productId: productId)
        }
    }
}
