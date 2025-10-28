import Foundation

typealias CollectionsCompletion = (Result<[NFTCollection], Error>) -> Void

protocol CollectionService {
    func loadCollections(completion: @escaping CollectionsCompletion)
}

final class CollectionServiceImpl: CollectionService {
    private let networkClient: NetworkClient
    private var cachedCollections: [NFTCollection]?
    private let syncQueue = DispatchQueue(label: "collection.service.sync", attributes: .concurrent)
    private var _isLoading = false
    private var _completions: [CollectionsCompletion] = []
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    deinit {
        syncQueue.async(flags: .barrier) { [weak self] in
            self?._completions.removeAll()
        }
    }
    
    func loadCollections(completion: @escaping CollectionsCompletion) {
        if let cachedCollections = cachedCollections {
            DispatchQueue.main.async { completion(.success(cachedCollections)) }
            return
        }
        
        var shouldStartLoading = false
        
        syncQueue.sync(flags: .barrier) {
            _completions.append(completion)
            
            if !_isLoading {
                _isLoading = true
                shouldStartLoading = true
            }
        }
        
        guard shouldStartLoading else { return }
        
        let request = CollectionsRequest()
        networkClient.send(request: request, type: [NFTCollection].self) { [weak self] result in
            guard let self else { return }
            
            self.syncQueue.async(flags: .barrier) {
                let currentCompletions = self._completions
                self._completions.removeAll()
                self._isLoading = false
                
                DispatchQueue.main.async {
                    switch result {
                    case .success(let collections):
                        self.cachedCollections = collections
                        currentCompletions.forEach { $0(.success(collections)) }
                    case .failure(let error):
                        currentCompletions.forEach { $0(.failure(error)) }
                    }
                }
            }
        }
    }
}
