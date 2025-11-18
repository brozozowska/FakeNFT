import Foundation

protocol CartStorage {
    func toggleCart(for nftId: String, completion: ((Bool) -> Void)?)
    func isInCart(nftId: String) -> Bool
    func getCartItems() -> [String]
    func clearCart()
}

final class CartStorageImpl: CartStorage {
    private let cartService: CartServiceProtocol
    private var cartItems: [String] = []
    
    init(cartService: CartServiceProtocol) {
        self.cartService = cartService
        loadCartFromServer()
        setupNotifications() // Добавляем подписку на нотификации
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func toggleCart(for nftId: String, completion: ((Bool) -> Void)? = nil) {
        let isCurrentlyInCart = cartItems.contains(nftId)
        
        if isCurrentlyInCart {
            // Удаляем из корзины
            cartService.removeItem(with: nftId) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        // Только отправляем нотификацию, НЕ перезагружаем корзину
                        self?.cartItems.removeAll { $0 == nftId }
                        print("CartStorage: Removed NFT \(nftId) from cart. Current items: \(self?.cartItems ?? [])")
                        NotificationCenter.default.post(name: NSNotification.Name("CartDidChange"), object: nil)
                        completion?(true)
                    case .failure:
                        completion?(false)
                    }
                }
            }
        } else {
            // Добавляем в корзину
            cartService.addItem(with: nftId) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        // Только отправляем нотификацию, НЕ перезагружаем корзину
                        self?.cartItems.append(nftId)
                        print("CartStorage: Added NFT \(nftId) to cart. Current items: \(self?.cartItems ?? [])")
                        NotificationCenter.default.post(name: NSNotification.Name("CartDidChange"), object: nil)
                        completion?(true)
                    case .failure:
                        completion?(false)
                    }
                }
            }
        }
    }
    
    func isInCart(nftId: String) -> Bool {
        cartItems.contains(nftId)
    }
    
    func getCartItems() -> [String] {
        cartItems
    }
    
    func clearCart() {
        cartService.clear { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.cartItems.removeAll()
                    NotificationCenter.default.post(name: NSNotification.Name("CartDidChange"), object: nil)
                case .failure:
                    break
                }
            }
        }
    }
    
    // MARK: - Notifications
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCartDidChange),
            name: NSNotification.Name("CartDidChange"),
            object: nil
        )
    }
    
    @objc private func handleCartDidChange() {
        print("CartStorage: CartDidChange notification received - reloading cart from server")
        // При любой нотификации об изменении корзины перезагружаем данные
        loadCartFromServer()
    }
    
    private func loadCartFromServer() {
        cartService.fetchCartItems { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    self?.cartItems = items.map { $0.id }
                    print("CartStorage: Cart loaded from server: \(items.count) items - \(self?.cartItems ?? [])")
                    
                    // Отправляем только CartDidLoadFromServer при первоначальной загрузке
                    NotificationCenter.default.post(
                        name: NSNotification.Name("CartDidLoadFromServer"),
                        object: nil
                    )
                case .failure(let error):
                    print("CartStorage: Failed to load cart: \(error)")
                    self?.cartItems = []
                }
            }
        }
    }
}
