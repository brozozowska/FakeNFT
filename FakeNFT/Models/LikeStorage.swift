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
        print("Toggle like for NFT: \(nftId). Currently liked: \(likedNFTs.contains(nftId))")
        
        let oldState = likedNFTs.contains(nftId)
        
        if likedNFTs.contains(nftId) {
            likedNFTs.remove(nftId)
        } else {
            likedNFTs.insert(nftId)
        }
        
        updateLikesOnServer { [weak self] success in
            if !success {
                if oldState {
                    self?.likedNFTs.insert(nftId)
                } else {
                    self?.likedNFTs.remove(nftId)
                }
            } else {
                NotificationCenter.default.post(name: NSNotification.Name("LikesDidChange"), object: nil)
            }
            completion?(success)
        }
    }
    
    func isLiked(nftId: String) -> Bool {
        return likedNFTs.contains(nftId)
    }
    
    private func loadLikesFromServer() {
        let request = GetProfileRequest(id: profileId)
        print("Loading likes from server...")
        
        networkClient.send(request: request, type: Profile.self) { [weak self] result in
            switch result {
            case .success(let profile):
                print("Successfully loaded profile: \(profile.name), likes: \(profile.likes)")
                self?.likedNFTs = Set(profile.likes)
                self?.currentProfile = profile
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("LikesDidLoadFromServer"),
                        object: nil
                    )
                }
                print("Successfully loaded \(profile.likes.count) likes")
            case .failure(let error):
                print("Failed to load likes: \(error)")
                self?.likedNFTs = []
            }
        }
    }
    
    private func updateLikesOnServer(completion: ((Bool) -> Void)? = nil) {
        let likesString = Array(likedNFTs).joined(separator: ",")
        print("Updating likes on server: \(likesString)")
        
        let profileName = currentProfile?.name ?? "Студентус Практикумс"
        let avatarURL = currentProfile?.avatar ?? "https://code.s3.yandex.net/landings-v2-ios-developer/space.PNG"
        let profileDescription = currentProfile?.description ?? "Прошел 5-й спринт, и этот пройду"
        let website = currentProfile?.website ?? "https://practicum.yandex.ru/ios-developer"
        
        let request = PutProfileRequest(
            id: profileId,
            likes: likesString,
            name: profileName,
            avatar: avatarURL,
            description: profileDescription,
            website: website
        )
        
        if let dto = request.dto {
            print("Sending DTO: \(dto.asDictionary())")
        }
        
        networkClient.send(request: request, type: Profile.self) { [weak self] result in
            switch result {
            case .success(let profile):
                print("Likes updated successfully. Profile name: \(profile.name), liked NFTs: \(profile.likes.count)")
                self?.currentProfile = profile
                completion?(true)
            case .failure(let error):
                print("Failed to update likes: \(error)")
                completion?(false)
            }
        }
    }
}
