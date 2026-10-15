import Foundation

final class GetReviewsUseCase {
    private let repository: ProductsRepository

    init(repository: ProductsRepository) {
        self.repository = repository
    }

    func execute(productId: UUID) async throws -> [Review] {
        try await repository.getReviews(productId: productId)
    }
}
