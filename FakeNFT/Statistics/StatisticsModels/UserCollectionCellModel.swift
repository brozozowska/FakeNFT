//
//  UserCollectionCellModel.swift
//  FakeNFT
//
//  Created by Yanye Velikanova on 11/5/25.
//

import Foundation

struct UserCollectionCellModel {
    let id: String
    let title: String?
    let imageURL: String?
    let rating: Int?
    let priceETH: Double?

    // состояние
    var isFavorite: Bool
    var isInCart: Bool

    init(nft: Nft) {
        id = nft.id
        title = nft.name
        imageURL = nft.images.first?.absoluteString
        rating = nft.rating
        priceETH = nft.price
        isFavorite = false
        isInCart = false
    }

    init(nft: Nft, isFavorite: Bool, isInCart: Bool) {
        id = nft.id
        title = nft.name
        imageURL = nft.images.first?.absoluteString
        rating = nft.rating
        priceETH = nft.price
        self.isFavorite = isFavorite
        self.isInCart = isInCart
    }

    var displayTitle: String { title ?? id }

    var priceString: String? {
        guard let priceETH else { return nil }
        return String(format: "%.2f ETH", priceETH)
    }

    var ratingImageName: String {
        switch rating ?? 0 {
        case 1: return "1star"
        case 2: return "2stars"
        case 3: return "3stars"
        case 4: return "4stars"
        case 5: return "5stars"
        default: return "zero"
        }
    }
}
