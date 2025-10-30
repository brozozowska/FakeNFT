import UIKit
import Kingfisher

final class DeleteConfirmationView: UIView {

    // MARK: - Constants
    private enum Constants {
        enum Layout {
            static let imageSize: CGFloat = 108
            static let spacingImageToLabel: CGFloat = 12
            static let spacingLabelToButtons: CGFloat = 20
            static let buttonsSpacing: CGFloat = 8
            static let buttonHeight: CGFloat = 44
            static let imageCornerRadius: CGFloat = 16
            static let buttonCornerRadius: CGFloat = 12
            static let horizontalContainerInset: CGFloat = 56
        }
        enum Typography {
            static let messageFontSize: CGFloat = 13
            static let buttonFontSize: CGFloat = 17
        }
        enum Strings {
            static let messageKey = "Cart.delete.confirm.message"
            static let deleteKey = "Cart.delete.confirm.remove"
            static let cancelKey = "Cart.delete.confirm.cancel"
        }
    }

    // MARK: - Public callbacks
    var onConfirm: (() -> Void)?
    var onCancel: (() -> Void)?

    // MARK: - UI
    private lazy var blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemUltraThinMaterial)
        let view = UIVisualEffectView(effect: blur)
        return view
    }()

    private lazy var contentContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = Constants.Layout.imageCornerRadius
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .label
        label.font = .systemFont(ofSize: Constants.Typography.messageFontSize, weight: .regular)
        label.numberOfLines = 0
        label.text = NSLocalizedString(Constants.Strings.messageKey, comment: "Delete confirmation message")
        return label
    }()

    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString(Constants.Strings.deleteKey, comment: "Delete"), for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: Constants.Typography.buttonFontSize, weight: .regular)
        button.backgroundColor = .label
        button.layer.cornerRadius = Constants.Layout.buttonCornerRadius
        button.addTarget(self, action: #selector(handleConfirm), for: .touchUpInside)
        return button
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString(Constants.Strings.cancelKey, comment: "Cancel"), for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: Constants.Typography.buttonFontSize, weight: .regular)
        button.backgroundColor = .label
        button.layer.cornerRadius = Constants.Layout.buttonCornerRadius
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()

    private lazy var buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = Constants.Layout.buttonsSpacing
        stack.distribution = .fillEqually
        return stack
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        return stack
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupHierarchy()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    func configure(imageURL: URL?) {
        if let url = imageURL {
            imageView.kf.setImage(with: url)
        } else {
            imageView.image = nil
        }
    }

    func present(in container: UIView) {
        frame = container.bounds
        container.addSubview(self)
        layoutIfNeeded()
        animateIn()
    }

    func dismiss(completion: (() -> Void)? = nil) {
        animateOut(completion: { [weak self] in
            self?.removeFromSuperview()
            completion?()
        })
    }

    // MARK: - Setup
    private func setupHierarchy() {
        buttonsStack.addArrangedSubview(deleteButton)
        buttonsStack.addArrangedSubview(cancelButton)

        contentStack.addArrangedSubview(imageView)
        contentStack.addArrangedSubview(messageLabel)
        contentStack.addArrangedSubview(buttonsStack)

        contentStack.setCustomSpacing(Constants.Layout.spacingImageToLabel, after: imageView)
        contentStack.setCustomSpacing(Constants.Layout.spacingLabelToButtons, after: messageLabel)

        addSubview(blurView)
        addSubview(contentContainer)
        
        contentContainer.addSubview(contentStack)

        [
            blurView,
            contentContainer,
            contentStack
        ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            contentContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.Layout.horizontalContainerInset),
            contentContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.Layout.horizontalContainerInset),

            contentStack.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            contentStack.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),

            imageView.widthAnchor.constraint(equalToConstant: Constants.Layout.imageSize),
            imageView.heightAnchor.constraint(equalToConstant: Constants.Layout.imageSize),

            deleteButton.heightAnchor.constraint(equalToConstant: Constants.Layout.buttonHeight),
            cancelButton.heightAnchor.constraint(equalToConstant: Constants.Layout.buttonHeight),
            buttonsStack.widthAnchor.constraint(equalTo: contentStack.widthAnchor)
        ])
    }

    // MARK: - Actions
    @objc private func handleConfirm() {
        onConfirm?()
    }
    
    @objc private func handleCancel() {
        onCancel?()
    }

    // MARK: - Animations
    private func animateIn() {
        contentContainer.alpha = 0
        blurView.alpha = 0
        contentContainer.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseOut]) {
            self.blurView.alpha = 1
            self.contentContainer.alpha = 1
            self.contentContainer.transform = .identity
        }
    }

    private func animateOut(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseIn]) {
            self.blurView.alpha = 0
            self.contentContainer.alpha = 0
            self.contentContainer.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        } completion: { _ in
            completion()
        }
    }
}
