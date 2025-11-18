import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    let servicesAssembly = ServicesAssembly(
        networkClient: DefaultNetworkClient(),
        nftStorage: NftStorageImpl()
    )
    
    lazy var viewModelAssembly = ViewModelAssembly(servicesAssembly: servicesAssembly)
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        
        if hasSeenOnboarding {
            showMainApp()
        } else {
            showOnboarding()
        }
        
        window?.makeKeyAndVisible()
    }
    
    private func showOnboarding() {
        let onboardingViewController = OnboardingViewController()
        window?.rootViewController = onboardingViewController
    }
    
    private func showMainApp() {
        let tabBarController = TabBarController()
        tabBarController.servicesAssembly = servicesAssembly
        tabBarController.viewModelAssembly = viewModelAssembly
        window?.rootViewController = tabBarController
    }
    
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        showMainApp()
    }
}
