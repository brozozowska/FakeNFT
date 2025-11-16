import Foundation
import Combine

final class CollectionViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var nfts: [Nft] = []
    @Published var isLoading: Bool = false
    @Published var errorModel: ErrorModel?
    
    // MARK: - Public Properties
    
    let collection: NFTCollection
    var collectionName: String { collection.name }
    var authorName: String { collection.author }
    var nftsCount: Int { nfts.count }
    
    // MARK: - Callbacks
    
    var onAuthorWebsiteTapped: (() -> Void)?
    var onNFTSeeMoreTapped: ((String) -> Void)?
    
    // MARK: - Private Properties
    
    private let nftService: NftService
    private let likeService: LikeStorage
    private let cartService: CartStorage
    private var cancellables = Set<AnyCancellable>()
    
    private var updatingNFTs: Set<String> = []
    
    // MARK: - Init
    
    init(collection: NFTCollection,
         nftService: NftService,
         likeService: LikeStorage,
         cartService: CartStorage) {
        self.collection = collection
        self.nftService = nftService
        self.likeService = likeService
        self.cartService = cartService
    }
    
    // MARK: - Public Methods
    
    func loadCollectionData() {
        isLoading = true
        errorModel = nil
        
        let group = DispatchGroup()
        let threadSafeQueue = DispatchQueue(label: "com.app.collectionViewModel.nfts", attributes: .concurrent)
        var loadedNFTs: [Nft] = []
        var loadError: Error?
        
        for nftId in collection.nfts {
            group.enter()
            nftService.loadNft(id: nftId) { result in
                switch result {
                case .success(let nft):
                    threadSafeQueue.async(flags: .barrier) {
                        loadedNFTs.append(nft)
                    }
                case .failure(let error):
                    threadSafeQueue.async(flags: .barrier) {
                        if loadError == nil {
                            loadError = error
                        }
                    }
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            
            threadSafeQueue.sync {
                self.isLoading = false
                
                if let error = loadError {
                    self.errorModel = self.makeErrorModel(error)
                } else {
                    self.nfts = loadedNFTs
                }
            }
        }
    }
    
    func nft(at index: Int) -> Nft {
        nfts[index]
    }
    
    func toggleLike(for nftId: String) {
        guard !updatingNFTs.contains(nftId) else {
            print("Like operation already in progress for NFT: \(nftId)")
            return
        }
        
        updatingNFTs.insert(nftId)
        objectWillChange.send()
        
        likeService.toggleLike(for: nftId) { [weak self] success in
            self?.updatingNFTs.remove(nftId)
            self?.objectWillChange.send()
        }
    }
    
    func toggleCart(for nftId: String) {
        guard !updatingNFTs.contains(nftId) else {
            print("Cart operation already in progress for NFT: \(nftId)")
            return
        }
        
        updatingNFTs.insert(nftId)
        objectWillChange.send()
        
        cartService.toggleCart(for: nftId) { [weak self] success in
            self?.updatingNFTs.remove(nftId)
            self?.objectWillChange.send()
        }
    }
    
    func isLiked(nftId: String) -> Bool {
        return likeService.isLiked(nftId: nftId)
    }
    
    func isInCart(nftId: String) -> Bool {
        return cartService.isInCart(nftId: nftId)
    }
    
    func isUpdating(nftId: String) -> Bool {
        return updatingNFTs.contains(nftId)
    }
    
    func showNftDetail(_ nftId: String) {
        onNFTSeeMoreTapped?(nftId)
    }
    
    func openAuthorWebsite() {
        onAuthorWebsiteTapped?()
    }
    
    // MARK: - Private Methods
    
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
            self?.loadCollectionData()
        }
    }
}
