//
//  RecommendVC.swift
//  Peekabook
//
//  Created by devxsby on 2022/12/31.
//

import UIKit

import SnapKit
import Then

import Moya

final class RecommendVC: UIViewController {

    private var recommendTypes: [String] = [I18N.BookRecommend.recommended, I18N.BookRecommend.recommending]
    
    // MARK: - Properties
    
    private let recommendedVC = RecommendedVC()
    private let recommendingVC = RecommendingVC()
    private lazy var dataViewControllers: [UIViewController] = {
        return [recommendedVC, recommendingVC]
    }()

    private var currentPage: Int = 0 {
        didSet {
            bind(newValue: currentPage)
        }
    }
    
    // MARK: - UI Components
    
    private let headerView = UIView()
    private let logoImage = UIImageView().then {
        $0.image = ImageLiterals.Image.logo
    }
    private let headerUnderlineView = UIView()
    private let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumInteritemSpacing = 17
        $0.sectionInset = UIEdgeInsets(
            top: 16,
            left: 22,
            bottom: 17,
            right: 22
        )
    }
    private lazy var recommendCollectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: layout
    ).then {
        $0.showsHorizontalScrollIndicator = false
        $0.isScrollEnabled = false
        $0.allowsMultipleSelection = false
    }
    private lazy var pageViewController: UIPageViewController = {
        let vc = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        return vc
    }()
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setSubviews()
        setLayout()
        setDelegate()
        registerCells()
        setFirstIndexSelected()
    }
}

// MARK: - UI & Layout

extension RecommendVC {
    
    private func setUI() {
        headerUnderlineView.backgroundColor = .peekaRed
        self.view.backgroundColor = .peekaBeige
        recommendCollectionView.backgroundColor = .clear
    }
    
    private func setSubviews() {
        view.addSubviews(
            [headerView,
            recommendCollectionView,
            pageViewController.view]
        )
        headerView.addSubviews(
            [logoImage,
             headerUnderlineView]
        )
    }
    
    private func setLayout() {
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(52)
        }
        
        logoImage.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.width.equalTo(150)
            $0.height.equalTo(18)
        }
        
        headerUnderlineView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(2)
        }
        
        recommendCollectionView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(63)
        }
        
        pageViewController.view.snp.makeConstraints {
            $0.top.equalTo(recommendCollectionView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Methods

extension RecommendVC {
    
    private func registerCells() {
        recommendCollectionView.register(
            RecommendTypeCVC.self,
            forCellWithReuseIdentifier: RecommendTypeCVC.className
        )
    }
    
    private func setDelegate() {
        recommendCollectionView.delegate = self
        recommendCollectionView.dataSource = self
        
        pageViewController.delegate = self
        pageViewController.dataSource = self
    }
    
    private func didTapCell(at indexPath: IndexPath) {
        currentPage = indexPath.item
    }
    
    private func bind(newValue: Int) {
        recommendCollectionView.selectItem(
            at: IndexPath(
                item: currentPage,
                section: 0),
            animated: true,
            scrollPosition: .centeredHorizontally
        )
    }
    
    private func setFirstIndexSelected() {
        let selectedIndexPath = IndexPath(item: 0, section: 0)
        recommendCollectionView.selectItem(
            at: selectedIndexPath,
            animated: true,
            scrollPosition: .bottom
        )
        
        if let recommendedVC = dataViewControllers.first {
            pageViewController.setViewControllers(
                [recommendedVC],
                direction: .forward,
                animated: true,
                completion: nil
            )
        }
    }
}

extension RecommendVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendTypeCVC.className, for: indexPath) as? RecommendTypeCVC else { return UICollectionViewCell() }
        cell.dataBind(menuLabel: recommendTypes[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            pageViewController.setViewControllers(
                [recommendedVC],
                direction: .reverse,
                animated: true,
                completion: nil
            )
        } else {
            pageViewController.setViewControllers(
                [recommendingVC],
                direction: .forward,
                animated: true,
                completion: nil
            )
        }
    }
}

extension RecommendVC: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = dataViewControllers.firstIndex(of: viewController) else { return nil }
        let previousIndex = index - 1
        if previousIndex < 0 { return nil }
        return dataViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let currentVC = pageViewController.viewControllers?.first,
              let currentIndex = dataViewControllers.firstIndex(of: currentVC) else { return }
        currentPage = currentIndex
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = dataViewControllers.firstIndex(of: viewController) else { return nil }
        let nextIndex = index + 1
        if nextIndex == dataViewControllers.count { return nil }
        return dataViewControllers[nextIndex]
    }
}
