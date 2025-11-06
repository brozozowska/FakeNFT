final class ServicesAssembly {
    
    private let networkClient: NetworkClient
    private let nftStorage: NftStorage
    private lazy var likeStorage: LikeStorage = LikeStorageImpl()
    private lazy var cartStorage: CartStorage = CartStorageImpl()
    
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
    
    var cartService: CartStorage {
        return cartStorage
    }
    
    var likeService: LikeStorage {
            return likeStorage
        }
    
    var sortSettingsService: SortSettingsService {
            SortSettingsServiceImpl()
        }
}
