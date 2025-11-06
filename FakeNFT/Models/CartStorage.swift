import Foundation

protocol CartStorage {
    func toggleCart(for nftId: String)
    func isInCart(nftId: String) -> Bool
    func getCartItems() -> [String]
    func clearCart()
}

final class CartStorageImpl: CartStorage {
    private let userDefaults = UserDefaults.standard
    private let cartKey = "cartItems"
    
    func toggleCart(for nftId: String) {
        var cartItems = getCartItems()
        
        if let index = cartItems.firstIndex(of: nftId) {
            cartItems.remove(at: index)
        } else {
            cartItems.append(nftId)
        }
        
        userDefaults.set(cartItems, forKey: cartKey)
        
        NotificationCenter.default.post(name: NSNotification.Name("CartDidChange"), object: nil)
    }
    
    func isInCart(nftId: String) -> Bool {
        return getCartItems().contains(nftId)
    }
    
    func getCartItems() -> [String] {
        return userDefaults.stringArray(forKey: cartKey) ?? []
    }
    
    func clearCart() {
        userDefaults.removeObject(forKey: cartKey)
        NotificationCenter.default.post(name: NSNotification.Name("CartDidChange"), object: nil)
    }
}
