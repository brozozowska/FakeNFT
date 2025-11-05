import Foundation

protocol CurrencyViewModelOutput: AnyObject {
    func didUpdateCurrencies()
    func didChangeLoading(_ isLoading: Bool)
    func didReceiveError(_ error: Error)
    func didFinishPayment()
    func didFailPayment(_ error: Error)
}

protocol CurrencyViewModelProtocol: AnyObject {
    var currencies: [Currency] { get }
    var output: CurrencyViewModelOutput? { get set }
    func viewDidLoad()
    func pay()
}

final class CurrencyViewModel: CurrencyViewModelProtocol {
    private let currencyService: CurrencyServiceProtocol
    private let cartService: CartServiceProtocol
    private(set) var currencies: [Currency] = []
   
    weak var output: CurrencyViewModelOutput?
    
    init(currencyService: CurrencyServiceProtocol, cartService: CartServiceProtocol) {
        self.currencyService = currencyService
        self.cartService = cartService
    }
    
    func viewDidLoad() {
        load()
    }
    
    func pay() {
        output?.didChangeLoading(true)
        cartService.clear { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.output?.didChangeLoading(false)
                switch result {
                case .success:
                    self.output?.didFinishPayment()
                case .failure(let error):
                    self.output?.didFailPayment(error)
                }
            }
        }
    }
    
    private func load() {
        output?.didChangeLoading(true)
        currencyService.fetchCurrencies { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.output?.didChangeLoading(false)
                switch result {
                case .success(let currencies):
                    self.currencies = currencies
                    self.output?.didUpdateCurrencies()
                case .failure(let error):
                    self.output?.didReceiveError(error)
                }
            }
        }
    }
}
