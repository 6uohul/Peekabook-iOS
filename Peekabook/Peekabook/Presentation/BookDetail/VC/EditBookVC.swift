//
//  EditBookVC.swift
//  Peekabook
//
//  Created by 고두영 on 2023/01/07.
//

import UIKit

import SnapKit
import Then

import Moya

final class EditBookVC: UIViewController {
    
    // MARK: - Properties
    var status: Int = 0
    private var focus = 0
    var bookIndex: Int = 0
    var descriptions: String = ""
    var memo: String = ""
    
    // MARK: - UI Components
    
    private let headerView = UIView()
    
    private lazy var backButton = UIButton().then {
        $0.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
    }
    
    private let headerTitleLabel = UILabel().then {
        $0.text = I18N.BookEdit.title
        $0.font = .h3
        $0.textColor = .peekaRed
    }
    
    private lazy var checkButton = UIButton().then {
        $0.setTitle(I18N.BookEdit.done, for: .normal)
        $0.titleLabel!.font = .h4
        $0.setTitleColor(.peekaRed, for: .normal)
        $0.addTarget(self, action: #selector(checkButtonDidTap), for: .touchUpInside)
    }
    
    private let containerView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    var bookImgView = UIImageView().then {
        $0.layer.masksToBounds = false
        $0.contentMode = .scaleAspectFit
        $0.layer.applyShadow(color: .black, alpha: 0.25, x: 0, y: 4, blur: 4, spread: 0)
    }
    
    var nameLabel = UILabel().then {
        $0.font = .h3
        $0.textColor = .peekaRed
    }
    
    var authorLabel = UILabel().then {
        $0.font = .h2
        $0.textColor = .peekaRed
    }
    
    private let peekaCommentView = CustomTextView()
    private let peekaMemoView = CustomTextView()

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setReusableView()
        setUI()
        setLayout()
        addTapGesture()
        addKeyboardObserver()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        peekaCommentView.textView.text = descriptions
        peekaMemoView.textView.text = memo
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UI & Layout
extension EditBookVC {
    
    private func setReusableView() {
        peekaCommentView.boxView.backgroundColor = .clear
        
        peekaMemoView.boxView.backgroundColor = .clear
        peekaMemoView.boxView.frame.size.height = 101
        peekaMemoView.label.text = I18N.BookDetail.memo
        peekaMemoView.textView.text = I18N.BookDetail.memoHint
        
        if descriptions != I18N.BookDetail.emptyComment {
            peekaCommentView.textView.textColor = .peekaRed
            peekaCommentView.maxLabel.text = "\(descriptions.count)/200"
        } else {
            peekaCommentView.maxLabel.text = I18N.BookAdd.commentLength
        }
        
        if memo != I18N.BookDetail.emptyMemo {
            peekaMemoView.textView.textColor = .peekaRed
            peekaMemoView.maxLabel.text = "\(memo.count)/50"
        } else {
            peekaMemoView.maxLabel.text = I18N.BookAdd.memoLength
        }
    }
    
    private func setUI() {
        self.view.backgroundColor = .peekaBeige
        headerView.backgroundColor = .clear
        containerView.backgroundColor = .clear
        backButton.setImage(ImageLiterals.Icn.back, for: .normal)
    }
    
    private func setLayout() {
        [containerView, headerView].forEach {
            view.addSubview($0)
        }
        
        [backButton, headerTitleLabel, checkButton].forEach {
            headerView.addSubview($0)
        }
        
        [bookImgView, nameLabel, authorLabel, peekaCommentView, peekaMemoView].forEach {
            containerView.addSubview($0)
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(52)
        }
        
        backButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        
        headerTitleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        checkButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(11)
            $0.width.height.equalTo(48)
        }
        
        bookImgView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.centerX.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(bookImgView.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
        
        authorLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
        }
        
        peekaCommentView.snp.makeConstraints {
            $0.top.equalTo(authorLabel.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(335)
            $0.height.equalTo(229)
        }
        
        peekaMemoView.snp.makeConstraints {
            $0.top.equalTo(peekaCommentView.snp.bottom).offset(40)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(335)
            $0.height.equalTo(101)
            $0.bottom.equalToSuperview().inset(36)
        }
    }
}

// MARK: - Methods

extension EditBookVC {
    
    @objc private func backButtonDidTap() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func checkButtonDidTap() {
        print("checkButtonDidTap")
        editMyBookInfo(id: bookIndex, param: EditBookRequest(description: peekaCommentView.textView.text, memo: peekaMemoView.textView.text))
        let vc = BookDetailVC()
        vc.getBookDetail(id: bookIndex)
    }
    
    private func config() {
        backButton.setImage(ImageLiterals.Icn.back, for: .normal)
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
            bottom: keyboardFrame.size.height,
            right: 0.0)
        containerView.contentInset = contentInset
        containerView.scrollIndicatorInsets = contentInset
        
        if peekaCommentView.textView.isFirstResponder {
            let textViewHeight = peekaCommentView.boxView.frame.height
            let position = CGPoint(x: 0, y: peekaCommentView.boxView.frame.origin.y - keyboardFrame.size.height + textViewHeight + 250)
            containerView.setContentOffset(position, animated: true)
            return
        }
        
        if peekaMemoView.textView.isFirstResponder {
            let textViewHeight = peekaMemoView.boxView.frame.height
            let position = CGPoint(x: 0, y: peekaMemoView.boxView.frame.origin.y - keyboardFrame.size.height + textViewHeight + 500)
            containerView.setContentOffset(position, animated: true)
            return
        }
        
    }
    
    @objc private func keyboardWillHide() {
        let contentInset = UIEdgeInsets.zero
        containerView.contentInset = contentInset
        containerView.scrollIndicatorInsets = contentInset
    }
}

extension EditBookVC {
    func editMyBookInfo(id: Int, param: EditBookRequest) {
        BookShelfAPI.shared.editMyBookInfo(id: id, param: param) { response in
            if response?.success == true {
                self.navigationController?.popViewController(animated: true)
            } else {
                print("책 수정 실패")
            }
        }
    }
}
