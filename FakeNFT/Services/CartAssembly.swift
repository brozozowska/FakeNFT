import UIKit

final class CartAssembly {
    private let servicesAssembly: ServicesAssembly

    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
    }

    func build() -> UIViewController {
        let service = servicesAssembly.cartService
        let viewModel = CartViewModel(cartService: service)
        let viewController = CartViewController(viewModel: viewModel)
        return UINavigationController(rootViewController: viewController)
    }
}
