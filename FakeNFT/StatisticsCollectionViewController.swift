//
//  StatisticsCollectionViewController.swift
//  FakeNFT
//
//  Created by Yanye Velikanova on 11/3/25.
//

import UIKit

final class StatisticsCollectionViewController: UIViewController {

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    private let placeholderLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Здесь будут NFT"
        l.textAlignment = .center
        l.textColor = .secondaryLabel
        l.font = .systemFont(ofSize: 17, weight: .regular)
        return l
    }()

    private var items: [String] = [] 

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(StatisticsNFTCell.self, forCellWithReuseIdentifier: "StatisticsNFTCell")

        view.addSubview(collectionView)
        view.addSubview(placeholderLabel)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        updatePlaceholder()
    }

    private func updatePlaceholder() {
        placeholderLabel.isHidden = !items.isEmpty
        collectionView.isHidden = items.isEmpty
    }
}

extension StatisticsCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatisticsNFTCell", for: indexPath) as! StatisticsNFTCell
        cell.configure(title: items[indexPath.item])
        return cell
    }
}

extension StatisticsCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let inset: CGFloat = 16
        let spacing: CGFloat = 12
        let columns: CGFloat = 2
        let total = inset * 2 + spacing * (columns - 1)
        let width = (collectionView.bounds.width - total) / columns
        return CGSize(width: width, height: 160)
    }
}

final class StatisticsNFTCell: UICollectionViewCell {

    private let card = UIView()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = .clear

        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 12

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .tertiarySystemFill
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2

        contentView.addSubview(card)
        card.addSubview(imageView)
        card.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            imageView.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            imageView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            imageView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            imageView.heightAnchor.constraint(equalToConstant: 100),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(title: String) {
        titleLabel.text = title
    }
}
