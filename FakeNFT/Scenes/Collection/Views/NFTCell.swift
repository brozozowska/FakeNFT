import UIKit
import Kingfisher

final class NFTCell: UICollectionViewCell {
    
    static let reuseIdentifier = "NFTCell"
    
    // MARK: - Constants
    
    private enum Constants {
        static let imageCornerRadius: CGFloat = 12
        static let buttonSize: CGFloat = 40
        static let cartButtonSize: CGFloat = 24
        static let ratingHeight: CGFloat = 12
        static let ratingTopInset: CGFloat = 8
        static let nameTopInset: CGFloat = 8
        static let priceTopInset: CGFloat = 4
        static let trailingInset: CGFloat = -8
        static let imageFadeDuration: TimeInterval = 0.3
        static let disabledAlpha: CGFloat = 0.5
        static let enabledAlpha: CGFloat = 1.0
    }
    
    // MARK: - Callbacks
    
    var onLikeTapped: (() -> Void)?
    var onCartTapped: (() -> Void)?
    
    // MARK: - UI Components
    
    private lazy var nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = Constants.imageCornerRadius
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(resource: .likeInactive), for: .normal)
        button.setImage(UIImage(resource: .likeActive), for: .selected)
        button.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var ratingView: RatingView = {
        let view = RatingView()
        return view
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyBold
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.textColor = .black
        return label
    }()
    
    private lazy var cartButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(resource: .cartAdd), for: .normal)
        button.setImage(UIImage(resource: .cartRemove), for: .selected)
        button.addTarget(self, action: #selector(cartButtonTapped), for: .touchUpInside)
        return button
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
    
    func setLikeButtonEnabled(_ enabled: Bool) {
        likeButton.isEnabled = enabled
        likeButton.alpha = enabled ? Constants.enabledAlpha : Constants.disabledAlpha
    }
    
    func setCartButtonEnabled(_ enabled: Bool) {
        cartButton.isEnabled = enabled
        cartButton.alpha = enabled ? Constants.enabledAlpha : Constants.disabledAlpha
    }
    
    func configure(with nft: Nft, isLiked: Bool, isInCart: Bool, isUpdating: Bool = false) {
        nameLabel.text = nft.name
        priceLabel.text = "\(nft.price) ETH"
        ratingView.rating = nft.rating
        
        loadNFTImage(for: nft)
        
        likeButton.isSelected = isLiked
        cartButton.isSelected = isInCart
        
        setLikeButtonEnabled(!isUpdating)
        setCartButtonEnabled(!isUpdating)
    }
    
    private func loadNFTImage(for nft: Nft) {
        nftImageView.image = nil
        nftImageView.backgroundColor = .lightGray
        
        if let imageURL = nft.images.first {
            nftImageView.kf.setImage(
                with: imageURL,
                options: [
                    .transition(.fade(Constants.imageFadeDuration)),
                    .cacheOriginalImage
                ]
            ) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        self?.nftImageView.backgroundColor = .clear
                    case .failure(_):
                        self?.nftImageView.backgroundColor = .lightGray
                    }
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        contentView.backgroundColor = .white
        
        [
            nftImageView,
            likeButton,
            ratingView,
            nameLabel,
            priceLabel,
            cartButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nftImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            nftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nftImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nftImageView.heightAnchor.constraint(equalTo: nftImageView.widthAnchor),
            
            likeButton.topAnchor.constraint(equalTo: nftImageView.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: nftImageView.trailingAnchor),
            likeButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            likeButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize),
            
            ratingView.topAnchor.constraint(equalTo: nftImageView.bottomAnchor, constant: Constants.ratingTopInset),
            ratingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            ratingView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            ratingView.heightAnchor.constraint(equalToConstant: Constants.ratingHeight),
            
            nameLabel.topAnchor.constraint(equalTo: ratingView.bottomAnchor, constant: Constants.nameTopInset),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: cartButton.leadingAnchor, constant: Constants.trailingInset),
            
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Constants.priceTopInset),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: cartButton.leadingAnchor, constant: Constants.trailingInset),
            priceLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),
            
            cartButton.centerYAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            cartButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cartButton.widthAnchor.constraint(equalToConstant: Constants.cartButtonSize),
            cartButton.heightAnchor.constraint(equalToConstant: Constants.cartButtonSize)
        ])
    }
    
    @objc private func likeButtonTapped() {
        onLikeTapped?()
    }
    
    @objc private func cartButtonTapped() {
        onCartTapped?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nftImageView.kf.cancelDownloadTask()
        nftImageView.image = nil
        nftImageView.backgroundColor = .lightGray
        likeButton.isSelected = false
        cartButton.isSelected = false
        ratingView.rating = .zero
        
        onLikeTapped = nil
        onCartTapped = nil
        
        setLikeButtonEnabled(true)
        setCartButtonEnabled(true)
    }
}
