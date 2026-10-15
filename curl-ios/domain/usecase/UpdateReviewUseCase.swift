import Foundation

final class UpdateReviewUseCase {
    private let repository: ProductsRepository

    init(repository: ProductsRepository) {
        self.repository = repository
    }

    func execute(userId: UUID, productId: UUID, reviewId: UUID, mark: Int, review: String) async throws {
        try await repository.updateReview(
            userId: userId,
            productId: productId,
            reviewId: reviewId,
            mark: mark,
            review: review
        )
    }
}
