import UIKit

final class TabBarController: UITabBarController {
    
    var servicesAssembly: ServicesAssembly!
    var viewModelAssembly: ViewModelAssembly!
    
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
        
        // Catalog
        let catalogViewModel = viewModelAssembly.makeCatalogViewModel()
        let catalogController = CatalogViewController(viewModel: catalogViewModel, servicesAssembly: servicesAssembly)
        let catalogNavigationController = UINavigationController(rootViewController: catalogController)
        catalogNavigationController.tabBarItem = catalogTabBarItem
        
        // Cart
        let cartNavigationController = CartAssembly().build()
        cartNavigationController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("Tab.cart", comment: ""),
            image: UIImage(systemName: "cart"),
            selectedImage: UIImage(systemName: "cart.fill")
        )
        
        // Profile
        let profileViewModel = viewModelAssembly.makeProfileViewModel()
        let profileController = ProfileViewController(
            viewModel: profileViewModel,
            viewModelFactory: viewModelAssembly
        )
        let profileNavigationController = UINavigationController(rootViewController: profileController)
        profileNavigationController.tabBarItem = profileTabBarItem
        
        viewControllers = [catalogNavigationController, cartNavigationController, profileNavigationController]
        
        view.backgroundColor = .systemBackground
    }
}
