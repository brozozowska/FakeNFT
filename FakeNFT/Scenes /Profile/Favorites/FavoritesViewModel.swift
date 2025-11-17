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
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.reloadFavoritesFromStorage()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: NSNotification.Name("LikesDidLoadFromServer"))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.reloadFavoritesFromStorage()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    func loadFavorites() {
        reloadFavoritesFromStorage()
    }
    
    func toggleFavorite(nftId: String) {
        let wasLiked = likeService.isLiked(nftId: nftId)
        if wasLiked {
            nfts.removeAll { $0.id == nftId }
        }
        
        likeService.toggleLike(for: nftId) { [weak self] success in
            DispatchQueue.main.async {
                if !success {
                    if wasLiked {
                        self?.reloadFavoritesFromStorage()
                    }
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
    
    private func reloadFavoritesFromStorage() {
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
            guard let self = self else { return }
            
            self.nfts = loadedNFTs.sorted { first, second in
                guard let firstIndex = ids.firstIndex(of: first.id),
                      let secondIndex = ids.firstIndex(of: second.id) else {
                    return false
                }
                return firstIndex < secondIndex
            }
            
            self.isLoading = false
        }
    }
}
