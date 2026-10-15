import Foundation

final class AddReviewUseCase {
    private let repository: ProductsRepository

    init(repository: ProductsRepository) {
        self.repository = repository
    }

    func execute(userId: UUID, productId: UUID, mark: Int, review: String) async throws {
        try await repository.addReview(
            userId: userId,
            productId: productId,
            mark: mark,
            review: review
        )
    }
}
