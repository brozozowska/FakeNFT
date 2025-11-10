import UIKit
import Kingfisher

// MARK: - Avatar Image View
final class AvatarImageView: UIImageView {
    var hasCustomImage: Bool {
        return image != UIImage(named: "changeAvatar")
    }
    
    init() {
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    private func configure() {
        contentMode = .scaleAspectFill
        layer.cornerRadius = 35
        layer.masksToBounds = true
        backgroundColor = .clear
        image = UIImage(named: "changeAvatar")
        isUserInteractionEnabled = true
    }
    
    func loadImage(from url: URL) {
        kf.setImage(with: url) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let value):
                    self?.image = value.image
                case .failure:
                    self?.setPlaceholder()
                }
            }
        }
    }
    
    func setPlaceholder() {
        image = UIImage(named: "changeAvatar")
    }
}

// MARK: - Title Label
final class TitleLabel: UILabel {
    init() {
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        fatalError("init(coder:) has not been implemented")
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
        fatalError("init(coder:) has not been implemented")
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
        fatalError("init(coder:) has not been implemented")
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
