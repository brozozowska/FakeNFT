import Foundation

final class CurrencyServiceNetwork: CurrencyServiceProtocol {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func fetchCurrencies(completion: @escaping (Result<[Currency], Error>) -> Void) {
        let request = CurrenciesListRequest()
        networkClient.send(request: request, type: [CurrencyDTO].self) { result in
            switch result {
            case .success(let dtos):
                let currencies = dtos.map { $0.toDomain() }
                completion(.success(currencies))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
