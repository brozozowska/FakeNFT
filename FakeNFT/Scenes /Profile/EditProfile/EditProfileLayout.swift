import UIKit

enum EditProfileLayout {
    static func applyConstraints(
        for view: UIView,
        avatarImageView: UIImageView,
        nameTitleLabel: UILabel,
        nameTextField: UITextField,
        descriptionTitleLabel: UILabel,
        descriptionTextView: UITextView,
        websiteTitleLabel: UILabel,
        websiteTextField: UITextField,
        saveButton: UIButton
    ) {
        NSLayoutConstraint.activate([
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 60),
            
            avatarImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            avatarImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 73),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            
            nameTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTitleLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 24),
            
            nameTextField.topAnchor.constraint(equalTo: nameTitleLabel.bottomAnchor, constant: 8),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 44),
            nameTextField.widthAnchor.constraint(equalToConstant: 343),
            
            descriptionTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            descriptionTitleLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            
            descriptionTextView.topAnchor.constraint(equalTo: descriptionTitleLabel.bottomAnchor, constant: 8),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 132),
            descriptionTextView.widthAnchor.constraint(equalToConstant: 343),
            
            websiteTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            websiteTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            websiteTitleLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 24),
            
            websiteTextField.topAnchor.constraint(equalTo: websiteTitleLabel.bottomAnchor, constant: 8),
            websiteTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            websiteTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            websiteTextField.heightAnchor.constraint(equalToConstant: 44),
            websiteTextField.widthAnchor.constraint(equalToConstant: 343)
        ])
    }
}
