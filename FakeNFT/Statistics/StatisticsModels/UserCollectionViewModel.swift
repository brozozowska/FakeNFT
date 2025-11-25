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

    // MARK: - Favorites / Cart через сервисы

    private let favoritesService: FavoritesServiceProtocol
    private let cartService: CartServiceProtocol

    // MARK: - Init

    init(
        service: UserCollectionServiceProtocol,
        userID: String,
        favoritesService: FavoritesServiceProtocol = FavoritesService(),
        cartService: CartServiceProtocol = CartService()
    ) {
        self.service = service
        self.userID = userID
        self.favoritesService = favoritesService
        self.cartService = cartService
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
                            isInCart: self.cartService.isInCart(id: nft.id)
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

        favoritesService.toggleFavorite(id: id)
        // обновляем состояние модели из сервиса
        items[index].isFavorite = favoritesService.isFavorite(id: id)
    }

    func toggleCart(at index: Int) {
        guard index < items.count else { return }
        let id = items[index].id

        cartService.toggleInCart(id: id)
        // обновляем состояние модели из сервиса
        items[index].isInCart = cartService.isInCart(id: id)
    }
}
