import Foundation

struct PutOrderRequest: NetworkRequest {
    let id: String
    let nfts: String
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/\(id)")
    }
    
    var httpMethod: HttpMethod { .put }
    
    var dto: Dto? {
        OrderDto(nfts: nfts)
    }
    
    var headers: [String: String]? {
        ["X-Practicum-Mobile-Token": RequestConstants.token]
    }
}

struct OrderDto: Dto {
    let nfts: String
    
    func asDictionary() -> [String: String] {
        return ["nfts": nfts]
    }
}

struct GetOrderRequest: NetworkRequest {
    let id: String
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/\(id)")
    }
    
    var httpMethod: HttpMethod { .get }
    
    var dto: Dto? { nil }
    
    var headers: [String: String]? {
        ["X-Practicum-Mobile-Token": RequestConstants.token]
    }
}

struct Order: Decodable {
    let id: String
    let nfts: [String]
}
