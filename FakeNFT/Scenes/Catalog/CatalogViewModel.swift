import Foundation
import Combine

final class CatalogViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var collections: [NFTCollection] = []
    @Published var isLoading: Bool = false
    @Published var errorModel: ErrorModel?
    
    // MARK: - Private Properties
    
    private let collectionService: CollectionService
    private var sortSettingsService: SortSettingsService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(collectionService: CollectionService, sortSettingsService: SortSettingsService) {
        self.collectionService = collectionService
        self.sortSettingsService = sortSettingsService
    }
    
    // MARK: - Public Methods
    
    func loadCollections() {
        isLoading = true
        errorModel = nil
        
        collectionService.loadCollections { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let collections):
                    self.collections = self.applySorting(to: collections)
                case .failure(let error):
                    self.errorModel = self.makeErrorModel(error)
                }
            }
        }
    }
    
    func updateSortOption(_ option: CatalogSortOption) {
        sortSettingsService.currentSortOption = option
        collections = applySorting(to: collections)
    }
    
    var currentSortOption: CatalogSortOption {
        sortSettingsService.currentSortOption
    }
    
    func collection(at index: Int) -> NFTCollection {
        collections[index]
    }
    
    func collectionsCount() -> Int {
        collections.count
    }
    
    // MARK: - Private Methods
    
    private func applySorting(to collections: [NFTCollection]) -> [NFTCollection] {
        let sortedCollections: [NFTCollection]
        
        switch sortSettingsService.currentSortOption {
        case .byName:
            sortedCollections = collections.sorted { $0.name < $1.name }
        case .byNFTCount:
            sortedCollections = collections.sorted {
                Set($0.nfts).count > Set($1.nfts).count
            }
        }
        
        return sortedCollections
    }
    
    private func makeErrorModel(_ error: Error) -> ErrorModel {
        let message: String
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                message = NSLocalizedString("Error.network.connection", comment: "No internet connection")
            case .timedOut:
                message = NSLocalizedString("Error.network.timeout", comment: "Request timeout")
            default:
                message = NSLocalizedString("Error.network", comment: "Network error")
            }
        } else {
            message = NSLocalizedString("Error.unknown", comment: "Unknown error")
        }
        
        let actionText = NSLocalizedString("Error.repeat", comment: "Try again")
        return ErrorModel(message: message, actionText: actionText) { [weak self] in
            self?.loadCollections()
        }
    }
}
