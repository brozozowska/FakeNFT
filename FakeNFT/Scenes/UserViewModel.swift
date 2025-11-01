//
//  UserViewModel.swift
//  FakeNFT
//
//  Created by Yanye Velikanova on 10/31/25.
//

import Foundation

final class UserViewModel {

    // Outputs
    var onNameBio: ((String, String?) -> Void)?
    var onAvatar: ((URL?) -> Void)?
    var onWebsiteVisible: ((Bool) -> Void)?

    private let user: User
    init(user: User) { self.user = user }

    func viewDidLoad() {
        onNameBio?(user.name, user.bio)
        onAvatar?(user.avatar)
        onWebsiteVisible?(user.website != nil)
    }

    var website: URL? { user.website }
}
