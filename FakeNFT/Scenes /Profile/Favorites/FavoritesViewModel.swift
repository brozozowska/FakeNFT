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
                print("LikesDidChange notification received in FavoritesViewModel")
                self?.loadFavorites()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    func loadFavorites() {
        isLoading = true
        errorModel = nil
        
        let likedNFTs = Array(likeService.getLikedNFTs())
        print("Loading Favorites from likes: \(likedNFTs.count) items - \(likedNFTs)")
        
        if likedNFTs.isEmpty {
            self.isLoading = false
            self.nfts = []
            print("No favorite NFTs")
            return
        }
        
        loadNFTs(by: likedNFTs)
    }
    
    func toggleFavorite(nftId: String) {
        likeService.toggleLike(for: nftId) { [weak self] success in
            if success {
                print("Successfully toggled like for NFT \(nftId)")
            } else {
                print("Failed to toggle like")
                self?.errorModel = ErrorModel(
                    message: NSLocalizedString("Error.toggleLike", comment: "Failed to update like"),
                    actionText: NSLocalizedString("Error.repeat", comment: "Try again"),
                    action: { self?.toggleFavorite(nftId: nftId) }
                )
            }
        }
    }
    
    func isLiked(nftId: String) -> Bool {
        return likeService.isLiked(nftId: nftId)
    }
    
    // MARK: - Private Methods
    
    private func loadNFTs(by ids: [String]) {
        guard !ids.isEmpty else {
            self.isLoading = false
            self.nfts = []
            print("No NFT IDs to load")
            return
        }
        
        print("Loading \(ids.count) NFTs: \(ids)")
        
        let group = DispatchGroup()
        var loadedNFTs: [Nft] = []
        var loadError: Error?
        
        for nftId in ids {
            group.enter()
            nftService.loadNft(id: nftId) { result in
                switch result {
                case .success(let nft):
                    print("Successfully loaded NFT: \(nft.name), id: \(nft.id)")
                    loadedNFTs.append(nft)
                case .failure(let error):
                    print("Failed to load NFT \(nftId): \(error)")
                    loadError = error
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.isLoading = false
            if let error = loadError {
                print("Error loading NFTs: \(error)")
                self?.errorModel = self?.makeErrorModel(error)
            } else {
                print("Successfully loaded \(loadedNFTs.count) NFTs for Favorites")
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
}
