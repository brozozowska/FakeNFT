//
//  UserCollectionCell.swift
//  FakeNFT
//
//  Created by Yanye Velikanova on 11/5/25.
//

import UIKit

final class UserCollectionCell: UICollectionViewCell {

    static let identifier = "UserCollectionCell"

    // MARK: - Callbacks

    var onHeartTap: (() -> Void)?
    var onCartTap: (() -> Void)?

    // MARK: - UI

    private let nftImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 12
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let heartButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.tintColor = .white
        b.imageView?.contentMode = .scaleAspectFit
        return b
    }()


    private let starsImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .bold)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let priceLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let cartButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.tintColor = .label
        return b
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        heartButton.addTarget(self, action: #selector(heartTapped), for: .touchUpInside)
        cartButton.addTarget(self, action: #selector(cartTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure

    func configure(with model: UserCollectionCellModel) {

        // Имя
        nameLabel.text = model.displayTitle

        // Цена
        priceLabel.text = model.priceString

        // Картинка
        if
            let urlString = model.imageURL,
            let url = URL(string: urlString)
        {
            loadImage(from: url)
        } else {
            nftImageView.image = UIImage(systemName: "photo")
        }

        // Рейтинг (звёзды)
        starsImageView.image = UIImage(named: model.ratingImageName)

        // Избранное
        if model.isFavorite {
            heartButton.tintColor = .systemRed
            let img = UIImage(named: "Active")?.withRenderingMode(.alwaysTemplate)
            heartButton.setImage(img, for: .normal)
        } else {
            heartButton.tintColor = .white
            let img = UIImage(named: "NoActive")?.withRenderingMode(.alwaysTemplate)
            heartButton.setImage(img, for: .normal)
        }

        // Корзина
        let cartImageName = model.isInCart ? "Delete" : "add"
        cartButton.setImage(UIImage(named: cartImageName), for: .normal)
    }

    // MARK: - Actions

    @objc private func heartTapped() {
        onHeartTap?()
    }

    @objc private func cartTapped() {
        onCartTap?()
    }

    // MARK: - Setup UI

    private func setupUI() {
        contentView.addSubview(nftImageView)
        contentView.addSubview(heartButton)
        contentView.addSubview(starsImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(cartButton)

        NSLayoutConstraint.activate([
            // Image
            nftImageView.topAnchor.constraint(equalTo: contentView.topAnchor)
                ,
            nftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nftImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nftImageView.heightAnchor.constraint(equalToConstant: 108),

            // Heart icon
            heartButton.topAnchor.constraint(equalTo: nftImageView.topAnchor, constant: 5),
            heartButton.trailingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: -5),
            heartButton.widthAnchor.constraint(equalToConstant: 40),
            heartButton.heightAnchor.constraint(equalToConstant: 40),

            // Stars
            starsImageView.topAnchor.constraint(equalTo: nftImageView.bottomAnchor, constant: 6),
            starsImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            starsImageView.widthAnchor.constraint(equalToConstant: 80),
            starsImageView.heightAnchor.constraint(equalToConstant: 14),

            // Name
            nameLabel.topAnchor.constraint(equalTo: starsImageView.bottomAnchor, constant: 6),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: cartButton.leadingAnchor, constant: -6),

            // Cart icon
            cartButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            cartButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cartButton.widthAnchor.constraint(equalToConstant: 40),
            cartButton.heightAnchor.constraint(equalToConstant: 40),

            // Price
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    // MARK: - Image loader

    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data,
                  let img = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.nftImageView.image = img
            }
        }.resume()
    }
}
