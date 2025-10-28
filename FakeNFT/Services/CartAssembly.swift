import UIKit

final class CartAssembly {
    func build() -> UIViewController {
        let service = CartServiceMock()
        let viewModel = CartViewModel(cartService: service)
        let viewController = CartViewController(viewModel: viewModel)
        return UINavigationController(rootViewController: viewController)
    }
}
