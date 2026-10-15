import Foundation

final class GetUserFavoritesUseCase {
    private let repository: ProductsRepository

    init(repository: ProductsRepository) {
        self.repository = repository
    }

    func execute(userId: UUID) async throws -> [Favorite]? {
        try await repository.getUserFavorites(userId: userId)
    }
}
