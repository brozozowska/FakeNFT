//
//  User.swift
//  FakeNFT
//
//  Created by Yanye Velikanova on 10/31/25.
//

import Foundation

struct User: Decodable, Hashable {
    let id: String
    let name: String
    let avatar: URL?
    let rating: Int
    let bio: String?
    let website: URL?
    let nftCount: Int
}

extension User {
    init(dto: UserDTO) {
        self.id = dto.id
        self.name = dto.name
        self.avatar = dto.avatar
        self.rating = Int(dto.rating) ?? 0
        self.bio = dto.bio
        self.website = dto.website
        self.nftCount = dto.nfts.count
    }
}
