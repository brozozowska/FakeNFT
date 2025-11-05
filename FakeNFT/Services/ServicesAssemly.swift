final class ServicesAssembly {
    
    private let networkClient: NetworkClient
    private let nftStorage: NftStorage
    private lazy var likeStorage: LikeStorage = LikeStorageImpl()
    
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
    
    var likeService: LikeStorage {
            return likeStorage
        }
    
    var sortSettingsService: SortSettingsService {
            SortSettingsServiceImpl()
        }
}
