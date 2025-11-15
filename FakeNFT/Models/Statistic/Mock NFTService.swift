//
//  Mock NFTService.swift
//  FakeNFT
//
//  Created by Yanye Velikanova on 11/5/25.
//

import Foundation

struct NFTModel {
    let name: String
    let image: String
    let rating: Int
    let price: Double
}

final class NFTService {
    func fetchUserNFTs(completion: @escaping (Result<[NFTModel], Error>) -> Void) {
        // Эмуляция загрузки
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            let mock = [
                NFTModel(name: "Archie", image: "nft1", rating: 2, price: 1.78),
                NFTModel(name: "Emma", image: "nft2", rating: 2, price: 1.78),
                NFTModel(name: "Stella", image: "nft3", rating: 2, price: 1.78),
                NFTModel(name: "Toast", image: "nft4", rating: 2, price: 1.78),
                NFTModel(name: "Zeus", image: "nft5", rating: 2, price: 1.78)
            ]
            completion(.success(mock))
        }
    }
}
