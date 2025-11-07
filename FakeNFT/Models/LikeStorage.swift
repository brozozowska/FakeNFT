import Foundation

protocol LikeStorage {
    func getLikedNFTs() -> Set<String>
    func toggleLike(for nftId: String)
    func isLiked(nftId: String) -> Bool
}

final class LikeStorageImpl: LikeStorage {
    private let networkClient: NetworkClient
    private let profileId = "1"
    private var likedNFTs: Set<String> = []
    private var profileName = "Студентус Практикумс"
    private var avatarURL = "https://photo.bank/1.png"
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
        loadLikesFromServer()
    }
    
    func getLikedNFTs() -> Set<String> {
        return likedNFTs
    }
    
    func toggleLike(for nftId: String) {
        if likedNFTs.contains(nftId) {
            likedNFTs.remove(nftId)
        } else {
            likedNFTs.insert(nftId)
        }
        
        updateLikesOnServer()
    }
    
    func isLiked(nftId: String) -> Bool {
        return likedNFTs.contains(nftId)
    }
    
    private func loadLikesFromServer() {
        let request = GetProfileRequest(id: profileId)
        networkClient.send(request: request, type: Profile.self) { [weak self] result in
            switch result {
            case .success(let profile):
                self?.likedNFTs = Set(profile.likes)
                self?.profileName = profile.name
                self?.avatarURL = profile.avatar
            case .failure(let error):
                print("Failed to load likes: \(error)")
                self?.likedNFTs = []
            }
        }
    }
    
    private func updateLikesOnServer() {
        let likesString = Array(likedNFTs).joined(separator: ",")
        let request = PutProfileRequest(
            id: profileId,
            likes: likesString,
            name: profileName,
            avatar: avatarURL
        )
        
        networkClient.send(request: request, type: Profile.self) { result in
            switch result {
            case .success(let profile):
                print("Likes updated successfully. Liked NFTs: \(profile.likes)")
            case .failure(let error):
                print("Failed to update likes: \(error)")
                // В реальном приложении нужно откатить изменения или показать ошибку
            }
        }
    }
}
