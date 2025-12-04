import Foundation

struct OrderGetRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }
    var httpMethod: HttpMethod { .get }
    var dto: Dto? { nil }
}

struct OrderPutDto: Dto {
    let nfts: [String]
    
    enum CodingKeys: String {
        case nfts
    }
    
    func asDictionary() -> [String : String] {
        [
            CodingKeys.nfts.rawValue: nfts.joined(separator: ", ")
        ]
    }
}

struct OrderPutRequest: NetworkRequest {
    let dto: Dto?
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }
    var httpMethod: HttpMethod { .put }
}
