import UIKit

final class TabBarController: UITabBarController {
    
    var servicesAssembly: ServicesAssembly!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let servicesAssembly else {
                   assertionFailure("servicesAssembly is nil")
                   return
               }
        
        let catalogController = TestCatalogViewController(servicesAssembly: servicesAssembly)
        catalogController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("Tab.catalog", comment: ""),
            image: UIImage(systemName: "square.stack.3d.up.fill"),
            tag: 0
        )
        
        let statisticsNav = StatisticsAssembly(services: servicesAssembly).build()
        statisticsNav.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "stat_bar_icon")?.withRenderingMode(.alwaysTemplate),
            tag: 1
        )
        
        viewControllers = [catalogController, statisticsNav]
        view.backgroundColor = .systemBackground
    }
}
