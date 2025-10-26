import UIKit

// MARK: - Protocol
protocol CurrencyView: AnyObject, LoadingView, ErrorView { }

// MARK: - CurrencyViewController
final class CurrencyViewController: UIViewController, CurrencyView {
    
    // MARK: - Constants
    private struct Constants {
        static let collectionTopInset: CGFloat = 20
        static let collectionSideInset: CGFloat = 16
        static let collectionBottomInset: CGFloat = 0
        static let interItemSpacing: CGFloat = 7
        static let lineSpacing: CGFloat = 7
        static let itemHeight: CGFloat = 46
        static let numberOfColumns: CGFloat = 2
        
        static let bottomContainerCornerRadius: CGFloat = 16
        static let termsLabelTopInset: CGFloat = 12
        static let payButtonTopInset: CGFloat = 12
        static let payButtonSideInset: CGFloat = 16
        static let payButtonBottomInset: CGFloat = 12
        static let payButtonHeight: CGFloat = 52
        
        static let termsFontSize: CGFloat = 14
        static let payButtonFontSize: CGFloat = 17
        static let payButtonCornerRadius: CGFloat = 16
        
        static let titleKey = "Currency.header"
        static let termsKey = "Currency.terms"
        static let payButtonKey = "Currency.pay"
        static let errorRepeatKey = "Error.repeat"
    }
    
    // MARK: - UI
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(
            top: Constants.collectionTopInset,
            left: Constants.collectionSideInset,
            bottom: Constants.collectionBottomInset,
            right: Constants.collectionSideInset
        )
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    private let bottomContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = Constants.bottomContainerCornerRadius
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    private let termsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: Constants.termsFontSize)
        label.text = NSLocalizedString(Constants.termsKey, comment: "Terms and conditions text")
        return label
    }()
    
    private let payButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .label
        button.setTitle(NSLocalizedString(Constants.payButtonKey, comment: "Pay button title"), for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: Constants.payButtonFontSize, weight: .bold)
        button.layer.cornerRadius = Constants.payButtonCornerRadius
        return button
    }()
    
    internal lazy var activityIndicator = UIActivityIndicatorView(style: .medium)
    
    // MARK: - Dependencies
    private let viewModel: CurrencyViewModelProtocol
    
    // MARK: - Init
    init(viewModel: CurrencyViewModelProtocol) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        title = NSLocalizedString(Constants.titleKey, comment: "Currency selection header")
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
        collectionView.register(CurrencyCell.self, forCellWithReuseIdentifier: CurrencyCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        viewModel.viewDidLoad()
    }
    
    // MARK: - Setup
    private func setupHierarchy() {
        view.addSubview(collectionView)
        view.addSubview(bottomContainer)
        bottomContainer.addSubview(termsLabel)
        bottomContainer.addSubview(payButton)
        view.addSubview(activityIndicator)
    }
    
    private func setupConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        bottomContainer.translatesAutoresizingMaskIntoConstraints = false
        termsLabel.translatesAutoresizingMaskIntoConstraints = false
        payButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomContainer.topAnchor),
            
            bottomContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            termsLabel.topAnchor.constraint(equalTo: bottomContainer.topAnchor, constant: Constants.termsLabelTopInset),
            termsLabel.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor, constant: Constants.payButtonSideInset),
            termsLabel.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor, constant: -Constants.payButtonSideInset),
            
            payButton.topAnchor.constraint(equalTo: termsLabel.bottomAnchor, constant: Constants.payButtonTopInset),
            payButton.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor, constant: Constants.payButtonSideInset),
            payButton.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor, constant: -Constants.payButtonSideInset),
            payButton.bottomAnchor.constraint(equalTo: bottomContainer.bottomAnchor, constant: -Constants.payButtonBottomInset),
            payButton.heightAnchor.constraint(equalToConstant: Constants.payButtonHeight)
        ])
    }
    
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
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
            actionText: NSLocalizedString(Constants.errorRepeatKey, comment: "Repeat button")
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
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CurrencyCell.reuseIdentifier,
            for: indexPath
        ) as! CurrencyCell
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
        let horizontalInsets = Constants.collectionSideInset * 2
        let interItemSpacing = Constants.interItemSpacing
        let columns = Constants.numberOfColumns
        let itemWidth = (totalWidth - horizontalInsets - interItemSpacing) / columns
        
        return CGSize(width: itemWidth, height: Constants.itemHeight)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        Constants.lineSpacing
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        Constants.interItemSpacing
    }
}

// MARK: - Notification
extension Notification.Name {
    static let didSelectCurrency = Notification.Name("didSelectCurrency")
}
