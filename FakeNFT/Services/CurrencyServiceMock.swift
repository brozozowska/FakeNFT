import Foundation

final class CurrencyServiceMock: CurrencyServiceProtocol {
    private let currencies: [Currency] = [
        Currency(id: "1", title: "Bitcoin", name: "BTC", imageURL: URL(string: "https://t4.ftcdn.net/jpg/05/11/11/67/360_F_511116703_djZ9CLaCKJQIja8iRIoZ2MThVcTbT5OS.jpg")),
        Currency(id: "2", title: "Dogecoin", name: "DOGE", imageURL: URL(string: "https://www.citypng.com/public/uploads/preview/-316210035915mqt5kbcm8.png")),
        Currency(id: "3", title: "Tether", name: "USDT", imageURL: URL(string: "https://vectorseek.com/wp-content/uploads/2023/02/Tether-Logo-Vector-300x300.jpg")),
        Currency(id: "4", title: "ApeCoin", name: "APE", imageURL: URL(string: "https://img.cryptorank.io/coins/ape_coin1693307681566.png")),
        Currency(id: "5", title: "Ethereum", name: "ETH", imageURL: URL(string: "https://logowik.com/content/uploads/images/t_ethereum3649.jpg")),
        Currency(id: "6", title: "Solana", name: "SOL", imageURL: URL(string: "https://www.pngall.com/wp-content/uploads/10/Solana-Crypto-Logo-PNG-File.png")),
        Currency(id: "7", title: "Cardano", name: "ADA", imageURL: URL(string: "https://www.bitcoinqrcodemaker.com/cardano_logo2.png")),
        Currency(id: "8", title: "Shiba Inu", name: "SHIB", imageURL: URL(string: "https://i.pinimg.com/originals/0d/8d/30/0d8d3085e86eab92be5f1fb254668869.jpg"))
    ]
    
    func fetchCurrencies(completion: @escaping (Result<[Currency], Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.4) { [currencies] in
            completion(.success(currencies))
        }
    }
}
