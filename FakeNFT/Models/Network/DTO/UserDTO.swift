//
//  UserDTO.swift
//  FakeNFT
//
//  Created by Yanye Velikanova on 11/5/25.
//

import Foundation

struct UserDTO: Decodable {
    let id: String
    let name: String?
    let description: String?
    let website: String?
    let avatar: String?
    /// список id NFT пользователя
    let nfts: [String]
}
