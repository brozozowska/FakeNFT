import Foundation

protocol LikeStorage {
    func getLikedNFTs() -> Set<String>
    func toggleLike(for nftId: String, completion: ((Bool) -> Void)?)
    func isLiked(nftId: String) -> Bool
}

final class LikeStorageImpl: LikeStorage {
    private let networkClient: NetworkClient
    private let profileId = "1"
    private var likedNFTs: Set<String> = []
    private var currentProfile: Profile?
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
        loadLikesFromServer()
    }
    
    func getLikedNFTs() -> Set<String> {
        return likedNFTs
    }
    
    func toggleLike(for nftId: String, completion: ((Bool) -> Void)? = nil) {
        let oldLikedNFTs = likedNFTs
        
        if likedNFTs.contains(nftId) {
            likedNFTs.remove(nftId)
        } else {
            likedNFTs.insert(nftId)
        }
        
        updateLikesOnServer { [weak self] success in
            DispatchQueue.main.async {
                if !success {
                    self?.likedNFTs = oldLikedNFTs
                    completion?(false)
                } else {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("LikesDidChange"),
                        object: nil
                    )
                    completion?(true)
                }
            }
        }
    }
    
    func isLiked(nftId: String) -> Bool {
        return likedNFTs.contains(nftId)
    }
    
    private func loadLikesFromServer() {
        let request = GetProfileRequest(id: profileId)
        
        networkClient.send(request: request, type: Profile.self) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self?.likedNFTs = Set(profile.likes)
                    self?.currentProfile = profile
                    NotificationCenter.default.post(
                        name: NSNotification.Name("LikesDidLoadFromServer"),
                        object: nil
                    )
                case .failure:
                    self?.likedNFTs = []
                }
            }
        }
    }
    
    private func updateLikesOnServer(completion: ((Bool) -> Void)? = nil) {
        guard currentProfile != nil else {
            completion?(false)
            return
        }
        
        let likesString: String? = likedNFTs.isEmpty ? nil : Array(likedNFTs).joined(separator: ",")
        
        let request = PutProfileRequest(
            id: profileId,
            likes: likesString,
            name: nil,
            avatar: nil,
            description: nil,
            website: nil
        )
        
        networkClient.send(request: request, type: Profile.self) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    if likesString == nil && !profile.likes.isEmpty {
                        self?.likedNFTs = []
                        completion?(true)
                    } else {
                        self?.likedNFTs = Set(profile.likes)
                        self?.currentProfile = profile
                        completion?(true)
                    }
                case .failure:
                    completion?(false)
                }
            }
        }
    }
}
