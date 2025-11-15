//
//  UsersService.swift
//  FakeNFT
//
//  Created by Yanye Velikanova on 10/31/25.
//

import Foundation

typealias UsersCompletion = (Result<[User], Error>) -> Void

protocol UsersService {
    func loadUsers(completion: @escaping UsersCompletion)
}


final class UsersServiceMock: UsersService {
    private let queue = DispatchQueue(label: "users.service.mock", qos: .userInitiated)

    func loadUsers(completion: @escaping UsersCompletion) {
        queue.asyncAfter(deadline: .now() + 0.6) {
            let users: [User] = [
                .init(id: "1", name: "Alex",
                      avatar: URL(string:"https://picsum.photos/seed/1/80"),
                      rating: 112,
                      bio: "Дизайнер из Казани, люблю цифровое искусство и бейглы.",
                      website: URL(string:"https://apple.com"),
                      nftCount: 112),
                .init(id: "2", name: "Bill",  avatar: nil, rating: 98, bio: nil, website: nil, nftCount: 98),
                .init(id: "3", name: "Alla",  avatar: nil, rating: 72, bio: nil, website: nil, nftCount: 72),
                .init(id: "4", name: "Mads",
                      avatar: URL(string:"https://picsum.photos/seed/4/80"),
                      rating: 71, bio: nil, website: nil, nftCount: 71),
                .init(id: "5", name: "Timothée",
                      avatar: URL(string:"https://picsum.photos/seed/5/80"),
                      rating: 51, bio: nil, website: nil, nftCount: 51),
            ]
            DispatchQueue.main.async { completion(.success(users)) }
        }
    }
}
