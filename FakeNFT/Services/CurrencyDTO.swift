import Foundation

struct CurrencyDTO: Decodable {
    let id: String
    let title: String
    let name: String
    let image: String
}

extension CurrencyDTO {
    func toDomain() -> Currency {
        Currency(
            id: id,
            title: title,
            name: name,
            imageURL: URL(string: image)
        )
    }
}
