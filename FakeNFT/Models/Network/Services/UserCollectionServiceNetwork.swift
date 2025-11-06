//
//  UserCollectionServiceNetwork.swift
//  FakeNFT
//
//  Created by Yanye Velikanova on 11/5/25.
//

import Foundation

protocol UserCollectionServiceProtocol {
    func fetchUserNFTs(userID: String, completion: @escaping (Result<[Nft], Error>) -> Void)
}

final class UserCollectionServiceNetwork: UserCollectionServiceProtocol {
    private let networkClient: NetworkClient
    private let nftService: NftService

    init(networkClient: NetworkClient, nftService: NftService) {
        self.networkClient = networkClient
        self.nftService = nftService
    }

    func fetchUserNFTs(userID: String, completion: @escaping (Result<[Nft], Error>) -> Void) {
        let request = UserGetRequest(userID: userID)

        networkClient.send(request: request, type: UserDTO.self) { [weak self] result in
            switch result {
            case .success(let user):
                self?.loadNFTs(ids: user.nfts, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - private
    private func loadNFTs(ids: [String], completion: @escaping (Result<[Nft], Error>) -> Void) {
        guard !ids.isEmpty else {
            completion(.success([]))
            return
        }

        let group = DispatchGroup()
        var items: [Nft] = []
        var firstError: Error?
        let sync = DispatchQueue(label: "user-nfts-sync-queue")

        for id in ids {
            group.enter()
            nftService.loadNft(id: id) { result in
                switch result {
                case .success(let nft):
                    sync.async { items.append(nft); group.leave() }
                case .failure(let error):
                    sync.async { if firstError == nil { firstError = error }; group.leave() }
                }
            }
        }

        group.notify(queue: .global()) {
            if let error = firstError {
                completion(.failure(error))
            } else {
                // сохранить порядок как в ids
                let dict = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
                let ordered = ids.compactMap { dict[$0] }
                completion(.success(ordered))
            }
        }
    }
}
