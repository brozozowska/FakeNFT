import Foundation

struct GetProfileRequest: NetworkRequest {
    let id: String
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/\(id)")
    }
    
    var httpMethod: HttpMethod { .get }
    
    var dto: Dto? { nil }
}

struct PutProfileRequest: NetworkRequest {
    let id: String
    let likes: String?
    let name: String?
    let avatar: String?
    let description: String?
    let website: String?
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/\(id)")
    }
    
    var httpMethod: HttpMethod { .put }
    
    var dto: Dto? {
        ProfileDto(
            likes: likes,
            name: name,
            avatar: avatar,
            description: description,
            website: website
        )
    }
}

struct ProfileDto: Dto {
    let likes: String?
    let name: String?
    let avatar: String?
    let description: String?
    let website: String?
    
    func asDictionary() -> [String: String] {
        var dictionary: [String: String] = [:]
        
        if let likes = likes { dictionary["likes"] = likes }
        if let name = name { dictionary["name"] = name }
        if let avatar = avatar { dictionary["avatar"] = avatar }
        if let description = description { dictionary["description"] = description }
        if let website = website { dictionary["website"] = website }
        
        return dictionary
    }
}
