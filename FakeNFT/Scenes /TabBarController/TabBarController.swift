import UIKit

final class TabBarController: UITabBarController {

    var servicesAssembly: ServicesAssembly!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupTabBar()
    }
    
    private func setupTabBar() {
        let catalogController = TestCatalogViewController(
            servicesAssembly: servicesAssembly
        )
        catalogController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("Tab.catalog", comment: ""),
            image: UIImage(systemName: "square.stack.3d.up.fill"),
            tag: 0
        )

        let cartController = CartAssembly().build()
        cartController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("Tab.cart", comment: ""),
            image: UIImage(resource: .basket),
            tag: 1
        )

        viewControllers = [catalogController, cartController]
    }
}
