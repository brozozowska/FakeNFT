//
//  UserDTO.swift
//  FakeNFT
//
//  Created by Yanye Velikanova on 11/5/25.
//

import Foundation

struct UserDTO: Decodable {
    let id: String
    let name: String
    let avatar: URL?
    let rating: String 
    let bio: String?
    let website: URL?
    let nfts: [String]
}
