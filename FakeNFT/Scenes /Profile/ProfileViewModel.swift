import Foundation
import Combine

final class ProfileViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var profile: Profile?
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
        loadProfile()
    }
    
    // MARK: - Public Methods
    
    func loadProfile() {
        isLoading = true
        errorModel = nil
        
        profileService.loadProfile(id: profileId) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let profile):
                self?.profile = profile
            case .failure(let error):
                self?.errorModel = self?.makeErrorModel(error)
            }
        }
    }
    
    func updateProfile(name: String, description: String, website: String, avatar: String) {
        isLoading = true
        
        let currentLikes = profile?.likes.joined(separator: ",") ?? ""
        
        let profileUpdate = ProfileUpdate(
            name: name,
            avatar: avatar,
            description: description,
            website: website,
            likes: currentLikes
        )
        
        profileService.updateProfile(profileUpdate) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let profile):
                self?.profile = profile
            case .failure(let error):
                self?.errorModel = self?.makeErrorModel(error)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func makeErrorModel(_ error: Error) -> ErrorModel {
        let message = NSLocalizedString("Error.network", comment: "Network error")
        let actionText = NSLocalizedString("Error.repeat", comment: "Try again")
        return ErrorModel(message: message, actionText: actionText) { [weak self] in
            self?.loadProfile()
        }
    }
}
