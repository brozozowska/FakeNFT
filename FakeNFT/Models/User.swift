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
