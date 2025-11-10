import Foundation
import Combine

final class MyNFTsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var nfts: [Nft] = []
    @Published var isLoading: Bool = false
    @Published var errorModel: ErrorModel?
    
    // MARK: - Private Properties
    private let profileService: ProfileService
    private let nftService: NftService
    private var cancellables = Set<AnyCancellable>()
    private let profileId = "1"
    
    // MARK: - Init
    init(profileService: ProfileService, nftService: NftService) {
        self.profileService = profileService
        self.nftService = nftService
        loadMyNFTs()
    }
    
    // MARK: - Public Methods
    func loadMyNFTs() {
        isLoading = true
        errorModel = nil
        
        profileService.loadProfile(id: profileId) { [weak self] result in
            switch result {
            case .success(let profile):
                self?.loadNFTs(by: profile.nfts)
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.errorModel = self?.makeErrorModel(error)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    private func loadNFTs(by ids: [String]) {
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
