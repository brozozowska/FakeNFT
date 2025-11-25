//
//  FavoritesService.swift
//  FakeNFT
//
//  Created by Yanye Velikanova on 11/21/25.
//

import Foundation

protocol FavoritesServiceProtocol {
    func isFavorite(id: String) -> Bool
    func toggleFavorite(id: String)
    func allFavorites() -> Set<String>
}

final class FavoritesService: FavoritesServiceProtocol {

    
    private let key = "UserCollectionFavorites"

    private let storage: UserDefaults

    private var favoriteIDs: Set<String> {
        didSet {
            save()
        }
    }

    init(storage: UserDefaults = .standard) {
        self.storage = storage

        if let saved = storage.stringArray(forKey: key) {
            self.favoriteIDs = Set(saved)
        } else {
            self.favoriteIDs = []
        }
    }

    func isFavorite(id: String) -> Bool {
        favoriteIDs.contains(id)
    }

    func toggleFavorite(id: String) {
        if favoriteIDs.contains(id) {
            favoriteIDs.remove(id)
        } else {
            favoriteIDs.insert(id)
        }
    }

    func allFavorites() -> Set<String> {
        favoriteIDs
    }

    private func save() {
        storage.set(Array(favoriteIDs), forKey: key)
    }
}
