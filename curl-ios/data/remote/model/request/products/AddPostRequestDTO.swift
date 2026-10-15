import Foundation

struct AddPostRequestDTO: Encodable {
    let title: String
    let body: String
    let userId: Int
}
