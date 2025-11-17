//
//  UserCollectionViewController.swift
//  FakeNFT
//
//  Created by Yanye Velikanova on 11/5/25.
//

import UIKit

final class UserCollectionViewController: UIViewController {

    // MARK: - Dependencies
    private let viewModel: UserCollectionViewModel

    // MARK: - UI

    private let customNavBar = StatisticsCustomNavBar()
    private let collectionView: UICollectionView
    private let loader = UIActivityIndicatorView(style: .large)

    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text = "У пользователя пока нет NFT"
        l.textAlignment = .center
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        l.isHidden = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Init

    init(viewModel: UserCollectionViewModel) {
        self.viewModel = viewModel

       
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        let sideInset: CGFloat = 16
        let interItemSpacing: CGFloat = 9
        let screenWidth = UIScreen.main.bounds.width
        let totalSpacing = sideInset * 2 + interItemSpacing * 2
        let itemWidth = floor((screenWidth - totalSpacing) / 3)

        layout.itemSize = CGSize(width: itemWidth, height: 192)
        layout.minimumInteritemSpacing = interItemSpacing
        layout.minimumLineSpacing = 20
        layout.sectionInset = .zero

        self.collectionView = UICollectionView(frame: .zero,
                                               collectionViewLayout: layout)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background

        setupNavBar()
        setupCollection()
        setupLoader()
        setupEmpty()

        bind()
        viewModel.load()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Setup UI

    private func setupNavBar() {
        customNavBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(customNavBar)

        customNavBar.isBackButtonInvisible(it_s: false)
        customNavBar.isSortButtonInvisible(it_s: true)
        customNavBar.isTitleInvisible(it_s: false)
        customNavBar.titleLabel.text = "Коллекция NFT"

        customNavBar.backButton.addTarget(self,
                                          action: #selector(backButtonTapped),
                                          for: .touchUpInside)

        NSLayoutConstraint.activate([
            customNavBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 42)
        ])
    }

    private func setupCollection() {
        collectionView.backgroundColor = .background
        collectionView.dataSource = self
        collectionView.register(
            UserCollectionCell.self,
            forCellWithReuseIdentifier: UserCollectionCell.identifier
        )

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupLoader() {
        loader.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loader)

        NSLayoutConstraint.activate([
            loader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupEmpty() {
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    // MARK: - Binding

    private func bind() {
        viewModel.onLoading = { [weak self] isLoading in
            guard let self else { return }
            if isLoading {
                loader.startAnimating()
                collectionView.alpha = 0
                emptyLabel.isHidden = true
            } else {
                loader.stopAnimating()
                collectionView.alpha = 1
            }
        }

        viewModel.onItems = { [weak self] items in
            guard let self else { return }
            emptyLabel.isHidden = !items.isEmpty
            collectionView.reloadData()
        }

        viewModel.onError = { [weak self] message in
            guard let self else { return }
            let alert = UIAlertController(title: "Ошибка",
                                          message: message,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    // MARK: - Actions

    @objc private func backButtonTapped() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension UserCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        viewModel.items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard indexPath.item < viewModel.items.count else { return UICollectionViewCell() }

        let id = UserCollectionCell.identifier
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id,
                                                            for: indexPath) as? UserCollectionCell
        else { return UICollectionViewCell() }

        cell.configure(with: viewModel.items[indexPath.item])
        return cell
    }
}
