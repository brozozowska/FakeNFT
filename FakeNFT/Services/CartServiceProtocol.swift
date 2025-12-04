import Foundation

protocol CartServiceProtocol: AnyObject {
    func fetchCartItems(completion: @escaping (Result<[CartItem], Error>) -> Void)
    
    func removeItem(with id: String, completion: @escaping (Result<Void, Error>) -> Void)
    
    func clear(completion: @escaping (Result<Void, Error>) -> Void)
    
    func addItem(with id: String, completion: @escaping (Result<Void, Error>) -> Void)
}
