import Foundation

protocol CurrencyViewModelOutput: AnyObject {
    func didUpdateCurrencies()
    func didChangeLoading(_ isLoading: Bool)
    func didReceiveError(_ error: Error)
    func didSelectCurrency(_ currency: Currency)
}

protocol CurrencyViewModelProtocol: AnyObject {
    var currencies: [Currency] { get }
    var output: CurrencyViewModelOutput? { get set }
    func viewDidLoad()
    func selectCurrency(at index: Int)
}

final class CurrencyViewModel: CurrencyViewModelProtocol {
    private let currencyService: CurrencyServiceProtocol
    private(set) var currencies: [Currency] = []
   
    weak var output: CurrencyViewModelOutput?
    
    init(currencyService: CurrencyServiceProtocol) {
        self.currencyService = currencyService
    }
    
    func viewDidLoad() {
        load()
    }
    
    func selectCurrency(at index: Int) {
        let currency = currencies[index]
        output?.didSelectCurrency(currency)
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
