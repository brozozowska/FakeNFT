import Foundation

struct CartItem: Identifiable, Equatable {
    let id: String
    let title: String
    let imageURL: URL?
    let rating: Int
    let price: Decimal
}
