import UIKit

final class TabBarController: UITabBarController {
    
    var servicesAssembly: ServicesAssembly! {
        didSet {
            setupViewControllersIfNeeded()
        }
    }
    
    var viewModelAssembly: ViewModelAssembly! {
        didSet {
            setupViewControllersIfNeeded()
        }
    }
    
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
        setupViewControllersIfNeeded()
    }
    
    private func setupViewControllersIfNeeded() {
        guard !isInitialized else { return }
        

        guard servicesAssembly != nil,
              viewModelAssembly != nil,
              isViewLoaded else {
            return
        }
        
        setupViewControllers()
    }
    
    private func setupViewControllers() {
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
        
        // MARK: - Statistics (Рейтинг пользователей)
        let statisticsNavigationController = StatisticsAssembly(
            services: servicesAssembly
        ).build()

        statisticsNavigationController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("Tab.statistics", comment: "Statistics tab bar"),
            image: UIImage(resource: .statisticsNoactive),     // неактивная иконка
            selectedImage: UIImage(resource: .statisticsActive) // активная иконка
        )

        
      
        viewControllers = [
            catalogNavigationController,
            cartNavigationController,
            statisticsNavigationController,
            profileNavigationController
        ]
        
        isInitialized = true
    }
}
