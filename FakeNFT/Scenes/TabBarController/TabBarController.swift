import UIKit

final class TabBarController: UITabBarController {
    
    var servicesAssembly: ServicesAssembly!
    var viewModelAssembly: ViewModelAssembly!
    
    private var isInitialized = false
    
    private let catalogTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.catalog", comment: ""),
        image: UIImage(resource: .catalogNoactive),
        selectedImage: UIImage(resource: .catalogActive)
    )
    
    private let profileTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.profile", comment: ""),
        image: UIImage(resource: .profileNoactive),
        selectedImage: UIImage(resource: .profileActive)
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupViewControllers()
    }
    
    private func setupViewControllers() {
        guard !isInitialized else { return }
        
        // Проверяем, что зависимости установлены
        guard servicesAssembly != nil, viewModelAssembly != nil else {
            print("Dependencies not set in TabBarController")
            return
        }
        
        // Profile
        let profileViewModel = viewModelAssembly.makeProfileViewModel()
        let profileController = ProfileViewController(
            viewModel: profileViewModel,
            viewModelFactory: viewModelAssembly
        )
        let profileNavigationController = UINavigationController(rootViewController: profileController)
        profileNavigationController.tabBarItem = profileTabBarItem
        
        // Catalog
        let catalogViewModel = viewModelAssembly.makeCatalogViewModel()
        let catalogController = CatalogViewController(
            viewModel: catalogViewModel,
            servicesAssembly: servicesAssembly
        )
        let catalogNavigationController = UINavigationController(rootViewController: catalogController)
        catalogNavigationController.tabBarItem = catalogTabBarItem
        
        // Cart
        let cartNavigationController = CartAssembly(servicesAssembly: servicesAssembly).build()
        cartNavigationController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("Tab.cart", comment: "Cart tab bar"),
            image: UIImage(resource: .basket),
            tag: 1
        )
        
        viewControllers = [profileNavigationController, catalogNavigationController, cartNavigationController]
        isInitialized = true
    }
    
    // Метод для принудительной переустановки контроллеров после установки зависимостей
    func setupTabs() {
        setupViewControllers()
    }
}
