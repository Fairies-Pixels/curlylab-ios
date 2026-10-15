import Foundation

final class GetProductsUseCase {
    private let repository: ProductsRepository

    init(repository: ProductsRepository) {
        self.repository = repository
    }

    func execute() async throws -> [Product] {
        try await repository.getProducts()
    }
}
