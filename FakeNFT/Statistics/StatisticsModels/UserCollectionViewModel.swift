//
//  UserCollectionViewModel.swift
//  FakeNFT
//
//  Created by Yanye Velikanova on 11/5/25.
//

import Foundation

final class UserCollectionViewModel {
    var onLoading: ((Bool) -> Void)?
    var onItems: (([UserCollectionCellModel]) -> Void)?
    var onError: ((String) -> Void)?

    private let service: UserCollectionServiceProtocol
    private let userID: String
    private(set) var items: [UserCollectionCellModel] = []

    // MARK: - Favorites / Cart (имитация)

    private static let favoritesKey = "UserCollectionFavorites"
    private static let cartKey = "UserCollectionCart"

    private var favoriteIDs: Set<String>
    private var cartIDs: Set<String>

    init(service: UserCollectionServiceProtocol, userID: String) {
        self.service = service
        self.userID = userID

        let fav = UserDefaults.standard.stringArray(forKey: Self.favoritesKey) ?? []
        let cart = UserDefaults.standard.stringArray(forKey: Self.cartKey) ?? []
        self.favoriteIDs = Set(fav)
        self.cartIDs = Set(cart)
    }

    // MARK: - Load

    func load() {
        onLoading?(true)
        service.fetchUserNFTs(userID: userID) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.onLoading?(false)
                switch result {
                case .success(let nfts):
                    self.items = nfts.map { nft in
                        UserCollectionCellModel(
                            nft: nft,
                            isFavorite: self.favoriteIDs.contains(nft.id),
                            isInCart: self.cartIDs.contains(nft.id)
                        )
                    }
                    self.onItems?(self.items)
                case .failure(let error):
                    self.items = []
                    self.onError?(error.localizedDescription)
                    self.onItems?([])
                }
            }
        }
    }

    // MARK: - Public actions

    func toggleFavorite(at index: Int) {
        guard index < items.count else { return }
        let id = items[index].id

        if favoriteIDs.contains(id) {
            favoriteIDs.remove(id)
            items[index].isFavorite = false
        } else {
            favoriteIDs.insert(id)
            items[index].isFavorite = true
        }

        saveFavorites()
    }

    func toggleCart(at index: Int) {
        guard index < items.count else { return }
        let id = items[index].id

        if cartIDs.contains(id) {
            cartIDs.remove(id)
            items[index].isInCart = false
        } else {
            cartIDs.insert(id)
            items[index].isInCart = true
        }

        saveCart()
    }

    // MARK: - Persistence

    private func saveFavorites() {
        let array = Array(favoriteIDs)
        UserDefaults.standard.set(array, forKey: Self.favoritesKey)
    }

    private func saveCart() {
        let array = Array(cartIDs)
        UserDefaults.standard.set(array, forKey: Self.cartKey)
    }
}
