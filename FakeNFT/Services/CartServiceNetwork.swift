import Foundation

final class CartServiceNetwork: CartServiceProtocol {
    private let networkClient: NetworkClient
    private let nftService: NftService
    
    private var currentIds: [String] = []
    
    init(networkClient: NetworkClient, nftService: NftService) {
        self.networkClient = networkClient
        self.nftService = nftService
    }
    
    func fetchCartItems(completion: @escaping (Result<[CartItem], Error>) -> Void) {
        assert(Thread.isMainThread, "CartServiceNetwork.fetchCartItems must be called on the main thread")
        
        let request = OrderGetRequest()
        networkClient.send(request: request, type: OrderDTO.self) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let order):
                self.currentIds = order.nfts
                self.loadCartItems(ids: order.nfts, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func addItem(with id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread, "CartServiceNetwork.addItem must be called on the main thread")
        
        var updatedIds = currentIds
        if !updatedIds.contains(id) {
            updatedIds.append(id)
        }
        
        let dto = OrderPutDto(nfts: updatedIds)
        let request = OrderPutRequest(dto: dto)
        
        networkClient.send(request: request, type: OrderDTO.self) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let order):
                    self?.currentIds = order.nfts
                    NotificationCenter.default.post(
                        name: NSNotification.Name("CartDidChange"),
                        object: nil
                    )
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func removeItem(with id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread, "CartServiceNetwork.removeItem must be called on the main thread")
        
        let proceed: ([String]) -> Void = { [weak self] ids in
            guard let self else { return }
            let updated = ids.filter { $0 != id }
            
            guard !updated.isEmpty else {
                self.clear(completion: completion)
                return
            }
            
            let dto = OrderPutDto(nfts: updated)
            let request = OrderPutRequest(dto: dto)
            self.networkClient.send(request: request, type: OrderDTO.self) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let order):
                        self?.currentIds = order.nfts
                        NotificationCenter.default.post(
                            name: NSNotification.Name("CartDidChange"),
                            object: nil
                        )
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
        
        if currentIds.isEmpty {
            let getReq = OrderGetRequest()
            networkClient.send(request: getReq, type: OrderDTO.self) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let order):
                    self.currentIds = order.nfts
                    proceed(order.nfts)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            proceed(currentIds)
        }
    }
    
    func clear(completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread, "CartServiceNetwork.clear must be called on the main thread")
        
        let request = OrderPutRequest(dto: nil)
        networkClient.send(request: request, type: OrderDTO.self) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let order):
                    self?.currentIds = order.nfts
                    NotificationCenter.default.post(
                        name: NSNotification.Name("CartDidChange"),
                        object: nil
                    )
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Private
    private func loadCartItems(ids: [String], completion: @escaping (Result<[CartItem], Error>) -> Void) {
        guard !ids.isEmpty else {
            completion(.success([]))
            return
        }
        
        let group = DispatchGroup()
        var items: [CartItem] = []
        var firstError: Error?
        let syncQueue = DispatchQueue(label: "cart-items-sync-queue")
        
        for id in ids {
            group.enter()
            nftService.loadNft(id: id) { result in
                switch result {
                case .success(let nft):
                    let item = CartItem(
                        id: nft.id,
                        title: nft.name,
                        imageURL: nft.images.first,
                        rating: nft.rating,
                        price: nft.price
                    )
                    syncQueue.async {
                        items.append(item)
                        group.leave()
                    }
                case .failure(let error):
                    syncQueue.async {
                        if firstError == nil { firstError = error }
                        group.leave()
                    }
                }
            }
        }
        
        group.notify(queue: .global()) {
            if let error = firstError {
                completion(.failure(error))
            } else {
                let dict = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
                let ordered = ids.compactMap { dict[$0] }
                completion(.success(ordered))
            }
        }
    }
}
