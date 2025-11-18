final class ServicesAssembly {
    
    private let networkClient: NetworkClient
    private let nftStorage: NftStorage
    
    // Единый сервис корзины для всех модулей
    private lazy var cartServiceInstance: CartServiceProtocol = CartServiceNetwork(
        networkClient: networkClient,
        nftService: nftService
    )
    
    // CartStorage использует CartServiceProtocol
    private lazy var cartStorageInstance: CartStorage = CartStorageImpl(
        cartService: cartServiceInstance
    )
    
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
    
    var cartService: CartServiceProtocol {
        cartServiceInstance
    }
    
    var cartStorage: CartStorage {
        cartStorageInstance
    }
    
    var currencyService: CurrencyServiceProtocol {
        CurrencyServiceNetwork(networkClient: networkClient)
    }
}
