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
        
        NotificationCenter.default.publisher(for: NSNotification.Name("LikesDidChange"))
            .sink { [weak self] _ in
                self?.loadFavorites()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: NSNotification.Name("LikesDidLoadFromServer"))
            .sink { [weak self] _ in
                self?.loadFavorites()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    func loadFavorites() {
        isLoading = true
        errorModel = nil
        
        let likedNFTs = Array(likeService.getLikedNFTs())
        
        if likedNFTs.isEmpty {
            isLoading = false
            nfts = []
            return
        }
        
        loadNFTs(by: likedNFTs)
    }
    
    func toggleFavorite(nftId: String) {
        likeService.toggleLike(for: nftId) { [weak self] success in
            DispatchQueue.main.async {
                if !success {
                    self?.errorModel = ErrorModel(
                        message: NSLocalizedString("Error.toggleLike", comment: ""),
                        actionText: NSLocalizedString("Error.repeat", comment: ""),
                        action: { self?.toggleFavorite(nftId: nftId) }
                    )
                }
            }
        }
    }
    
    func isLiked(nftId: String) -> Bool {
        return likeService.isLiked(nftId: nftId)
    }
    
    // MARK: - Private Methods
    
    private func loadNFTs(by ids: [String]) {
        let group = DispatchGroup()
        var loadedNFTs: [Nft] = []
        
        for nftId in ids {
            group.enter()
            nftService.loadNft(id: nftId) { result in
                if case .success(let nft) = result {
                    loadedNFTs.append(nft)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.isLoading = false
            self?.nfts = loadedNFTs
        }
    }
    
    private func makeErrorModel(_ error: Error) -> ErrorModel {
        ErrorModel(
            message: NSLocalizedString("Error.network", comment: ""),
            actionText: NSLocalizedString("Error.repeat", comment: ""),
            action: { [weak self] in self?.loadFavorites() }
        )
    }
}
