import Foundation

final class CartServiceMock: CartServiceProtocol {
    private var items: [CartItem] = [
        CartItem(id: "93", title: "NFT #93", imageURL: URL(string: "https://picsum.photos/id/93/300/300"), rating: 4, price: 0.23),
        CartItem(id: "94", title: "NFT #94", imageURL: URL(string: "https://picsum.photos/id/94/300/300"), rating: 5, price: 0.47),
        CartItem(id: "95", title: "NFT #95", imageURL: URL(string: "https://picsum.photos/id/95/300/300"), rating: 3, price: 0.12),
        CartItem(id: "96", title: "NFT #96", imageURL: URL(string: "https://picsum.photos/id/96/300/300"), rating: 2, price: 0.78),
        CartItem(id: "97", title: "NFT #97", imageURL: URL(string: "https://picsum.photos/id/97/300/300"), rating: 5, price: 1.05),
        CartItem(id: "98", title: "NFT #98", imageURL: URL(string: "https://picsum.photos/id/98/300/300"), rating: 1, price: 0.05)
    ]
    
    func fetchCartItems(completion: @escaping (Result<[CartItem], Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.4) { [items] in
            completion(.success(items))
        }
    }
    
    func removeItem(with id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items.remove(at: index)
            completion(.success(()))
        } else {
            completion(.failure(NSError(domain: "CartServiceMock", code: 404, userInfo: [NSLocalizedDescriptionKey: "Item not found"])))
        }
    }
    
    func clear(completion: @escaping (Result<Void, Error>) -> Void) {
        items.removeAll()
        completion(.success(()))
    }
}
