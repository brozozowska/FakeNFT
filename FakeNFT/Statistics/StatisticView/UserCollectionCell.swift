//
//  UserCollectionCell.swift
//  FakeNFT
//
//  Created by Yanye Velikanova on 11/5/25.
//

import UIKit
import Kingfisher

final class UserCollectionCell: UICollectionViewCell {

    static let identifier = "UserCollectionCell"

    var onHeartTap: (() -> Void)?
    var onCartTap: (() -> Void)?

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

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        heartButton.addTarget(self, action: #selector(heartTapped), for: .touchUpInside)
        cartButton.addTarget(self, action: #selector(cartTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nftImageView.kf.cancelDownloadTask()
        nftImageView.image = nil
    }

    func configure(with model: UserCollectionCellModel) {
        nameLabel.text = model.displayTitle
        priceLabel.text = model.priceString

        if
            let urlString = model.imageURL,
            let url = URL(string: urlString)
        {
            let placeholder = UIImage(systemName: "photo")
            nftImageView.kf.setImage(with: url, placeholder: placeholder)
        } else {
            nftImageView.image = UIImage(systemName: "photo")
        }

        starsImageView.image = UIImage(named: model.ratingImageName)

        if model.isFavorite {
            heartButton.tintColor = .systemRed
            heartButton.setImage(UIImage(named: "Active")?.withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            heartButton.tintColor = .white
            heartButton.setImage(UIImage(named: "NoActive")?.withRenderingMode(.alwaysTemplate), for: .normal)
        }

        let cartImageName = model.isInCart ? "Delete" : "add"
        cartButton.setImage(UIImage(named: cartImageName), for: .normal)
    }

    @objc private func heartTapped() {
        onHeartTap?()
    }

    @objc private func cartTapped() {
        onCartTap?()
    }

    private func setupUI() {
        contentView.addSubview(nftImageView)
        contentView.addSubview(heartButton)
        contentView.addSubview(starsImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(cartButton)

        NSLayoutConstraint.activate([
            nftImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            nftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nftImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nftImageView.heightAnchor.constraint(equalToConstant: 108),

            heartButton.topAnchor.constraint(equalTo: nftImageView.topAnchor, constant: 5),
            heartButton.trailingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: -5),
            heartButton.widthAnchor.constraint(equalToConstant: 40),
            heartButton.heightAnchor.constraint(equalToConstant: 40),

            starsImageView.topAnchor.constraint(equalTo: nftImageView.bottomAnchor, constant: 6),
            starsImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            starsImageView.widthAnchor.constraint(equalToConstant: 80),
            starsImageView.heightAnchor.constraint(equalToConstant: 14),

            nameLabel.topAnchor.constraint(equalTo: starsImageView.bottomAnchor, constant: 6),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: cartButton.leadingAnchor, constant: -6),

            cartButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            cartButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cartButton.widthAnchor.constraint(equalToConstant: 40),
            cartButton.heightAnchor.constraint(equalToConstant: 40),

            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}
