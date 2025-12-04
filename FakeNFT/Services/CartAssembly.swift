import UIKit

final class CartAssembly {
    private let servicesAssembly: ServicesAssembly

    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
    }

    func build() -> UIViewController {
        let cartService = servicesAssembly.cartService
        let viewModel = CartViewModel(cartService: cartService)
        let viewController = CartViewController(
            viewModel: viewModel,
            currencyService: servicesAssembly.currencyService,
            cartService: cartService
        )
        return UINavigationController(rootViewController: viewController)
    }
}
