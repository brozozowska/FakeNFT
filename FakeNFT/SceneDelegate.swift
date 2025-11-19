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
        
        showLaunchScreen()
        
        window?.makeKeyAndVisible()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.showAppInterface()
        }
    }
    
    private func showLaunchScreen() {
        let launchScreenViewController = LaunchScreenViewController()
        window?.rootViewController = launchScreenViewController
    }
    
    private func showAppInterface() {
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        
        if hasSeenOnboarding {
            showMainApp()
        } else {
            showOnboarding()
        }
    }
    
    private func showOnboarding() {
        let onboardingViewController = OnboardingViewController()
        onboardingViewController.onCompletion = { [weak self] in
            self?.completeOnboarding()
        }
        
        UIView.transition(with: window!, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.window?.rootViewController = onboardingViewController
        })
    }
    
    private func showMainApp() {
        let tabBarController = TabBarController()
        tabBarController.servicesAssembly = servicesAssembly
        tabBarController.viewModelAssembly = viewModelAssembly
        tabBarController.setupTabs()
        
        UIView.transition(with: window!, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.window?.rootViewController = tabBarController
        })
    }
    
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        showMainApp()
    }
}
