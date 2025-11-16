import Foundation



protocol ProfileService {
    func loadProfile(id: String, completion: @escaping (Result<Profile, Error>) -> Void)
    func updateProfile(_ profile: ProfileUpdate, completion: @escaping (Result<Profile, Error>) -> Void)
}

final class ProfileServiceImpl: ProfileService {
    private let networkClient: NetworkClient
    private let likeStorage: LikeStorage
    
    init(networkClient: NetworkClient, likeStorage: LikeStorage) {
        self.networkClient = networkClient
        self.likeStorage = likeStorage
    }
    
    func loadProfile(id: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        let request = GetProfileRequest(id: id)
        networkClient.send(request: request, type: Profile.self) { result in
            switch result {
            case .success(let profile):
                completion(.success(profile))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func updateProfile(_ profile: ProfileUpdate, completion: @escaping (Result<Profile, Error>) -> Void) {
        let likedNFTs = likeStorage.getLikedNFTs()
        let likesString = Array(likedNFTs).joined(separator: ",")
        
        let request = PutProfileRequest(
            id: "1",
            likes: likesString,
            name: profile.name,
            avatar: profile.avatar,
            description: profile.description,
            website: profile.website
        )
        
        print("Updating profile with: name=\(profile.name), avatar=\(profile.avatar), description=\(profile.description), website=\(profile.website), likes=\(likesString)")
        
        networkClient.send(request: request, type: Profile.self) { result in
            switch result {
            case .success(let updatedProfile):
                completion(.success(updatedProfile))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
