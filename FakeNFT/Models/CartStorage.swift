import Foundation

protocol CartStorage {
    func toggleCart(for nftId: String, completion: ((Bool) -> Void)?)
    func isInCart(nftId: String) -> Bool
    func getCartItems() -> [String]
    func clearCart()
}

final class CartStorageImpl: CartStorage {
    private let networkClient: NetworkClient
    private let orderId = "1"
    private var cartItems: [String] = []
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
        loadCartFromServer()
    }
    
    func toggleCart(for nftId: String, completion: ((Bool) -> Void)? = nil) {
        print("Toggle cart for NFT: \(nftId). Currently in cart: \(cartItems.contains(nftId))")
        
        let oldState = cartItems.contains(nftId)
        
        if let index = cartItems.firstIndex(of: nftId) {
            cartItems.remove(at: index)
        } else {
            cartItems.append(nftId)
        }
        
        updateCartOnServer { [weak self] success in
            guard let self else { return }
            
            if success {
                NotificationCenter.default.post(name: NSNotification.Name("CartDidChange"), object: nil)
                completion?(true)
            } else {
                if oldState {
                    self.cartItems.append(nftId)
                } else {
                    if let index = self.cartItems.firstIndex(of: nftId) {
                        self.cartItems.remove(at: index)
                    }
                }
                completion?(false)
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
        cartItems.removeAll()
        updateCartOnServer()
        NotificationCenter.default.post(name: NSNotification.Name("CartDidChange"), object: nil)
    }
    
    private func loadCartFromServer() {
        let request = GetOrderRequest(id: orderId)
        print("Loading cart from server...")
        
        networkClient.send(request: request, type: Order.self) { [weak self] result in
            switch result {
            case .success(let order):
                print("Successfully loaded cart. NFTs in cart: \(order.nfts)")
                self?.cartItems = order.nfts
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("CartDidLoadFromServer"),
                        object: nil
                    )
                }
            case .failure(let error):
                print("Failed to load cart: \(error)")
                self?.cartItems = []
            }
        }
    }
    
    private func updateCartOnServer(completion: ((Bool) -> Void)? = nil) {
        let nftsString = cartItems.joined(separator: ",")
        print("Updating cart on server: '\(nftsString)'")
        
        let request = PutOrderRequest(id: orderId, nfts: nftsString)
        
        networkClient.send(request: request, type: Order.self) { result in
            switch result {
            case .success(let order):
                print("Cart updated successfully. NFTs in cart: \(order.nfts.count)")
                completion?(true)
            case .failure(let error):
                print("Failed to update cart: \(error)")
                completion?(false)
            }
        }
    }
}
