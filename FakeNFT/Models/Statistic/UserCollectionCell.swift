//
//  UserCollectionCell.swift
//  FakeNFT
//
//  Created by Yanye Velikanova on 11/5/25.
//

import UIKit

final class UserCollectionCell: UICollectionViewCell {
    static let identifier = "UserCollectionCell"

    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let ratingStack = UIStackView()
    private let cartButton  = UIButton(type: .system)
    private static let cache = NSCache<NSString, UIImage>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) { nil }

    func configure(with model: UserCollectionCellModel) {
        titleLabel.text = model.displayTitle
        setImage(urlString: model.imageURL)

        // цена (если нет — скрываем)
        if let price = model.priceString {
            priceLabel.text = price
            priceLabel.isHidden = false
        } else {
            priceLabel.isHidden = true
        }

        // рейтинг (если нет — скрываем)
        if let r = model.rating {
            setStars(r)
            ratingStack.isHidden = false
        } else {
            ratingStack.isHidden = true
        }
    }

    private func setupUI() {
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true

        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .secondarySystemBackground
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true

        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.numberOfLines = 1

        priceLabel.font = .systemFont(ofSize: 14)
        priceLabel.textColor = .secondaryLabel

        ratingStack.axis = .horizontal
        ratingStack.spacing = 2

        cartButton.setImage(UIImage(systemName: "bag"), for: .normal)

        let v = UIStackView(arrangedSubviews: [ratingStack, titleLabel, priceLabel])
        v.axis = .vertical
        v.spacing = 6

        [imageView, v, cartButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),

            v.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            v.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            v.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            cartButton.topAnchor.constraint(equalTo: v.bottomAnchor, constant: 8),
            cartButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cartButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    private func setStars(_ rating: Int) {
        ratingStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for i in 1...5 {
            let iv = UIImageView(image: UIImage(systemName: i <= rating ? "star.fill" : "star"))
            iv.tintColor = .systemYellow
            ratingStack.addArrangedSubview(iv)
        }
    }

    private func setImage(urlString: String?) {
        imageView.image = nil
        guard let s = urlString, let url = URL(string: s) else { return }

        if let cached = Self.cache.object(forKey: s as NSString) {
            imageView.image = cached
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data, let img = UIImage(data: data) else { return }
            Self.cache.setObject(img, forKey: s as NSString)
            DispatchQueue.main.async { [weak self] in self?.imageView.image = img }
        }.resume()
    }
}
