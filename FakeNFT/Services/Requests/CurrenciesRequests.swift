import Foundation

struct CurrenciesListRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/currencies")
    }
    var httpMethod: HttpMethod { .get }
    var dto: Dto? { nil }
}

struct CurrencyByIdRequest: NetworkRequest {
    let id: String
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/currencies/\(id)")
    }
    var httpMethod: HttpMethod { .get }
    var dto: Dto? { nil }
}
