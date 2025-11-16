import Foundation

final class ViewModelAssembly {
    
    private let servicesAssembly: ServicesAssembly
    
    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
    }
    
    // MARK: - View Models
    
    func makeCatalogViewModel() -> CatalogViewModel {
        CatalogViewModel(collectionService: servicesAssembly.collectionService,
                         sortSettingsService: servicesAssembly.sortSettingsService)
    }
    
    // MARK: - CollectionView Models
    
    func makeCollectionViewModel(collection: NFTCollection) -> CollectionViewModel {
        return CollectionViewModel(
            collection: collection,
            nftService: servicesAssembly.nftService,
            likeService: servicesAssembly.likeService,
            cartService: servicesAssembly.cartService
        )
    }
    
    // MARK: - ProfileView Models
    
    func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(
            profileService: servicesAssembly.profileService,
            nftService: servicesAssembly.nftService
        )
    }
    
    func makeEditProfileViewModel(profile: Profile) -> EditProfileViewModel {
        EditProfileViewModel(
            profile: profile,
            profileService: servicesAssembly.profileService
        )
    }
    
    func makeMyNFTsViewModel() -> MyNFTsViewModel {
        let sortSettingsService = MyNFTSortSettingsServiceImpl()
        return MyNFTsViewModel(
            cartService: servicesAssembly.cartService,
            nftService: servicesAssembly.nftService,
            sortSettingsService: sortSettingsService
        )
    }
    
    func makeFavoritesViewModel() -> FavoritesViewModel {
        FavoritesViewModel(
            likeService: servicesAssembly.likeService,
            nftService: servicesAssembly.nftService
        )
    }
}
