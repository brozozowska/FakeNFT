import Foundation

protocol CurrencyServiceProtocol: AnyObject {
    func fetchCurrencies(completion: @escaping (Result<[Currency], Error>) -> Void)
}
