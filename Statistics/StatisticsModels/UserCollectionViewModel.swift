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

    // MARK: - Favorites

    private let favoritesService: FavoritesServiceProtocol

    // MARK: - Init

    init(
        service: UserCollectionServiceProtocol,
        userID: String,
        favoritesService: FavoritesServiceProtocol = FavoritesService()
    ) {
        self.service = service
        self.userID = userID
        self.favoritesService = favoritesService
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
                            isFavorite: self.favoritesService.isFavorite(id: nft.id),
                            // состояние корзины сейчас локальное, без CartService
                            isInCart: false
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
        guard items.indices.contains(index) else { return }
        let id = items[index].id

        favoritesService.toggleFavorite(id: id)
        items[index].isFavorite = favoritesService.isFavorite(id: id)
    }

    func toggleCart(at index: Int) {
        guard items.indices.contains(index) else { return }
        // Только локальный флаг, CartService не трогаем
        items[index].isInCart.toggle()
    }
}
