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
        
        let catalogViewModel = viewModelAssembly.makeCatalogViewModel()
        let catalogController = CatalogViewController(viewModel: catalogViewModel, servicesAssembly: servicesAssembly)
        let catalogNavigationController = UINavigationController(rootViewController: catalogController)
        catalogNavigationController.tabBarItem = catalogTabBarItem
        
        let profileViewModel = viewModelAssembly.makeProfileViewModel()
        let profileController = ProfileViewController(
            viewModel: profileViewModel,
            viewModelFactory: viewModelAssembly
        )
        let profileNavigationController = UINavigationController(rootViewController: profileController)
        profileNavigationController.tabBarItem = profileTabBarItem
        
        viewControllers = [profileNavigationController, catalogNavigationController]
        
        view.backgroundColor = .systemBackground
    }
}
