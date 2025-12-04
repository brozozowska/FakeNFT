import UIKit

// MARK: - PaymentSuccessViewController
final class PaymentSuccessViewController: UIViewController {
    
    // MARK: - Callbacks
    var onClose: (() -> Void)?
    
    // MARK: - Constants
    private enum Constants {
        enum Layout {
            static let imageTopOffset: CGFloat = 196
            static let sideInset: CGFloat = 36
            static let buttonSideInset: CGFloat = 16
            static let buttonBottomInset: CGFloat = 16
            static let buttonHeight: CGFloat = 60
            static let spacingBetweenImageAndTitle: CGFloat = 20
        }
        
        enum Typography {
            static let titleFontSize: CGFloat = 22
            static let buttonFontSize: CGFloat = 17
        }
        
        enum Appearance {
            static let buttonCornerRadius: CGFloat = 16
        }
        
        enum Strings {
            static let messageKey = "Payment.success.title"
            static let buttonTitleKey = "Payment.success.button"
        }
        
        enum Images {
            static let successImage: UIImage = UIImage(resource: .successPay)
        }
    }
    
    // MARK: - UI
    private let imageView: UIImageView = {
        let view = UIImageView(image: Constants.Images.successImage)
        view.contentMode = .scaleAspectFit
        return view
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString(Constants.Strings.messageKey, comment: "Success payment title")
        label.font = .systemFont(ofSize: Constants.Typography.titleFontSize, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()

    private let button: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .label
        button.setTitle(NSLocalizedString(Constants.Strings.buttonTitleKey, comment: "Return to main screen"), for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: Constants.Typography.buttonFontSize, weight: .bold)
        button.layer.cornerRadius = Constants.Appearance.buttonCornerRadius
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupHierarchy()
        setupConstraints()
    }
    
    // MARK: - Setup
    private func setupHierarchy() {
        [
            imageView,
            label,
            button
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.Layout.imageTopOffset),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.sideInset),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Layout.sideInset),

            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.Layout.spacingBetweenImageAndTitle),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.sideInset),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Layout.sideInset),

            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.buttonSideInset),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Layout.buttonSideInset),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.Layout.buttonBottomInset),
            button.heightAnchor.constraint(equalToConstant: Constants.Layout.buttonHeight)
        ])
    }
    
    // MARK: - Actions
    @objc private func closeTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onClose?()
        }
    }
}
