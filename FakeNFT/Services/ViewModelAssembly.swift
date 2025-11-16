import Foundation

// MARK: - ViewModelFactory Protocol

protocol ViewModelFactory {
    func makeEditProfileViewModel(profile: Profile) -> EditProfileViewModel
    func makeMyNFTsViewModel() -> MyNFTsViewModel
    func makeFavoritesViewModel() -> FavoritesViewModel
}

final class ViewModelAssembly: ViewModelFactory {
    
    private let servicesAssembly: ServicesAssembly
    
    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
    }
    
    // MARK: - View Models
    
    func makeCatalogViewModel() -> CatalogViewModel {
        CatalogViewModel(collectionService: servicesAssembly.collectionService,
                         sortSettingsService: servicesAssembly.sortSettingsService)
    }
    
    func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(
            profileService: servicesAssembly.profileService,
            likeStorage: servicesAssembly.likeService
        )
    }
    
    // MARK: - ViewModelFactory Methods
    
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
    
    // MARK: - CollectionView Models
    
    func makeCollectionViewModel(collection: NFTCollection) -> CollectionViewModel {
        return CollectionViewModel(
            collection: collection,
            nftService: servicesAssembly.nftService,
            likeService: servicesAssembly.likeService,
            cartService: servicesAssembly.cartService
        )
    }
}
