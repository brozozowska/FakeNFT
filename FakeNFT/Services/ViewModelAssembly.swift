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
}
