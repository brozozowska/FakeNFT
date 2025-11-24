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

    init(nft: Nft) {
        id = nft.id
        title = nft.name
        imageURL = nft.images.first?.absoluteString
        rating = nft.rating
        priceETH = nft.price
    }

    var displayTitle: String { title ?? id }

    var priceString: String {
        guard let priceETH else { return "—" }
        return String(format: "%.2f ETH", priceETH)
    }

    var ratingImageName: String {
        guard let rating else { return "0stars" }
        return "\(rating)stars"        
    }
}
