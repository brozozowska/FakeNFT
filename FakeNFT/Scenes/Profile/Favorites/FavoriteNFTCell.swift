import UIKit
import Kingfisher

final class FavoriteNFTCell: UICollectionViewCell, ReuseIdentifying {
    
    // MARK: - Constants
    
    private enum Constants {
        static let nftImageSize: CGFloat = 80
        static let nftImageCornerRadius: CGFloat = 12
        static let likeButtonSize: CGFloat = 30
        static let likeButtonTopInset: CGFloat = -6
        static let likeButtonTrailingInset: CGFloat = 6
        static let textLeadingInset: CGFloat = 12
        static let ratingTopInset: CGFloat = 4
        static let priceTopInset: CGFloat = 4
        static let ratingHeight: CGFloat = 12
    }
    
    // MARK: - Callbacks
    
    var onLikeTapped: (() -> Void)?
    
    // MARK: - UI Components
    
    private lazy var nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 12
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyBold
        label.textColor = .black
        return label
    }()
    
    private lazy var ratingView: RatingView = {
        let view = RatingView()
        return view
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.textColor = .black
        return label
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    // MARK: - Configuration
    
    func configure(with nft: Nft, isLiked: Bool) {
        nameLabel.text = nft.name
        ratingView.rating = nft.rating
        priceLabel.text = "\(nft.price) ETH"
        
        let likeImage = isLiked ? UIImage(resource: .likeActive) : UIImage(resource: .likeInactive)
            likeButton.setImage(likeImage, for: .normal)
        
        if let imageURL = nft.images.first {
            nftImageView.kf.setImage(with: imageURL)
        }
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        contentView.backgroundColor = .white
        
        [nftImageView, likeButton, nameLabel, ratingView, priceLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nftImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            nftImageView.widthAnchor.constraint(equalToConstant: Constants.nftImageSize),
            nftImageView.heightAnchor.constraint(equalToConstant: Constants.nftImageSize),
            
            likeButton.topAnchor.constraint(equalTo: nftImageView.topAnchor, constant: Constants.likeButtonTopInset),
            likeButton.trailingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: Constants.likeButtonTrailingInset),
            likeButton.widthAnchor.constraint(equalToConstant: Constants.likeButtonSize),
            likeButton.heightAnchor.constraint(equalToConstant: Constants.likeButtonSize),
            
            nameLabel.topAnchor.constraint(equalTo: nftImageView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: Constants.textLeadingInset),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            ratingView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Constants.ratingTopInset),
            ratingView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            ratingView.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            ratingView.heightAnchor.constraint(equalToConstant: Constants.ratingHeight),
            
            priceLabel.topAnchor.constraint(equalTo: ratingView.bottomAnchor, constant: Constants.priceTopInset),
            priceLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor)
        ])
    }
    
    @objc private func likeButtonTapped() {
        onLikeTapped?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nftImageView.kf.cancelDownloadTask()
        nftImageView.image = nil
        onLikeTapped = nil
    }
}
