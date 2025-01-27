//
//  SignUpVC.swift
//  Peekabook
//
//  Created by 김인영 on 2023/03/29.
//

import UIKit

enum ProfileImageType: CaseIterable {
    case defaultImage
    case customImage
}

final class SignUpVC: UIViewController {
    
    // MARK: - Properties
    
    private var isSignUp: Bool = false
    private var isCameraMode: Bool = false
    
    var nicknameText: String = ""
    var introText: String = ""
    
    var isImageDefaultType: Bool = true {
        didSet {
            if isImageDefaultType {
                self.profileImageView.image = ImageLiterals.Icn.emptyProfileImage
                self.editImageButton.setImage(ImageLiterals.Icn.addProfileImage, for: .normal)
            } else {
                self.editImageButton.setImage(ImageLiterals.Icn.profileImageEdit, for: .normal)
            }
        }
    }
    
    var isDoubleChecked: Bool = false {
        didSet {
            if isDoubleChecked {
                doubleCheckButton.backgroundColor = .peekaGray1
                doubleCheckErrorLabel.isHidden = true
                doubleCheckSuccessLabel.isHidden = false
            } else {
                doubleCheckButton.backgroundColor = .peekaRed
                doubleCheckErrorLabel.isHidden = false
                doubleCheckSuccessLabel.isHidden = true
            }
        }
    }
    
    var isCheckComplete: Bool = false {
        didSet {
            if isCheckComplete {
                updateConfirmSuccess()
                
            } else {
                updateConfirmFailed()
            }
        }
    }
    
    // MARK: - UI Components
    
    private lazy var naviBar = CustomNavigationBar(self, type: .oneRightButton)
        .addMiddleLabel(title: I18N.Profile.addMyInfo)
        .addRightButtonAction {
            print("회원가입 도중 창 닫아버림~~~~~~~~~~‼️")
            self.dismiss(animated: true)
        }
    
