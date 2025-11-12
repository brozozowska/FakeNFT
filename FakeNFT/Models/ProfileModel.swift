import Foundation

struct Profile: Decodable {
    let name: String
    let avatar: String
    let description: String?
    let website: String
    let nfts: [String]
    let likes: [String]
    let id: String
}

struct ProfileUpdate: Encodable {
    let name: String
    let avatar: String
    let description: String
    let website: String
    let likes: String
}
