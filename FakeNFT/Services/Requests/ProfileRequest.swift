import Foundation

struct PutProfileRequest: NetworkRequest {
    let id: String
    let likes: String
    let name: String
    let avatar: String
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/\(id)")
    }
    
    var httpMethod: HttpMethod { .put }
    
    var dto: Dto? {
        ProfileDto(likes: likes, name: name, avatar: avatar)
    }
}

struct ProfileDto: Dto {
    let likes: String
    let name: String
    let avatar: String
    
    func asDictionary() -> [String: String] {
        return [
            "likes": likes,
            "name": name,
            "avatar": avatar
        ]
    }
}

struct GetProfileRequest: NetworkRequest {
    let id: String
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/\(id)")
    }
    
    var dto: Dto? { nil }
    
    var httpMethod: HttpMethod { .get }
}
