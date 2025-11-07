import UIKit
import Combine

final class CollectionViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: CollectionViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionHeaderView.reuseIdentifier)
        collectionView.register(NFTCell.self, forCellWithReuseIdentifier: NFTCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.contentInsetAdjustmentBehavior = .never
        return collectionView
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Init
    
    init(viewModel: CollectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) is not supported for CollectionViewController. Use init(viewModel:) instead.")
        return nil
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        setupConstraints()
        setupBindings()
        setupViewModelCallbacks()
        viewModel.loadCollectionData()
    }
    
    // MARK: - Private Methods
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .black
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        title = ""
        
        [collectionView, activityIndicator].forEach {
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
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                isLoading ? self?.showLoading() : self?.hideLoading()
            }
            .store(in: &cancellables)
        
        viewModel.$nfts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$errorModel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorModel in
                if let errorModel = errorModel {
                    self?.showError(errorModel)
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupViewModelCallbacks() {
        viewModel.onAuthorWebsiteTapped = { [weak self] in
            self?.openAuthorWebsite()
        }
        
        viewModel.onNFTSeeMoreTapped = { [weak self] nftId in
            self?.showNftDetail(nftId)
        }
    }
    
    private func openAuthorWebsite() {
        guard let authorURL = URL(string: "https://practicum.yandex.com/ios-developer/?from=catalog") else { return }
        
        navigationItem.backButtonTitle = ""
        let webViewController = WebViewViewController(url: authorURL)
        navigationController?.pushViewController(webViewController, animated: true)
    }
    
    private func showNftDetail(_ nftId: String) {
        print("Show detail for NFT: \(nftId)")
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1/3),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(192)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 20
            section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0)
            
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(400)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 20,
                leading: 0,
                bottom: 20,
                trailing: 0
            )
            
            return section
        }
        return layout
    }
}

// MARK: - UICollectionViewDataSource

extension CollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.nftsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: NFTCell.reuseIdentifier,
            for: indexPath
        ) as? NFTCell else {
            return UICollectionViewCell()
        }
        
        let nft = viewModel.nft(at: indexPath.row)
        let isLiked = viewModel.isLiked(nftId: nft.id)
        let isInCart = viewModel.isInCart(nftId: nft.id)
        
        cell.configure(with: nft, isLiked: isLiked, isInCart: isInCart)
        
        cell.onLikeTapped = { [weak self] in
            self?.viewModel.toggleLike(for: nft.id)
            cell.configure(with: nft, isLiked: self?.viewModel.isLiked(nftId: nft.id) ?? false, isInCart: isInCart)
        }
        
        cell.onCartTapped = { [weak self] in
            self?.viewModel.toggleCart(for: nft.id)
            cell.configure(with: nft, isLiked: isLiked, isInCart: self?.viewModel.isInCart(nftId: nft.id) ?? false)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: CollectionHeaderView.reuseIdentifier,
                for: indexPath
              ) as? CollectionHeaderView else {
            return UICollectionReusableView()
        }
        
        headerView.configure(with: viewModel.collection, author: viewModel.authorName)
        headerView.onAuthorTapped = { [weak self] in
            self?.viewModel.openAuthorWebsite()
        }
        
        return headerView
    }
}

// MARK: - UICollectionViewDelegate

extension CollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let nft = viewModel.nft(at: indexPath.row)
        viewModel.showNftDetail(nft.id)
    }
}

// MARK: - LoadingView & ErrorView

extension CollectionViewController: LoadingView, ErrorView {
    func showLoading() {
        activityIndicator.startAnimating()
    }
    
    func hideLoading() {
        activityIndicator.stopAnimating()
    }
}
