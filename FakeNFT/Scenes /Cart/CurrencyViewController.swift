import UIKit

// MARK: - Protocol
protocol CurrencyView: AnyObject, LoadingView, ErrorView { }

// MARK: - CurrencyViewController
final class CurrencyViewController: UIViewController, CurrencyView {
    
    // MARK: - Constants
    private enum Constants {
        enum Layout {
            static let collectionTopInset: CGFloat = 20
            static let collectionSideInset: CGFloat = 16
            static let collectionBottomInset: CGFloat = 0
            static let interItemSpacing: CGFloat = 7
            static let lineSpacing: CGFloat = 7
            static let itemHeight: CGFloat = 46
        }
        
        enum Columns {
            static let numberOfColumns: CGFloat = 2
        }
        
        enum BottomContainer {
            static let cornerRadius: CGFloat = 16
        }
        
        enum Typography {
            static let termsFontSize: CGFloat = 14
            static let payButtonFontSize: CGFloat = 17
        }
        
        enum PayButton {
            static let sideInset: CGFloat = 16
            static let bottomInset: CGFloat = 12
            static let topInset: CGFloat = 12
            static let height: CGFloat = 52
            static let cornerRadius: CGFloat = 16
        }
        
        enum Strings {
            static let titleKey = "Currency.header"
            static let termsKey = "Currency.terms"
            static let payButtonKey = "Currency.pay"
            static let errorRepeatKey = "Error.repeat"
        }
    }
    
    // MARK: - UI
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(
            top: Constants.Layout.collectionTopInset,
            left: Constants.Layout.collectionSideInset,
            bottom: Constants.Layout.collectionBottomInset,
            right: Constants.Layout.collectionSideInset
        )
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    private lazy var bottomContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = Constants.BottomContainer.cornerRadius
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    private lazy var termsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: Constants.Typography.termsFontSize)
        label.text = NSLocalizedString(Constants.Strings.termsKey, comment: "Terms and conditions text")
        return label
    }()
    
    private lazy var payButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .label
        button.setTitle(NSLocalizedString(Constants.Strings.payButtonKey, comment: "Pay button title"), for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: Constants.Typography.payButtonFontSize, weight: .bold)
        button.layer.cornerRadius = Constants.PayButton.cornerRadius
        return button
    }()
    
    internal lazy var activityIndicator = UIActivityIndicatorView(style: .medium)
    
    // MARK: - Dependencies
    private let viewModel: CurrencyViewModelProtocol
    
    // MARK: - Init
    init(viewModel: CurrencyViewModelProtocol) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        title = NSLocalizedString(Constants.Strings.titleKey, comment: "Currency selection header")
        viewModel.output = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupHierarchy()
        setupConstraints()
        setupActivityIndicator()
        
        collectionView.backgroundColor = .clear
        collectionView.register(CurrencyCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        viewModel.viewDidLoad()
    }
    
    // MARK: - Setup
    private func setupHierarchy() {
        [
            collectionView,
            bottomContainer,
            activityIndicator
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        [
            termsLabel,
            payButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            bottomContainer.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomContainer.topAnchor),
            
            bottomContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            termsLabel.topAnchor.constraint(equalTo: bottomContainer.topAnchor, constant: Constants.PayButton.topInset),
            termsLabel.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor, constant: Constants.PayButton.sideInset),
            termsLabel.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor, constant: -Constants.PayButton.sideInset),
            
            payButton.topAnchor.constraint(equalTo: termsLabel.bottomAnchor, constant: Constants.PayButton.topInset),
            payButton.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor, constant: Constants.PayButton.sideInset),
            payButton.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor, constant: -Constants.PayButton.sideInset),
            payButton.bottomAnchor.constraint(equalTo: bottomContainer.bottomAnchor, constant: -Constants.PayButton.bottomInset),
            payButton.heightAnchor.constraint(equalToConstant: Constants.PayButton.height)
        ])
    }
    
    private func setupActivityIndicator() {
        activityIndicator.constraintCenters(to: view)
    }
}

// MARK: - CurrencyViewModelOutput
extension CurrencyViewController: CurrencyViewModelOutput {
    func didUpdateCurrencies() {
        collectionView.reloadData()
    }
    
    func didChangeLoading(_ isLoading: Bool) {
        isLoading ? showLoading() : hideLoading()
    }
    
    func didReceiveError(_ error: Error) {
        let model = ErrorModel(
            message: error.localizedDescription,
            actionText: NSLocalizedString(Constants.Strings.errorRepeatKey, comment: "Repeat button")
        ) { [weak self] in
            self?.viewModel.viewDidLoad()
        }
        showError(model)
    }
    
    func didSelectCurrency(_ currency: Currency) {
        navigationController?.popViewController(animated: true)
        NotificationCenter.default.post(name: .didSelectCurrency, object: currency)
    }
}

// MARK: - UICollectionViewDataSource
extension CurrencyViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        viewModel.currencies.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: CurrencyCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        let currency = viewModel.currencies[indexPath.item]
        cell.configure(with: currency)
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        viewModel.selectCurrency(at: indexPath.item)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CurrencyViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let totalWidth = collectionView.bounds.width
        let horizontalInsets = Constants.Layout.collectionSideInset * 2
        let interItemSpacing = Constants.Layout.interItemSpacing
        let columns = Constants.Columns.numberOfColumns
        let itemWidth = (totalWidth - horizontalInsets - interItemSpacing) / columns
        
        return CGSize(width: itemWidth, height: Constants.Layout.itemHeight)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        Constants.Layout.lineSpacing
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        Constants.Layout.interItemSpacing
    }
}

// MARK: - Notification
extension Notification.Name {
    static let didSelectCurrency = Notification.Name("didSelectCurrency")
}
