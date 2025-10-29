import Foundation

struct OrderDTO: Decodable {
    let id: String
    let nfts: [String]
}
