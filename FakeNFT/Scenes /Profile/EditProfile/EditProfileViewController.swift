import UIKit

final class EditProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    private let profile: Profile
    private let onSave: (String, String, String, String) -> Void
    var hasUnsavedChanges = false
    
    private var originalName = ""
    private var originalDescription = ""
    private var originalWebsite = ""
    private var originalAvatar = ""
    var currentAvatar = ""
    
    // MARK: - UI Components
    
    let avatarImageView = AvatarImageView()
    private let nameTitleLabel = TitleLabel()
    let nameTextField = EditProfileTextField()
    private let descriptionTitleLabel = TitleLabel()
    let descriptionTextView = EditProfileTextView()
    private let websiteTitleLabel = TitleLabel()
    let websiteTextField = EditProfileTextField()
    let saveButton = SaveButton()
    
    // MARK: - Init
    
    init(profile: Profile, onSave: @escaping (String, String, String, String) -> Void) {
        self.profile = profile
        self.onSave = onSave
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupInitialData()
        setupKeyboardDismiss()
        setupAvatarTapGesture()
        setupSaveButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        view.backgroundColor = .white
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        [avatarImageView, nameTitleLabel, nameTextField, descriptionTitleLabel,
         descriptionTextView, websiteTitleLabel, websiteTextField, saveButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        setupTextFieldsDelegates()
    }
    
    private func setupTextFieldsDelegates() {
        nameTextField.delegate = self
        websiteTextField.delegate = self
        descriptionTextView.delegate = self
        
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        websiteTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func setupSaveButton() {
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        EditProfileLayout.applyConstraints(
            for: view,
            avatarImageView: avatarImageView,
            nameTitleLabel: nameTitleLabel,
            nameTextField: nameTextField,
            descriptionTitleLabel: descriptionTitleLabel,
            descriptionTextView: descriptionTextView,
            websiteTitleLabel: websiteTitleLabel,
            websiteTextField: websiteTextField,
            saveButton: saveButton
        )
    }
    
    private func setupInitialData() {
        if !profile.avatar.isEmpty {
            let fullURLString = profile.avatar.hasPrefix("http") ? profile.avatar : "\(RequestConstants.baseURL)\(profile.avatar)"
            if let avatarURL = URL(string: fullURLString) {
                avatarImageView.loadImage(from: avatarURL)
            }
        } else {
            avatarImageView.setPlaceholder()
        }
        
        nameTextField.text = profile.name
        descriptionTextView.text = profile.description ?? ""
        websiteTextField.text = profile.website
        
        originalName = profile.name
        originalDescription = profile.description ?? ""
        originalWebsite = profile.website
        originalAvatar = profile.avatar
        currentAvatar = profile.avatar
        
        nameTextField.configure(placeholder: NSLocalizedString("EditProfile.namePlaceholder", comment: "Name"))
        websiteTextField.configure(placeholder: NSLocalizedString("EditProfile.websitePlaceholder", comment: "Website"))
        
        nameTitleLabel.text = NSLocalizedString("EditProfile.name", comment: "Name")
        descriptionTitleLabel.text = NSLocalizedString("EditProfile.description", comment: "Description")
        websiteTitleLabel.text = NSLocalizedString("EditProfile.website", comment: "Website")
    }
    
    private func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupAvatarTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
        avatarImageView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func backButtonTapped() {
        if hasUnsavedChanges {
            showUnsavedChangesAlert()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func saveTapped() {
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty,
              let website = websiteTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !website.isEmpty else {
            showAlert(message: NSLocalizedString("EditProfile.fillAllFields", comment: "Please fill all fields"))
            return
        }
        
        let description = descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !ValidationHelper.isValidURL(website) {
            showAlert(message: NSLocalizedString("EditProfile.invalidURL", comment: "Please enter a valid URL"))
            return
        }
        
        let avatarToSave = currentAvatar.isEmpty ? originalAvatar : currentAvatar
        
        print("Saving profile changes:")
        print("Name: \(name)")
        print("Description: \(description)")
        print("Website: \(website)")
        print("Avatar: \(avatarToSave)")
        
        onSave(name, description, website, avatarToSave)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func avatarTapped() {
        showPhotoActionSheet()
    }
    
    @objc func textFieldDidChange() {
        checkForChanges()
    }
    
    // MARK: - Change Detection
    
    func checkForChanges() {
        let currentName = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let currentDescription = descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let currentWebsite = websiteTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        let nameChanged = currentName != originalName
        let descriptionChanged = currentDescription != originalDescription
        let websiteChanged = currentWebsite != originalWebsite
        let avatarChanged = avatarImageView.hasCustomImage && currentAvatar != originalAvatar
        
        hasUnsavedChanges = nameChanged || descriptionChanged || websiteChanged || avatarChanged
        saveButton.isHidden = !hasUnsavedChanges
        
        print("Changes detected - Name: \(nameChanged), Description: \(descriptionChanged), Website: \(websiteChanged), Avatar: \(avatarChanged)")
    }
}
