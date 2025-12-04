import Foundation

struct Nft: Decodable {
    let id: String
    let name: String
    let images: [URL]
    let rating: Int
    let price: Decimal
    let description: String?
    let author: String
    let createdAt: String?
}

