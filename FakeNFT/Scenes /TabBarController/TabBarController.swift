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
            title: NSLocalizedString("Tab.catalog", comment: "Catalog tab bar"),
            image: UIImage(systemName: "square.stack.3d.up.fill"),
            tag: 0
        )

        let cartController = CartAssembly(servicesAssembly: servicesAssembly).build()
        cartController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("Tab.cart", comment: "Cart tab bar"),
            image: UIImage(resource: .basket),
            tag: 1
        )

        viewControllers = [catalogController, cartController]
    }
}
