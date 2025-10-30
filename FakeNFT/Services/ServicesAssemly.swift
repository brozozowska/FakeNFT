final class ServicesAssembly {
    
    private let networkClient: NetworkClient
    private let nftStorage: NftStorage
    
    init(
        networkClient: NetworkClient,
        nftStorage: NftStorage
    ) {
        self.networkClient = networkClient
        self.nftStorage = nftStorage
    }
    
    var nftService: NftService {
        NftServiceImpl(
            networkClient: networkClient,
            storage: nftStorage
        )
    }
    var collectionService: CollectionService {
        CollectionServiceImpl(
            networkClient: networkClient
        )
    }
    
    // MARK: - View Models
    
    func makeCatalogViewModel() -> CatalogViewModel {
        return CatalogViewModel(collectionService: collectionService)
    }
    
    // MARK: - CollectionView Models
    
    func makeCollectionViewModel(collection: NFTCollection) -> CollectionViewModel {
        return CollectionViewModel(collection: collection, nftService: nftService)
    }
}
