import Foundation

struct AddPostResponseDTO: Decodable {
    let id: Int
    let title: String
    let body: String
    let userId: Int
}
