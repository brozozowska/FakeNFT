//
//  UsersListRequest.swift
//  FakeNFT
//
//  Created by Yanye Velikanova on 11/16/25.
//

import Foundation

struct UsersListRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/users")
    }

    var httpMethod: HttpMethod { .get }
    var dto: Dto? { nil }
}
