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

    init(service: UserCollectionServiceProtocol, userID: String) {
        self.service = service
        self.userID = userID
    }

    func load() {
        onLoading?(true)
        service.fetchUserNFTs(userID: userID) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.onLoading?(false)
                switch result {
                case .success(let nfts):
                    self.items = nfts.map(UserCollectionCellModel.init)
                    self.onItems?(self.items)
                case .failure(let error):
                    self.items = []
                    self.onError?(error.localizedDescription)
                    self.onItems?([])
                }
            }
        }
    }
}
