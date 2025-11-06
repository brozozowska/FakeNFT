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
        title = nil                      
        imageURL = nft.images.first?.absoluteString
        rating = nil
        priceETH = nil
    }

    var displayTitle: String { title ?? id }
    var priceString: String? {
        guard let priceETH else { return nil }
        return String(format: "%.2f ETH", priceETH)
    }
}
