import Foundation

protocol LikeStorage {
    func getLikedNFTs() -> Set<String>
    func toggleLike(for nftId: String)
    func isLiked(nftId: String) -> Bool
}

final class LikeStorageImpl: LikeStorage {
    private let userDefaults = UserDefaults.standard
    private let likedNFTsKey = "likedNFTs"
    
    func getLikedNFTs() -> Set<String> {
        guard let array = userDefaults.array(forKey: likedNFTsKey) as? [String] else {
            return Set()
        }
        return Set(array)
    }
    
    func toggleLike(for nftId: String) {
        var likedNFTs = getLikedNFTs()
        
        if likedNFTs.contains(nftId) {
            likedNFTs.remove(nftId)
        } else {
            likedNFTs.insert(nftId)
        }
        
        userDefaults.set(Array(likedNFTs), forKey: likedNFTsKey)
    }
    
    func isLiked(nftId: String) -> Bool {
        return getLikedNFTs().contains(nftId)
    }
}
