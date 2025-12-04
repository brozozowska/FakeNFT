import UIKit

// MARK: - Avatar Image View

final class AvatarWithCameraView: UIView {
    private let avatarImageView = UIImageView()
    private let cameraIconView = UIImageView()
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    private func setupView() {
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 35
        avatarImageView.layer.cornerCurve = .continuous
        avatarImageView.layer.masksToBounds = true
        avatarImageView.backgroundColor = .systemGray5
        avatarImageView.image = UIImage(named: "Avatar")
        avatarImageView.isUserInteractionEnabled = true
        
        let cameraConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        cameraIconView.image = UIImage(systemName: "camera.fill", withConfiguration: cameraConfig)
        cameraIconView.tintColor = .white
        cameraIconView.backgroundColor = .black
        cameraIconView.contentMode = .center
        cameraIconView.layer.cornerRadius = 14
        cameraIconView.layer.cornerCurve = .continuous
        cameraIconView.layer.masksToBounds = true
        cameraIconView.layer.borderWidth = 4
        cameraIconView.layer.borderColor = UIColor.systemBackground.cgColor
        
        addSubview(avatarImageView)
        addSubview(cameraIconView)
        
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        cameraIconView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: topAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            avatarImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            avatarImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            cameraIconView.widthAnchor.constraint(equalToConstant: 28),
            cameraIconView.heightAnchor.constraint(equalToConstant: 28),
            cameraIconView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 6),
            cameraIconView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 6)
        ])
    }
}
// MARK: - Title Label

final class TitleLabel: UILabel {
    init() {
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    private func configure() {
        font = .headline3
        textColor = .black
    }
}

// MARK: - Text Field

final class EditProfileTextField: UITextField {
    init() {
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    private func configure() {
        font = .bodyRegular
        borderStyle = .roundedRect
        layer.cornerRadius = 12
        layer.masksToBounds = true
        backgroundColor = .lightGray
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: frame.height))
        leftView = paddingView
        leftViewMode = .always
    }
    
    func configure(placeholder: String) {
        self.placeholder = placeholder
    }
}

// MARK: - Text View

final class EditProfileTextView: UITextView {
    init() {
        super.init(frame: .zero, textContainer: nil)
        configure()
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    private func configure() {
        font = .bodyRegular
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor
        layer.cornerRadius = 12
        layer.masksToBounds = true
        backgroundColor = .lightGray
        textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
    }
}

// MARK: - Save Button

final class SaveButton: UIButton {
    init() {
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    private func configure() {
        setTitle(NSLocalizedString("EditProfile.save", comment: "Save"), for: .normal)
        titleLabel?.font = .bodyBold
        backgroundColor = .black
        setTitleColor(.white, for: .normal)
        layer.cornerRadius = 16
        layer.masksToBounds = true
        isHidden = true
    }
}
