//
//  UserViewModel.swift
//  FakeNFT
//
//  Created by Yanye Velikanova on 10/31/25.
//

import Foundation

final class UserViewModel {

    // MARK: - Outputs 
    var onNameBio: ((String, String) -> Void)?
    var onAvatar: ((URL?) -> Void)?
    var onWebsiteVisible: ((Bool) -> Void)?
    var onNftCount: ((Int) -> Void)?

    // MARK: - State
    private let user: User
    let userID: String              
    private(set) var website: URL?

    // MARK: - Init
    init(user: User) {
        self.user = user
        self.userID = user.id
        self.website = user.website
    }

    func viewDidLoad() {
        onNameBio?(user.name, user.bio ?? "")

        onAvatar?(user.avatar)

        onWebsiteVisible?(website != nil)

        onNftCount?(user.nftCount)
    }
}
