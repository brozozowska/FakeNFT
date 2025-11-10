import Foundation
import Combine

final class FavoritesViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var nfts: [Nft] = []
    @Published var isLoading: Bool = false
    @Published var errorModel: ErrorModel?
    
    // MARK: - Private Properties
    
    private let likeService: LikeStorage
    private let nftService: NftService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(likeService: LikeStorage, nftService: NftService) {
        self.likeService = likeService
        self.nftService = nftService
        loadFavorites()
        
        setupLikesObserver()
    }
    
    // MARK: - Public Methods
    
    func loadFavorites() {
        isLoading = true
        errorModel = nil
        
        let likedNFTs = Array(likeService.getLikedNFTs())
        loadNFTs(by: likedNFTs)
    }
    
    func toggleFavorite(nftId: String) {
        likeService.toggleLike(for: nftId) { [weak self] success in
            if success {
                print("Successfully toggled like for NFT \(nftId)")
            } else {
                print("Failed to toggle like")
                DispatchQueue.main.async {
                    self?.errorModel = ErrorModel(
                        message: NSLocalizedString("Error.toggleLike", comment: "Failed to update like"),
                        actionText: NSLocalizedString("Error.repeat", comment: "Try again"),
                        action: { self?.toggleFavorite(nftId: nftId) }
                    )
                }
            }
        }
    }
    
    func isLiked(nftId: String) -> Bool {
        likeService.isLiked(nftId: nftId)
    }
    
    // MARK: - Private Methods
    
    private func setupLikesObserver() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("LikesDidChange"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.loadFavorites()
        }
    }
    
    private func loadNFTs(by ids: [String]) {
        guard !ids.isEmpty else {
            self.isLoading = false
            self.nfts = []
            return
        }
        
        let group = DispatchGroup()
        var loadedNFTs: [Nft] = []
        var loadError: Error?
        
        for nftId in ids {
            group.enter()
            nftService.loadNft(id: nftId) { result in
                switch result {
                case .success(let nft):
                    loadedNFTs.append(nft)
                case .failure(let error):
                    loadError = error
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.isLoading = false
            if let error = loadError {
                self?.errorModel = self?.makeErrorModel(error)
            } else {
                self?.nfts = loadedNFTs
            }
        }
    }
    
    private func makeErrorModel(_ error: Error) -> ErrorModel {
        let message = NSLocalizedString("Error.network", comment: "Network error")
        let actionText = NSLocalizedString("Error.repeat", comment: "Try again")
        return ErrorModel(message: message, actionText: actionText) { [weak self] in
            self?.loadFavorites()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
