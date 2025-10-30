import UIKit

final class TabBarController: UITabBarController {
    
    var servicesAssembly: ServicesAssembly!
    
    private let catalogTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.catalog", comment: ""),
        image: UIImage(named: "catalog_Noactive"),
        selectedImage: UIImage(named: "catalog_active"),
        
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let catalogViewModel = servicesAssembly.makeCatalogViewModel()
        let catalogController = CatalogViewController(viewModel: catalogViewModel, servicesAssembly: servicesAssembly)
        let catalogNavigationController = UINavigationController(rootViewController: catalogController)
        catalogNavigationController.tabBarItem = catalogTabBarItem
        
        viewControllers = [catalogNavigationController]
        
        view.backgroundColor = .systemBackground
    }
}
