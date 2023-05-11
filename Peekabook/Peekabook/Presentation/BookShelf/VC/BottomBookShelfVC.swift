//
//  BottomBookShelfVC.swift
//  Peekabook
//
//  Created by devxsby on 2023/01/04.
//

import UIKit

import SnapKit

final class BottomBookShelfVC: UIViewController {
    
    // MARK: - Properties
    
    var bookShelfType: BookShelfType = .user
    private var serverMyBookShelfInfo: MyBookShelfResponse?
    private var books: [Book] = []
    private let fullView: CGFloat = 93.adjustedH
    private var partialView: CGFloat = UIScreen.main.bounds.height - 185.adjustedH

    // MARK: - UI Components
    
    private let headerContainerView = UIView()
    private let holdView = UIView()
    
    private let booksCountLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Books"
        lb.font = .engSb
        lb.textColor = .peekaRed
        return lb
    }()
    
    private lazy var addBookButton: UIButton = {
        let bt = UIButton(type: .system)
        bt.setImage(ImageLiterals.Icn.addBook, for: .normal)
        bt.addTarget(self, action: #selector(addBookButtonDidTap), for: .touchUpInside)
        return bt
    }()
    
    private lazy var bookShelfCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 45, right: 20)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isScrollEnabled = false
        cv.bounces = false
        cv.showsVerticalScrollIndicator = false
        cv.isUserInteractionEnabled = false
        return cv
    }()
    
    private let emptyDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .h2
        label.textColor = .peekaRed_60
        return label
    }()
    
    private let emptyDescriptionImage: UIImageView = {
        let iv = UIImageView()
        iv.isHidden = true
        iv.image = ImageLiterals.Icn.progressIndicator
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setLayout()
        setDelegate()
        registerCells()
        regeisterPanGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareBackgroundView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - @objc Function
    
    @objc
    private func addBookButtonDidTap() {
        let barcodeVC = BarcodeVC()
        barcodeVC.modalPresentationStyle = .fullScreen
        self.present(barcodeVC, animated: true, completion: nil)
    }
    
    @objc
    private func panGesture(_ recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: self.view)
        let velocity = recognizer.velocity(in: self.view)
        let y = self.view.frame.minY
        
        if (y + translation.y >= fullView) && (y + translation.y <= partialView) {
            self.view.frame = CGRect(x: 0, y: y + translation.y, width: view.frame.width, height: view.frame.height)
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }
        
        if recognizer.state == .ended {
            var duration = velocity.y < 0 ? Double((y - fullView) / -velocity.y) : Double((partialView - y) / velocity.y)
            
            duration = duration > 1.3 ? 1 : duration
            UIView.animateWithDamping(animation: {
//            UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
                if velocity.y >= 0 {
                    self.view.frame = CGRect(x: 0, y: self.partialView, width: self.view.frame.width, height: self.view.frame.height)
                } else {
                    self.view.frame = CGRect(x: 0, y: self.fullView, width: self.view.frame.width, height: self.view.frame.height)
                }
            }, completion: { [weak self] _ in
                if velocity.y < 0 {
                    self?.bookShelfCollectionView.isScrollEnabled = true
                    self?.bookShelfCollectionView.isUserInteractionEnabled = true
                }
            })
        }
    }
}

// MARK: - UI & Layout

extension BottomBookShelfVC {
    
    private func setUI() {
        view.backgroundColor = .peekaBeige
        holdView.backgroundColor = .peekaGray1
        holdView.layer.cornerRadius = 3
        headerContainerView.backgroundColor = .peekaLightBeige
        bookShelfCollectionView.backgroundColor = .peekaLightBeige
        roundViews()
    }
    
    private func setLayout() {
        
        view.addSubviews(headerContainerView, bookShelfCollectionView, emptyDescriptionLabel, emptyDescriptionImage)
        headerContainerView.addSubviews(holdView, booksCountLabel, addBookButton)
        
        headerContainerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(60)
        }
        
        holdView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(66)
            $0.height.equalTo(3)
        }
        
        booksCountLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
        
        addBookButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(4)
            $0.centerY.equalToSuperview()
        }
        
        bookShelfCollectionView.snp.makeConstraints {
            $0.top.equalTo(headerContainerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(70)
        }
        
        emptyDescriptionLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().multipliedBy(0.8)
        }
        
        emptyDescriptionImage.snp.makeConstraints {
            $0.bottom.equalTo(emptyDescriptionLabel.snp.top)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(48)
        }
        
        checkSmallLayout()
    }
}

