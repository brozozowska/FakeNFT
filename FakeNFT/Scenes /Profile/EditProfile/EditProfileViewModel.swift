import UIKit
import Combine

final class EditProfileViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var name: String
    @Published var description: String
    @Published var website: String
    @Published var avatarURL: String
    @Published var hasChanges = false
    @Published var saveButtonHidden = true
    
    // MARK: - Private Properties
    private let originalProfile: Profile
    private let profileService: ProfileService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(profile: Profile, profileService: ProfileService) {
        self.originalProfile = profile
        self.profileService = profileService
        
        self.name = profile.name
        self.description = profile.description ?? ""
        self.website = profile.website
        self.avatarURL = profile.avatar
        
        setupBindings()
    }
    
    // MARK: - Public Methods
    func updateAvatar(_ urlString: String) {
        avatarURL = urlString
        checkForChanges()
    }
    
    func saveProfile(completion: @escaping (Bool) -> Void) {
        guard validateFields() else {
            completion(false)
            return
        }
        
        let profileUpdate = ProfileUpdate(
            name: name,
            avatar: avatarURL,
            description: description,
            website: website,
            likes: originalProfile.likes.joined(separator: ",")
        )
        
        profileService.updateProfile(profileUpdate) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    completion(true)
                case .failure:
                    completion(false)
                }
            }
        }
    }
    
    func validateURL(_ urlString: String) -> Bool {
        if let url = URL(string: urlString), url.scheme != nil {
            return true
        }
        
        if let url = URL(string: "https://" + urlString), url.host != nil {
            return true
        }
        
        return false
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        $name
            .dropFirst()
            .sink { [weak self] _ in self?.checkForChanges() }
            .store(in: &cancellables)
        
        $description
            .dropFirst()
            .sink { [weak self] _ in self?.checkForChanges() }
            .store(in: &cancellables)
        
        $website
            .dropFirst()
            .sink { [weak self] _ in self?.checkForChanges() }
            .store(in: &cancellables)
    }
    
    private func checkForChanges() {
        let nameChanged = name != originalProfile.name
        let descriptionChanged = description != (originalProfile.description ?? "")
        let websiteChanged = website != originalProfile.website
        let avatarChanged = avatarURL != originalProfile.avatar
        
        hasChanges = nameChanged || descriptionChanged || websiteChanged || avatarChanged
        saveButtonHidden = !hasChanges
    }
    
    private func validateFields() -> Bool {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !website.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        
        return validateURL(website)
    }
}
