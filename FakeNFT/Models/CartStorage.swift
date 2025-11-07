import Foundation

protocol CartStorage {
    func toggleCart(for nftId: String)
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
    
    func toggleCart(for nftId: String) {
        if let index = cartItems.firstIndex(of: nftId) {
            cartItems.remove(at: index)
        } else {
            cartItems.append(nftId)
        }
        
        updateCartOnServer()
        NotificationCenter.default.post(name: NSNotification.Name("CartDidChange"), object: nil)
    }
    
    func isInCart(nftId: String) -> Bool {
        return cartItems.contains(nftId)
    }
    
    func getCartItems() -> [String] {
        return cartItems
    }
    
    func clearCart() {
        cartItems.removeAll()
        updateCartOnServer()
        NotificationCenter.default.post(name: NSNotification.Name("CartDidChange"), object: nil)
    }
    
    private func loadCartFromServer() {
        let request = GetOrderRequest(id: orderId)
        networkClient.send(request: request, type: Order.self) { [weak self] result in
            switch result {
            case .success(let order):
                self?.cartItems = order.nfts
            case .failure(let error):
                print("Failed to load cart: \(error)")
                self?.cartItems = []
            }
        }
    }
    
    private func updateCartOnServer() {
        let nftsString = cartItems.joined(separator: ",")
        let request = PutOrderRequest(id: orderId, nfts: nftsString)
        
        networkClient.send(request: request, type: Order.self) { result in
            switch result {
            case .success(let order):
                print("Cart updated successfully. NFTs in cart: \(order.nfts)")
            case .failure(let error):
                print("Failed to update cart: \(error)")
            }
        }
    }
}
