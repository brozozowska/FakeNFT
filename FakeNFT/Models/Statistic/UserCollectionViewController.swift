//
//  UserCollectionViewController.swift
//  FakeNFT
//
//  Created by Yanye Velikanova on 11/5/25.
//

import UIKit

final class UserCollectionViewController: UIViewController {

    private let viewModel: UserCollectionViewModel
    private let collectionView: UICollectionView
    private let loader = UIActivityIndicatorView(style: .large)
    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text = "У пользователя пока нет NFT"
        l.textAlignment = .center
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        l.isHidden = true
        return l
    }()

    init(viewModel: UserCollectionViewModel) {
        self.viewModel = viewModel

        let layout = UICollectionViewFlowLayout()
        let w = (UIScreen.main.bounds.width - 16*2 - 16*2) / 3 // 3 в ряд
        layout.itemSize = CGSize(width: w, height: w + 60)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Коллекция NFT"
        view.backgroundColor = .systemBackground

        setupCollection()
        setupLoader()
        setupEmpty()

        bind()
        viewModel.load()
    }

    private func setupCollection() {
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.register(UserCollectionCell.self, forCellWithReuseIdentifier: UserCollectionCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
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
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func bind() {
        viewModel.onLoading = { [weak self] isLoading in
            guard let self else { return }
            if isLoading {
                self.loader.startAnimating()
                self.collectionView.alpha = 0
                self.emptyLabel.isHidden = true
            } else {
                self.loader.stopAnimating()
                self.collectionView.alpha = 1
            }
        }

        viewModel.onItems = { [weak self] items in
            self?.emptyLabel.isHidden = !items.isEmpty
            self?.collectionView.reloadData()
        }

        viewModel.onError = { [weak self] message in
            guard let self else { return }
            let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}

extension UserCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
