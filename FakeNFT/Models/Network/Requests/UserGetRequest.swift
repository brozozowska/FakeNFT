//
//  UserGetRequest.swift
//  FakeNFT
//
//  Created by Yanye Velikanova on 11/5/25.
//

import Foundation

struct UserGetRequest: NetworkRequest {
    let userID: String

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/users/\(userID)")
    }

    var httpMethod: HttpMethod { .get }
    var dto: Dto? { nil }
}
