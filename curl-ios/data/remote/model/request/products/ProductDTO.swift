import Foundation

struct ProductDTO: Decodable {
    let id: Int
    let title: String
    let description: String
    let category: String
    let price: Double
    let rating: Double
    let brand: String?
    let thumbnail: String
    let tags: [String]?

}


