import UIKit

final class TabBarController: UITabBarController {
    
    var servicesAssembly: ServicesAssembly!
    var viewModelAssembly: ViewModelAssembly!
    
    private let catalogTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.catalog", comment: ""),
        image: UIImage(named: "catalog_Noactive"),
        selectedImage: UIImage(named: "catalog_active")
    )
    
    private let profileTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.profile", comment: ""),
        image: UIImage(named: "profile_Noactive"),
        selectedImage: UIImage(named: "profile_active")
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let catalogViewModel = viewModelAssembly.makeCatalogViewModel()
        let catalogController = CatalogViewController(viewModel: catalogViewModel, servicesAssembly: servicesAssembly)
        let catalogNavigationController = UINavigationController(rootViewController: catalogController)
        catalogNavigationController.tabBarItem = catalogTabBarItem
        
        let profileViewModel = viewModelAssembly.makeProfileViewModel()
        let profileController = ProfileViewController(viewModel: profileViewModel, servicesAssembly: servicesAssembly)
        let profileNavigationController = UINavigationController(rootViewController: profileController)
        profileNavigationController.tabBarItem = profileTabBarItem
        
        viewControllers = [profileNavigationController, catalogNavigationController]
        
        view.backgroundColor = .systemBackground
    }
}
