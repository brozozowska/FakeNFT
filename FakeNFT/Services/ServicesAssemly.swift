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
    
    var cartService: CartStorage {
        CartStorageImpl(networkClient: networkClient)
    }
    
    var likeService: LikeStorage {
        LikeStorageImpl(networkClient: networkClient)
    }
    
    var sortSettingsService: SortSettingsService {
        SortSettingsServiceImpl()
    }
    
    var myNFTSortSettingsService: MyNFTSortSettingsService {
        MyNFTSortSettingsServiceImpl()
    }
    
    var profileService: ProfileService {
        ProfileServiceImpl(
            networkClient: networkClient,
            likeStorage: likeService
        )
    }
}
