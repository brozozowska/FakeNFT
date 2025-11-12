import UIKit

// MARK: - Validation Helper

enum ValidationHelper {
    static func isValidURL(_ string: String) -> Bool {
        if let url = URL(string: string), url.scheme != nil {
            return true
        }
        
        if let url = URL(string: "https://" + string), url.host != nil {
            return true
        }
        
        return false
    }
}

// MARK: - Alert Helper

extension EditProfileViewController {
    func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showUnsavedChangesAlert() {
        let alert = UIAlertController(
            title: "Уверены,\nчто хотите выйти?",
            message: nil,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
            title: "Остаться",
            style: .default
        ))
        
        alert.addAction(UIAlertAction(
            title: "Выйти",
            style: .default
        ) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        
        alert.view.tintColor = .systemBlue
        present(alert, animated: true)
    }
}

// MARK: - Photo Picker Helper

extension EditProfileViewController {
    func showPhotoActionSheet() {
        let actionSheet = UIAlertController(
            title: NSLocalizedString("EditProfile.photoProfile", comment: "Profile photo"),
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let changeAction = UIAlertAction(
            title: NSLocalizedString("EditProfile.changePhoto", comment: "Change photo"),
            style: .default
        ) { [weak self] _ in
            self?.showPhotoURLAlert()
        }
        
        let deleteAction = UIAlertAction(
            title: NSLocalizedString("EditProfile.deletePhoto", comment: "Delete photo"),
            style: .destructive
        ) { [weak self] _ in
            self?.avatarImageView.setPlaceholder()
            self?.currentAvatar = ""
            self?.checkForChanges()
        }
        
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("EditProfile.cancel", comment: "Cancel"),
            style: .cancel
        )
        
        actionSheet.addAction(changeAction)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true)
    }
    
    func showPhotoURLAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString("Ссылка на фото", comment: "Photo URL"),
            message: nil,
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = NSLocalizedString("Введите ссылку на фото", comment: "Enter photo URL")
            textField.keyboardType = .URL
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
        }
        
        let saveAction = UIAlertAction(
            title: NSLocalizedString("Сохранить", comment: "Save"),
            style: .default
        ) { [weak self] _ in
            guard let textField = alert.textFields?.first,
                  let urlString = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !urlString.isEmpty else {
                return
            }
            
            self?.loadImageFromURL(urlString)
        }
        
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("Отмена", comment: "Cancel"),
            style: .cancel
        )
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    func loadImageFromURL(_ urlString: String) {
        var fullURLString = urlString
        
        if !fullURLString.hasPrefix("http://") && !fullURLString.hasPrefix("https://") {
            fullURLString = "https://" + fullURLString
        }
        
        guard let url = URL(string: fullURLString) else {
            showAlert(message: NSLocalizedString("Некорректная ссылка", comment: "Invalid URL"))
            return
        }
        
        guard let _ = URLComponents(string: fullURLString) else {
            showAlert(message: NSLocalizedString("Некорректная ссылка", comment: "Invalid URL"))
            return
        }
        
        print("Loading avatar from URL: \(fullURLString)")
        
        currentAvatar = fullURLString
        
        avatarImageView.loadImage(from: url)
        checkForChanges()
    }
}
