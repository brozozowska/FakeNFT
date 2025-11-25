//
//  NetworkUsersService.swift
//  FakeNFT
//
//  Created by Yanye Velikanova on 11/16/25.
//

import Foundation

final class NetworkUsersService: UsersService {
    let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func loadUsers(completion: @escaping UsersCompletion) {
        let request = UsersListRequest()
        networkClient.send(request: request, type: [UserDTO].self) { result in
            switch result {
            case .success(let dtos):
                let users = dtos.map(User.init(dto:))
                DispatchQueue.main.async {
                    completion(.success(users))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
