import UIKit
import Combine

final class OnboardingViewController: UIViewController {
    
    // MARK: - Constants
    
    private enum Constants {
        static let closeButtonTopMargin: CGFloat = 72
        static let closeButtonLeadingMargin: CGFloat = 342
        static let closeButtonSize: CGFloat = 42
        
        static let progressViewTopMargin: CGFloat = 54
        static let progressViewHeight: CGFloat = 3
        
        static let closeButtonSymbolSize: CGFloat = 18
        static let closeButtonSymbolWeight: UIImage.SymbolWeight = .bold
        
        static let lastPageIndex = 2
        static let initialPageIndex = 0
        
        static let onboardingCompletedKey = "hasSeenOnboarding"
    }
    
    private enum LayoutConstants {
        static let zeroSpacing: CGFloat = 0
        static let pageScrollAnimationDuration: TimeInterval = 0.3
    }
    
    // MARK: - Properties
    
    private let viewModel: OnboardingViewModel
    private var cancellables = Set<AnyCancellable>()
    
    var onCompletion: (() -> Void)?
    
    // MARK: - UI Components
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = LayoutConstants.zeroSpacing
        layout.minimumInteritemSpacing = LayoutConstants.zeroSpacing
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .white
        collectionView.register(OnboardingCollectionViewCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    private lazy var progressView: OnboardingProgressView = {
        let view = OnboardingProgressView()
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        let closeImage = UIImage(systemName: "xmark")?.withConfiguration(
            UIImage.SymbolConfiguration(
                pointSize: Constants.closeButtonSymbolSize,
                weight: Constants.closeButtonSymbolWeight
            )
        )
        button.setImage(closeImage, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init
    init(viewModel: OnboardingViewModel = OnboardingViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) is not supported for OnboardingViewController. Use init(viewModel:viewModelFactory:) instead.")
        return nil
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupBindings()
        setupProgressView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        view.backgroundColor = .white
        
        [collectionView, progressView, closeButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            progressView.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.progressViewTopMargin),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: Constants.progressViewHeight),
            
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.closeButtonTopMargin),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.closeButtonLeadingMargin),
            closeButton.widthAnchor.constraint(equalToConstant: Constants.closeButtonSize),
            closeButton.heightAnchor.constraint(equalToConstant: Constants.closeButtonSize)
        ])
    }
    
    private func setupBindings() {
        viewModel.$currentPage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] currentPage in
                self?.progressView.currentPage = currentPage
                self?.scrollToPage(currentPage)
                self?.updateCloseButtonVisibility(for: currentPage)
            }
            .store(in: &cancellables)
        
        viewModel.$slides
            .receive(on: DispatchQueue.main)
            .sink { [weak self] slides in
                self?.progressView.numberOfPages = slides.count
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func setupProgressView() {
        progressView.numberOfPages = viewModel.slides.count
        progressView.currentPage = Constants.initialPageIndex
        updateCloseButtonVisibility(for: Constants.initialPageIndex)
    }
    
    private func updateCloseButtonVisibility(for page: Int) {
        closeButton.isHidden = page == Constants.lastPageIndex
    }
    
    private func scrollToPage(_ page: Int) {
        let indexPath = IndexPath(item: page, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    private func handleLoginButtonTapped() {
        completeOnboarding()
    }
    
    @objc private func closeButtonTapped() {
        completeOnboarding()
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: Constants.onboardingCompletedKey)
        onCompletion?()
    }
}

// MARK: - UICollectionViewDataSource
extension OnboardingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.slides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: OnboardingCollectionViewCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        
        if let slide = viewModel.getSlide(at: indexPath.item) {
            cell.configure(with: slide)
            cell.onLoginButtonTapped = { [weak self] in
                self?.handleLoginButtonTapped()
            }
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension OnboardingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.bounds.size
    }
}

// MARK: - UIScrollViewDelegate
extension OnboardingViewController {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageIndex = Int(scrollView.contentOffset.x / scrollView.frame.width)
        viewModel.currentPage = pageIndex
    }
}
