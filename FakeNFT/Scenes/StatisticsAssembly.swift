//
//  StatisticsAssembly.swift
//  FakeNFT
//
//  Created by Yanye Velikanova on 10/31/25.
//

import UIKit

final class StatisticsAssembly {
    private let services: ServicesAssembly
    init(services: ServicesAssembly) { self.services = services }

    func build() -> UIViewController {
        // пока моки; позже подменим на сетевой сервис
        let vm = StatisticsViewModel(service: UsersServiceMock())
        let vc = StatisticsViewController(viewModel: vm)
        return UINavigationController(rootViewController: vc)
    }
}
