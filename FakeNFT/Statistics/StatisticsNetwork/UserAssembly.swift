//
//  UserAssembly.swift
//  FakeNFT
//
//  Created by Yanye Velikanova on 10/31/25.
//

import UIKit

final class UserAssembly {
    func build(user: User) -> UIViewController {
        let vm = UserViewModel(user: user)
        return UserViewController(viewModel: vm)
    }
}