    private let containerView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }
    
    private let profileImageContainerView = UIView()
    private let profileImageView = UIImageView().then {
        $0.image = ImageLiterals.Icn.emptyProfileImage
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 40
    }
    private lazy var editImageButton = UIButton(type: .system).then {
        $0.setImage(ImageLiterals.Icn.addProfileImage, for: .normal)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
        $0.addTarget(self, action: #selector(imagePickDidTap), for: .touchUpInside)
    }
    
    private let nicknameContainerView = UIView().then {
        $0.layer.borderWidth = 2
        $0.layer.borderColor = UIColor.peekaRed.cgColor
    }
    
    private let nicknameHeaderView = UIView()
    private let nicknameLabel = UILabel().then {
        $0.text = I18N.Profile.nickname
        $0.font = .h1
        $0.textColor = .peekaWhite
    }
    private let nicknameTextContainerView = UIView()
    private lazy var nicknameTextField = UITextField().then {
        $0.attributedPlaceholder = NSAttributedString(string: I18N.PlaceHolder.nickname,
                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.peekaGray1])
        $0.textColor = .peekaRed
        $0.addLeftPadding()
        $0.autocorrectionType = .no
        $0.returnKeyType = .done
        $0.font = .h2
        $0.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    private lazy var doubleCheckButton = UIButton(type: .system).then {
        $0.setTitle(I18N.Profile.doubleCheck, for: .normal)
        $0.backgroundColor = .peekaGray1
        $0.setTitleColor(.peekaWhite, for: .normal)
        $0.titleLabel?.font = .c1
        $0.isEnabled = false
        $0.addTarget(self, action: #selector(doubleCheckButtonDidTap), for: .touchUpInside)
    }
    private let doubleCheckErrorLabel = UILabel().then {
        $0.text = I18N.Profile.doubleCheckError
        $0.font = .s3
        $0.textColor = .peekaRed
        $0.isHidden = true
    }
    private let doubleCheckSuccessLabel = UILabel().then {
        $0.text = I18N.Profile.doubleCheckSuccess
        $0.font = .s3
        $0.textColor = .peekaRed
        $0.isHidden = true
    }
    private let countMaxTextLabel = UILabel().then {
        $0.text = "0" + I18N.Profile.nicknameLength
        $0.font = .h2
        $0.textColor = .peekaGray2
    }
    
    private let introContainerView = CustomTextView()
    
    private let checkContainerView = UIView()
    
    private lazy var signUpButton = UIButton(type: .system).then {
        $0.setTitle(I18N.DeleteAccount.confirm, for: .normal)
        $0.titleLabel!.font = .nameBold
        $0.setTitleColor(.peekaGray2, for: .normal)
        $0.backgroundColor = .peekaGray3
        $0.layer.borderColor = UIColor.peekaGray2_60.cgColor
        $0.layer.borderWidth = 2
        $0.addTarget(self, action: #selector(checkButtonDidTap), for: .touchUpInside)
    }
    
    private let doubleCheckNotTappedLabel = UILabel().then {
        $0.text = I18N.Profile.doubleUncheckedError
        $0.font = .s3
        $0.textColor = .peekaRed
        $0.isHidden = true
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundColor()
        setLayout()
        setIntroView()
        setImageTapGesture()
        addTapGesture()
        addKeyboardObserver()
        setDelegate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkIsDefaultImage()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("🌟 회원가입 뷰 viewDidDisappear")
        if !isSignUp && !isCameraMode {
            UserManager.shared.logout()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UI & Layout

extension SignUpVC {
    
    private func setIntroView() {
        introContainerView.delegate = self
        introContainerView.updateTextView(type: .addProfileIntro)
        introContainerView.setTextColor(.peekaGray1)
    }
    
    private func setBackgroundColor() {
        view.backgroundColor = .peekaBeige
        nicknameHeaderView.backgroundColor = .peekaRed
        nicknameContainerView.backgroundColor = .peekaWhite
        checkContainerView.backgroundColor = .peekaBeige
    }
    
    private func updateConfirmSuccess() {
        signUpButton.backgroundColor = .peekaRed
        signUpButton.setTitleColor(.peekaWhite, for: .normal)
        signUpButton.layer.borderColor = UIColor.peekaRed.cgColor
        signUpButton.isEnabled = true
    }
    
    private func updateConfirmFailed() {
        signUpButton.setTitleColor(.peekaGray2, for: .normal)
        signUpButton.backgroundColor = .peekaGray3
        signUpButton.layer.borderColor = UIColor.peekaGray2_60.cgColor
        signUpButton.layer.borderWidth = 2
        signUpButton.isEnabled = false
    }
    
    private func setLayout() {
        view.addSubviews(containerView, checkContainerView, naviBar)
        containerView.addSubviews(profileImageContainerView, nicknameContainerView, doubleCheckErrorLabel, doubleCheckSuccessLabel, countMaxTextLabel, introContainerView)
        profileImageContainerView.addSubviews(profileImageView, editImageButton)
        nicknameContainerView.addSubviews(nicknameHeaderView, nicknameTextContainerView)
        nicknameHeaderView.addSubviews(nicknameLabel)
        nicknameTextContainerView.addSubviews(nicknameTextField, doubleCheckButton)
        checkContainerView.addSubviews(signUpButton, doubleCheckNotTappedLabel)
    
        naviBar.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalTo(naviBar.snp.bottom)
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        profileImageContainerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(23)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(82)
        }
        
        profileImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.height.width.equalTo(80)
        }
        
        editImageButton.snp.makeConstraints {
            $0.trailing.bottom.equalToSuperview()
            $0.height.width.equalTo(24)
        }
        
        nicknameContainerView.snp.makeConstraints {
            $0.top.equalTo(profileImageContainerView.snp.bottom).offset(54)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(79)
        }
        
        nicknameHeaderView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(36)
        }
        
        nicknameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(14)
            $0.centerY.equalToSuperview()
        }
        
        nicknameTextContainerView.snp.makeConstraints {
            $0.top.equalTo(nicknameHeaderView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        nicknameTextField.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
//            $0.top.equalTo(nicknameContainerView.snp.top)
            $0.width.equalTo(244)
        }
        
        doubleCheckButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(7)
            $0.trailing.equalToSuperview().inset(14)
            $0.height.equalTo(26)
            $0.width.equalTo(53)
        }
        
        doubleCheckErrorLabel.snp.makeConstraints {
            $0.top.equalTo(nicknameContainerView.snp.bottom).offset(10)
            $0.leading.equalTo(nicknameContainerView)
        }
        
        doubleCheckSuccessLabel.snp.makeConstraints {
            $0.top.equalTo(nicknameContainerView.snp.bottom).offset(10)
            $0.leading.equalTo(nicknameContainerView)
        }
        
        countMaxTextLabel.snp.makeConstraints {
            $0.top.equalTo(nicknameContainerView.snp.bottom).offset(8)
            $0.trailing.equalTo(nicknameContainerView)
        }
        
        introContainerView.snp.makeConstraints {
            $0.top.equalTo(countMaxTextLabel.snp.bottom).offset(21)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(101)
            $0.bottom.equalToSuperview().inset(11)
        }
        
        checkContainerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(115)
        }
        
        signUpButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(23)
            $0.height.equalTo(56)
        }
        
        doubleCheckNotTappedLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.centerX.equalToSuperview()
        }
    }
}

// MARK: - Methods

extension SignUpVC {
    
    private func setDelegate() {
        nicknameTextField.delegate = self
    }
    
    private func checkIsDefaultImage() {
        if profileImageView.image == ImageLiterals.Icn.emptyProfileImage {
            self.isImageDefaultType = true
        } else {
            self.isImageDefaultType = false
        }
    }
    
    @objc
    private func textFieldDidChange(_ textField: UITextField) {
        guard let nicknameText = textField.text else { return }
        // 항상 값을 최신화
        self.nicknameText = nicknameText
        if nicknameText.isEmpty {
            isDoubleChecked = true
            doubleCheckButton.backgroundColor = .peekaGray1
        } else {
            isDoubleChecked = false
            doubleCheckButton.isEnabled = true
        }
        
        if nicknameText.count > 6 {
            textField.deleteBackward()
        } else {
            countMaxTextLabel.text = "\(nicknameText.count)\(I18N.Profile.nicknameLength)"
        }
    
        doubleCheckErrorLabel.isHidden = true
        doubleCheckSuccessLabel.isHidden = true
        doubleCheckNotTappedLabel.isHidden = true
        
        checkComplete()
    }
    
