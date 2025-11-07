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
    private var profileDescription: String?
    private var website = "https://practicum.yandex.ru/interface-designer/"
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
        loadLikesFromServer()
    }
    
    func getLikedNFTs() -> Set<String> {
        return likedNFTs
    }
    
    func toggleLike(for nftId: String) {
        print("Toggle like for NFT: \(nftId). Currently liked: \(likedNFTs.contains(nftId))")
        
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
        print("Loading likes from server...")
        
        networkClient.send(request: request, type: Profile.self) { [weak self] result in
            switch result {
            case .success(let profile):
                print("Successfully loaded profile: \(profile.name), likes: \(profile.likes)")
                self?.likedNFTs = Set(profile.likes)
                self?.profileName = profile.name
                self?.avatarURL = profile.avatar
                self?.profileDescription = profile.description
                self?.website = profile.website
                print("Successfully loaded \(profile.likes.count) likes")
            case .failure(let error):
                print("Failed to load likes: \(error)")
                self?.likedNFTs = []
            }
        }
    }
    
    private func updateLikesOnServer() {
        let likesString = Array(likedNFTs).joined(separator: ",")
        print("Updating likes on server: \(likesString)")
        
        let request = PutProfileRequest(
            id: profileId,
            likes: likesString,
            name: profileName,
            avatar: avatarURL
        )
        
        if let dto = request.dto {
                print("Sending DTO: \(dto.asDictionary())")
            }
        
        networkClient.send(request: request, type: Profile.self) { result in
            switch result {
            case .success(let profile):
                print("Likes updated successfully. Profile name: \(profile.name), liked NFTs: \(profile.likes.count)")
            case .failure(let error):
                print("Failed to update likes: \(error)")
            }
        }
    }
}
