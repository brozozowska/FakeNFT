import UIKit
import Kingfisher

final class MyNFTCell: UITableViewCell, ReuseIdentifying {
    
    // MARK: - Constants
    
    private enum Constants {
        static let nftImageSize: CGFloat = 108
        static let nftImageCornerRadius: CGFloat = 12
        static let horizontalInset: CGFloat = 16
        static let imageToTextSpacing: CGFloat = 10
        static let textToPriceSpacing: CGFloat = 36
        static let nameTopInset: CGFloat = 23
        static let ratingTopInset: CGFloat = 4
        static let authorTopInset: CGFloat = 4
        static let priceTopInset: CGFloat = 32
        static let priceWidth: CGFloat = 85
        static let ratingViewWidth: CGFloat = 68
        static let ratingViewHeight: CGFloat = 12
    }
    
    // MARK: - UI Components
    
    private lazy var nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 12
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .headline4
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.textColor = .black
        label.text = NSLocalizedString("MyNFTs.price", comment: "Price")
        label.textAlignment = .left
        return label
    }()
    
    private lazy var priceValueLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyBold
        label.textColor = .black
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    private lazy var ratingView: RatingView = {
        let view = RatingView()
        return view
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    // MARK: - Configuration
    
    func configure(with nft: Nft) {
        nameLabel.text = nft.name
        authorLabel.text = "от \(nft.author)"
        priceValueLabel.text = "\(nft.price) ETH"
        ratingView.rating = nft.rating
        
        if let imageURL = nft.images.first {
            nftImageView.kf.setImage(with: imageURL)
        }
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        contentView.backgroundColor = .white
        selectionStyle = .none
        
        [nftImageView, nameLabel, authorLabel, priceLabel, priceValueLabel, ratingView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalInset),
            nftImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nftImageView.widthAnchor.constraint(equalToConstant: Constants.nftImageSize),
            nftImageView.heightAnchor.constraint(equalToConstant: Constants.nftImageSize),
            
            nameLabel.topAnchor.constraint(equalTo: nftImageView.topAnchor, constant: Constants.nameTopInset),
            nameLabel.leadingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: Constants.imageToTextSpacing),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: priceLabel.leadingAnchor, constant: -Constants.textToPriceSpacing),
            
            ratingView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Constants.ratingTopInset),
            ratingView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            ratingView.widthAnchor.constraint(equalToConstant: Constants.ratingViewWidth),
            ratingView.heightAnchor.constraint(equalToConstant: Constants.ratingViewHeight),
            
            authorLabel.topAnchor.constraint(equalTo: ratingView.bottomAnchor, constant: Constants.authorTopInset),
            authorLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            authorLabel.trailingAnchor.constraint(lessThanOrEqualTo: priceLabel.leadingAnchor, constant: -Constants.textToPriceSpacing),
            
            priceLabel.topAnchor.constraint(equalTo: nftImageView.topAnchor, constant: Constants.priceTopInset),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalInset),
            priceLabel.widthAnchor.constraint(equalToConstant: Constants.priceWidth),
            
            priceValueLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 2),
            priceValueLabel.leadingAnchor.constraint(equalTo: priceLabel.leadingAnchor),
            priceValueLabel.trailingAnchor.constraint(equalTo: priceLabel.trailingAnchor)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nftImageView.kf.cancelDownloadTask()
        nftImageView.image = nil
        ratingView.rating = .zero
    }
}