    @objc
    private func doubleCheckButtonDidTap() {
        let checkDuplicated = CheckDuplicateRequest(nickname: nicknameText)
        checkDuplicateComplete(param: checkDuplicated)
        
        if nicknameText.isEmpty {
            doubleCheckButton.isEnabled = false
            isDoubleChecked = false
            doubleCheckButton.backgroundColor = .peekaGray1
        }
        checkComplete()
    }
    
    @objc
    private func checkButtonDidTap() {
        guard let profileImage = profileImageView.image else { return }
        
        if !isDoubleChecked {
            doubleCheckNotTappedLabel.isHidden = false
        } else {
            doubleCheckNotTappedLabel.isHidden = true
            isSignUp = true
            signUp(param: SignUpRequest(nickname: nicknameTextField.text ?? "", intro: introText), image: profileImage)
            view.endEditing(true)
        }
    }
    
    private func checkComplete() {
        if !self.nicknameText.isEmpty && !self.introText.isEmpty {
            isCheckComplete = true
        } else {
            isCheckComplete = false
        }
    }
    
    private func setImageTapGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imagePickDidTap))
        profileImageContainerView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc
    private func imagePickDidTap() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "카메라", style: .default, handler: { (action) in
            self.openCamera()
            self.isCameraMode = true
        }))
        alert.addAction(UIAlertAction(title: "앨범", style: .default, handler: { (action) in
            self.openPhotoLibrary()
        }))
        if !isImageDefaultType {
            alert.addAction(UIAlertAction(title: "기본이미지로 변경", style: .default, handler: { (action) in
                self.isImageDefaultType = true
            }))
        }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func openCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func openPhotoLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func addKeyboardObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        let contentInset = UIEdgeInsets(
            top: 0.0,
            left: 0.0,
            bottom: keyboardFrame.size.height + checkContainerView.frame.height,
            right: 0.0)
        
        containerView.contentInset = contentInset
        containerView.scrollIndicatorInsets = contentInset
        
        if nicknameTextField.isFirstResponder || introContainerView.isTextViewFirstResponder() {
            var position = introContainerView.getPositionForKeyboard(keyboardFrame: keyboardFrame)
            position.y += checkContainerView.frame.height // maxLength 레이아웃 28
            
            containerView.setContentOffset(position, animated: true)
            self.checkContainerView.transform = CGAffineTransform(translationX: 0, y: -keyboardFrame.size.height)
            
        }
    }
    
    @objc private func keyboardWillHide() {
        let contentInset = UIEdgeInsets.zero
        containerView.contentInset = contentInset
        containerView.scrollIndicatorInsets = contentInset
        UIView.animate(withDuration: 0.2, animations: {
            self.checkContainerView.transform = .identity
        })
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension SignUpVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            let compressedImage = compressImage(image: image, compressionQuality: 0.5) // 중간정도로 이미지 압축함
            self.profileImageView.image = fixOrientation(img: compressedImage)
            self.isImageDefaultType = false
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func compressImage(image: UIImage, compressionQuality: CGFloat) -> UIImage {
        guard let compressedImageData = image.jpegData(compressionQuality: compressionQuality) else { return image }
        guard let compressedUIImage = UIImage(data: compressedImageData) else { return image }
        return compressedUIImage
    }
    
    // 세로 이미지 회전 문제로 인한 함수
    private func fixOrientation(img: UIImage) -> UIImage {
        if img.imageOrientation == .up {
            return img
        }
        
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)
        
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return normalizedImage
    }
}

// MARK: - UITextFieldDelegate

extension SignUpVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let utf8Char = string.cString(using: .utf8)
        let isBackSpace = strcmp(utf8Char, "\\b")
        if string.checkNickname() || isBackSpace == -92 {
            return true
        }
        return false
    }
}

// MARK: - IntroTextDelegate

extension SignUpVC: IntroTextDelegate {
    func getTextView(text: String) {
        self.introText = text
        checkComplete()
    }
}

// MARK: - Network

extension SignUpVC {
    func signUp(param: SignUpRequest, image: UIImage?) {
        var finalImage: UIImage? = image
        if isImageDefaultType {
            finalImage = nil
        }
        UserAPI(viewController: self).signUp(param: param, image: finalImage) { response in
            if response?.success == true {
                self.switchRootViewController(rootViewController: TabBarController(), animated: true, completion: nil)
            }
        }
    }
    
    func checkDuplicateComplete(param: CheckDuplicateRequest) {
        UserAPI(viewController: self).checkDuplicate(param: param) { response in
            if response?.success == true {
                if let isDuplicated = response?.data?.check {
                    self.isDoubleChecked = (isDuplicated == 0) ? true : false
                }
            }
        }
    }
}
