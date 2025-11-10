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
        loadMyNFTs()
        
        NotificationCenter.default.publisher(for: NSNotification.Name("CartDidChange"))
            .sink { [weak self] _ in
                self?.loadMyNFTs()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    func loadMyNFTs() {
        isLoading = true
        errorModel = nil
        
        let cartNFTs = cartService.getCartItems()
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
            self?.loadMyNFTs()
        }
    }
}
