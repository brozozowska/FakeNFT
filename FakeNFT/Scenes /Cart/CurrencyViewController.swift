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
            static let bottomInset: CGFloat = 50
            static let topInset: CGFloat = 12
            static let height: CGFloat = 60
            static let cornerRadius: CGFloat = 16
        }
        
        enum Strings {
            static let titleKey = "Currency.header"
            static let termsKey = "Currency.terms"
            static let payButtonKey = "Currency.pay"
            static let errorRepeatKey = "Error.repeat"
            static let paymentFailedTitleKey = "Payment.failed.title"
            static let cancelKey = "Payment.failed.cancel"
            static let retryKey = "Payment.failed.retry"
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
        button.addTarget(self, action: #selector(payTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var activityIndicator = UIActivityIndicatorView(style: .medium)
    
    // MARK: - Dependencies
    private let viewModel: CurrencyViewModelProtocol
    
    // MARK: - Selection State
    private var selectedIndex: IndexPath?
    
    // MARK: - Init
    init(viewModel: CurrencyViewModelProtocol) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        title = NSLocalizedString(Constants.Strings.titleKey, comment: "Currency selection header")
        viewModel.output = self
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
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
            bottomContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
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
    
    // MARK: - Actions
    @objc private func payTapped() {
        viewModel.pay()
    }
    
    private func showPaymentFailureAlert(error: Error) {
        let title = NSLocalizedString(Constants.Strings.paymentFailedTitleKey, comment: "Payment failed")
        let cancel = NSLocalizedString(Constants.Strings.cancelKey, comment: "Cancel payment")
        let retry = NSLocalizedString(Constants.Strings.retryKey, comment: "Retry payment")
        
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: cancel, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: retry, style: .default, handler: { [weak self] _ in
            self?.viewModel.pay()
        }))
        present(alert, animated: true)
    }
    
    private func showSuccessReplacingCurrency() {
        NotificationCenter.default.post(name: .cartDidClear, object: nil)
        
        let success = PaymentSuccessViewController()
        success.hidesBottomBarWhenPushed = true
        success.navigationItem.hidesBackButton = true
        
        guard let nav = navigationController else {
            present(success, animated: true)
            return
        }
        let wasInteractivePopEnabled = nav.interactivePopGestureRecognizer?.isEnabled ?? true
        nav.interactivePopGestureRecognizer?.isEnabled = false
        
        if let cartVC = nav.viewControllers.first(where: { $0 is CartViewController }) {
            success.onClose = { [weak nav] in
                nav?.popViewController(animated: true)
                nav?.interactivePopGestureRecognizer?.isEnabled = wasInteractivePopEnabled
            }
            nav.setViewControllers([cartVC, success], animated: true)
        } else {
            nav.setViewControllers([success], animated: true)
        }
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
    }
    
    func didFinishPayment() {
        showSuccessReplacingCurrency()
    }
    
    func didFailPayment(_ error: Error) {
        showPaymentFailureAlert(error: error)
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
        cell.setSelectedAppearance(indexPath == selectedIndex)
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let previous = selectedIndex
        selectedIndex = indexPath
        
        var toReload: [IndexPath] = [indexPath]
        if let previous, previous != indexPath {
            toReload.append(previous)
        }
        collectionView.reloadItems(at: toReload)
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
    static let cartDidClear = Notification.Name("cartDidClear")
}
