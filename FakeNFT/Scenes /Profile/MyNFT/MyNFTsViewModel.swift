import Foundation
import Combine

final class MyNFTsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var nfts: [Nft] = []
    @Published var isLoading: Bool = false
    @Published var errorModel: ErrorModel?
    
    // MARK: - Private Properties
    private let cartService: CartStorage
    private let nftService: NftService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(cartService: CartStorage, nftService: NftService) {
        self.cartService = cartService
        self.nftService = nftService
        
        NotificationCenter.default.publisher(for: NSNotification.Name("CartDidChange"))
            .sink { [weak self] _ in
                print("CartDidChange notification received in MyNFTsViewModel")
                self?.loadMyNFTs()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func loadMyNFTs() {
        isLoading = true
        errorModel = nil
        
        let cartNFTs = cartService.getCartItems()
        print("Loading MyNFTs from cart: \(cartNFTs.count) items - \(cartNFTs)")
        
        if cartNFTs.isEmpty {
            self.isLoading = false
            self.nfts = []
            print("No NFTs in cart")
            return
        }
        
        loadNFTs(by: cartNFTs)
    }
    
    func removeFromCart(nftId: String) {
        cartService.toggleCart(for: nftId) { [weak self] success in
            if success {
                print("Successfully removed NFT \(nftId) from cart")
            } else {
                print("Failed to remove NFT from cart")
                DispatchQueue.main.async {
                    self?.errorModel = ErrorModel(
                        message: NSLocalizedString("Error.removeFromCart", comment: "Failed to remove from cart"),
                        actionText: NSLocalizedString("Error.repeat", comment: "Try again"),
                        action: { self?.removeFromCart(nftId: nftId) }
                    )
                }
            }
        }
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
                print("Successfully loaded \(loadedNFTs.count) NFTs for MyNFTs")
                self?.nfts = loadedNFTs
            }
        }
    }
    
    private func makeErrorModel(_ error: Error) -> ErrorModel {
        let message = NSLocalizedString("Error.network", comment: "Network error")
        let actionText = NSLocalizedString("Error.repeat", comment: "Try again")
        return ErrorModel(message: message, actionText: actionText) { [weak self] in
            self?.loadMyNFTs()
        }
    }
}
