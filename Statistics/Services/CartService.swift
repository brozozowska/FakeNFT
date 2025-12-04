//
//  CartService.swift
//  FakeNFT
//
//  Created by Yanye Velikanova on 11/21/25.
//

import Foundation

protocol CartServiceProtocol {
    func isInCart(id: String) -> Bool
    func toggleInCart(id: String)
    func allCartItems() -> Set<String>
}

final class CartService: CartServiceProtocol {


    private let key = "UserCollectionCart"

    private let storage: UserDefaults

    private var cartIDs: Set<String> {
        didSet {
            save()
        }
    }

    init(storage: UserDefaults = .standard) {
        self.storage = storage

        if let saved = storage.stringArray(forKey: key) {
            self.cartIDs = Set(saved)
        } else {
            self.cartIDs = []
        }
    }

    func isInCart(id: String) -> Bool {
        cartIDs.contains(id)
    }

    func toggleInCart(id: String) {
        if cartIDs.contains(id) {
            cartIDs.remove(id)
        } else {
            cartIDs.insert(id)
        }
    }

    func allCartItems() -> Set<String> {
        cartIDs
    }

    private func save() {
        storage.set(Array(cartIDs), forKey: key)
    }
}
