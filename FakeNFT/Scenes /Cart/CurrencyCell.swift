import UIKit
import Kingfisher

final class CurrencyCell: UICollectionViewCell {
    
    // MARK: - Constants
    private enum Constants {
        enum Layout {
            static let horizontalInset: CGFloat = 12
            static let spacingBetweenIconAndLabels: CGFloat = 4
            static let textStackSpacing: CGFloat = 2
        }
        
        enum Typography {
            static let titleFontSize: CGFloat = 13
            static let tickerFontSize: CGFloat = 13
        }
        
        enum Appearance {
            static let cornerRadius: CGFloat = 12
            static let iconCornerRadius: CGFloat = 6
            static let iconSize: CGFloat = 36
        }
        
        enum Strings {
            static let placeholderSystemImageName = "bitcoinsign.circle"
        }
    }
    
    // MARK: - Reuse Identifier
    static let reuseIdentifier = "CurrencyCell"
    
    // MARK: - UI
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = Constants.Appearance.iconCornerRadius
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.Typography.titleFontSize, weight: .regular)
        label.textColor = .label
        return label
    }()
    
    private lazy var tickerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.Typography.tickerFontSize, weight: .regular)
        label.textColor = .systemGreen
        return label
    }()
    
    private lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, tickerLabel])
        stack.axis = .vertical
        stack.spacing = Constants.Layout.textStackSpacing
        return stack
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHierarchy()
        setupConstraints()
        configureAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure
    func configure(with currency: Currency) {
        titleLabel.text = currency.title
        tickerLabel.text = currency.name
        
        iconImageView.kf.setImage(
            with: currency.imageURL,
            placeholder: UIImage(systemName: Constants.Strings.placeholderSystemImageName)
        )
    }
    
    // MARK: - Setup
    private func setupHierarchy() {
        contentView.addSubview(iconImageView)
        contentView.addSubview(textStack)
    }
    
    private func setupConstraints() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        textStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Layout.horizontalInset),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.heightAnchor.constraint(equalToConstant: Constants.Appearance.iconSize),
            iconImageView.widthAnchor.constraint(equalToConstant: Constants.Appearance.iconSize),
            
            textStack.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: Constants.Layout.spacingBetweenIconAndLabels),
            textStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    private func configureAppearance() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = Constants.Appearance.cornerRadius
        contentView.layer.masksToBounds = true
    }
}