// MARK: - Methods

extension BottomBookShelfVC {
    
    private func regeisterPanGesture() {
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(BottomBookShelfVC.panGesture))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
    }
    
    private func setDelegate() {
        bookShelfCollectionView.delegate = self
        bookShelfCollectionView.dataSource = self
    }
    
    private func registerCells() {
        bookShelfCollectionView.register(BookShelfCVC.self, forCellWithReuseIdentifier: BookShelfCVC.className)
    }
    
    private func animateView() {
//        if self.view.frame.minY <= fullView || self.view.frame.minY >= partialView { /// 안 닫히게
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                let frame = self?.view.frame
                let yComponent = self?.partialView
                self?.view.frame = CGRect(x: 0, y: yComponent!, width: frame!.width, height: frame!.height)
            })
//        }
    }
    
    private func roundViews() {
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
    }
    
    private func prepareBackgroundView() {
        let blurEffect = UIBlurEffect.init(style: .dark)
        let visualEffect = UIVisualEffectView.init(effect: blurEffect)
        let bluredView = UIVisualEffectView.init(effect: blurEffect)
        bluredView.contentView.addSubview(visualEffect)
        
        visualEffect.frame = UIScreen.main.bounds
        bluredView.frame = UIScreen.main.bounds
        
        view.insertSubview(bluredView, at: 0)
    }
    
    private func checkSmallLayout() {
        if UIScreen.main.isSmallThan712pt {
            partialView = UIScreen.main.bounds.height - 140.adjustedH
        }
    }
    
    func setData(books: [Book], bookTotalNum: Int) {
        self.books = books
        self.booksCountLabel.text = "\(String(bookTotalNum)) Books"
        bookShelfCollectionView.reloadData()
    }
    
    func changeLayout(isUser: Bool) {
        addBookButton.isHidden = isUser
        bookShelfType = .friend
    }
    
    func setEmptyLayout(_ isEnabled: Bool) {
        emptyDescriptionLabel.isHidden = !isEnabled
        
        if bookShelfType == .friend {
            emptyDescriptionImage.isHidden = !isEnabled
            emptyDescriptionLabel.text = I18N.BookShelf.emptyFriendBottomBookShelfDescription
        } else {
            emptyDescriptionImage.isHidden = true
            emptyDescriptionLabel.text = I18N.BookShelf.emptyMyBottomBookShelfDescription
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension BottomBookShelfVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookShelfCVC.className, for: indexPath)
                as? BookShelfCVC else { return UICollectionViewCell() }
        cell.setData(model: books[safe: indexPath.row]!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if Int(view.frame.minY) == Int(partialView) {
            bookShelfCollectionView.isUserInteractionEnabled = false
        } else {
            bookShelfCollectionView.isUserInteractionEnabled = true
            
            let bookDetailVC = BookDetailVC()
            if bookShelfType == .user {
                bookDetailVC.changeUserViewLayout()
            }
            bookDetailVC.hidesBottomBarWhenPushed = true
            bookDetailVC.selectedBookIndex = books[safe: indexPath.row]!.id
            navigationController?.pushViewController(bookDetailVC, animated: true)
        }
    }
}

// MARK: - UICollectionViewFlowLayout

extension BottomBookShelfVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let length = (collectionView.frame.width - 10) / 3
        return CGSize(width: length - 10, height: 170)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - UIGestureRecognizerDelegate

extension BottomBookShelfVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let gesture = (gestureRecognizer as? UIPanGestureRecognizer)
        let direction = gesture?.velocity(in: view).y ?? 0
        
        let y = view.frame.minY
        
        if (Int(y) == Int(fullView) && bookShelfCollectionView.contentOffset.y == 0 && direction > 0) || (Int(y) == Int(partialView)) {
            bookShelfCollectionView.isScrollEnabled = false
            bookShelfCollectionView.isUserInteractionEnabled = false
        } else {
            bookShelfCollectionView.isScrollEnabled = true
            bookShelfCollectionView.isUserInteractionEnabled = true
        }
        return false
    }
}
