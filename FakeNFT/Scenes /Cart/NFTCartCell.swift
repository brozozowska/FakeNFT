import UIKit
import Kingfisher

final class NFTCartCell: UITableViewCell, ReuseIdentifying {

    // MARK: - Constants
    private struct Constants {
        static let contentInset: CGFloat = 16
        static let imageSize: CGFloat = 108
        static let titleTopOffset: CGFloat = 8
        static let priceLabelBottomOffset: CGFloat = 8
        static let titleToRemoveSpacing: CGFloat = 12
        static let titleToRatingSpacing: CGFloat = 6
        static let ratingToPriceCaptionSpacing: CGFloat = 10
        static let priceCaptionToPriceSpacing: CGFloat = 6
        static let ratingStars: Int = 5
        static let ratingStarSpacing: CGFloat = 0
        static let ratingStarSize: CGFloat = 12
        static let previewCornerRadius: CGFloat = 12

        static let priceCaptionTextKey = "Cart.price"
        static let removeSystemImageName = "trash"
    }

    // MARK: - UI
    private lazy var previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = Constants.previewCornerRadius
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()

    private lazy var ratingView = StarRatingView(stars: Constants.ratingStars, starSize: Constants.ratingStarSize, spacing: Constants.ratingStarSpacing)

    private lazy var priceCaptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .label
        label.text = NSLocalizedString(Constants.priceCaptionTextKey, comment: "Price")
        return label
    }()

    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .label
        return label
    }()

    private lazy var removeButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(resource: .basketRemove)
        button.setImage(image, for: .normal)
        button.tintColor = .label
        return button
    }()

    // MARK: - Callbacks
    var onRemoveTapped: ((String) -> Void)?

    // MARK: - State
    private var currentId: String?

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupHierarchy()
        setupConstraints()
        removeButton.addTarget(self, action: #selector(handleRemove), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure
    func configure(with item: CartItem, priceFormatter: NumberFormatter, currencySuffix: String) {
        currentId = item.id
        titleLabel.text = item.title
        ratingView.rating = max(0, min(Constants.ratingStars, item.rating))

        if let url = item.imageURL {
            previewImageView.kf.setImage(with: url)
        } else {
            previewImageView.image = nil
        }

        let nsDecimal = item.price as NSDecimalNumber
        let priceString = priceFormatter.string(from: nsDecimal) ?? "\(item.price)"
        priceLabel.text = "\(priceString) \(currencySuffix)"
    }

    // MARK: - Actions
    @objc private func handleRemove() {
        if let id = currentId {
            onRemoveTapped?(id)
        }
    }

    // MARK: - Setup
    private func setupHierarchy() {
        contentView.addSubview(previewImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(ratingView)
        contentView.addSubview(priceCaptionLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(removeButton)
    }

    private func setupConstraints() {
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingView.translatesAutoresizingMaskIntoConstraints = false
        priceCaptionLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        removeButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            previewImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.contentInset),
            previewImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.contentInset),
            previewImageView.widthAnchor.constraint(equalToConstant: Constants.imageSize),
            previewImageView.heightAnchor.constraint(equalToConstant: Constants.imageSize),
            previewImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -Constants.contentInset),

            titleLabel.topAnchor.constraint(equalTo: previewImageView.topAnchor, constant: Constants.titleTopOffset),
            titleLabel.leadingAnchor.constraint(equalTo: previewImageView.trailingAnchor, constant: Constants.contentInset + 4),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: removeButton.leadingAnchor, constant: -Constants.titleToRemoveSpacing),

            ratingView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.titleToRatingSpacing),
            ratingView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            priceCaptionLabel.topAnchor.constraint(equalTo: ratingView.bottomAnchor, constant: Constants.ratingToPriceCaptionSpacing),
            priceCaptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            priceCaptionLabel.trailingAnchor.constraint(lessThanOrEqualTo: removeButton.leadingAnchor, constant: -Constants.titleToRemoveSpacing),

            priceLabel.topAnchor.constraint(equalTo: priceCaptionLabel.bottomAnchor, constant: Constants.priceCaptionToPriceSpacing),
            priceLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            priceLabel.trailingAnchor.constraint(lessThanOrEqualTo: removeButton.leadingAnchor, constant: -Constants.titleToRemoveSpacing),
            priceLabel.bottomAnchor.constraint(equalTo: previewImageView.bottomAnchor, constant: -Constants.priceLabelBottomOffset),

            removeButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            removeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.contentInset),
        ])
    }
}
