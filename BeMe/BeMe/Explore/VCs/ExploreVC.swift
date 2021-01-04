//
//  ExploreVC.swift
//  BeMe
//
//  Created by 이재용 on 2020/12/30.
//

import UIKit

class ExploreVC: UIViewController {
    
    //MARK: - IBOulets
    @IBOutlet weak var exploreScrollView: UIScrollView!
    @IBOutlet weak var highLightBar: UIView!
    @IBOutlet weak var headerHighLightBar: UIView!
    @IBOutlet weak var headerHighLightBarConstraint: NSLayoutConstraint!
    @IBOutlet weak var highLightBarLeading: NSLayoutConstraint!
    @IBOutlet weak var diffArticleSubTitle: UILabel!
    @IBOutlet weak var diffThoughtCollectionView: UICollectionView!
    @IBOutlet weak var diffArticleTableView: UITableView!
    @IBOutlet weak var diffArticleTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var headerViewTopContraint: NSLayoutConstraint!
    @IBOutlet weak var headerView: UIView! {
        didSet {
            headerView.alpha = 0.0
        }
    }
    @IBOutlet weak var headerViewHeight: NSLayoutConstraint! {
        didSet {
            
            headerViewHeight.constant = minHeight
        }
    }
    
    private var lastContentOffset: CGFloat = 0
    
    private let maxHeight: CGFloat = 32.0
    
    private let minHeight: CGFloat = 0.0
    
    private var cellNumber: Int = 10
    
    private var isRecentButtonPressed: Bool = true
    
    private var currentIndex: CGFloat = 0
    
    private var isOneStepPaging = true
    
    //MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adjustScrollViewInset()
        setThoughtCollectionView()
        diffArticleTableView.setDynamicCellHeight(to: 200)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.bringSubviewToFront(headerView)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setTableViewHeight()
        
    }
    
    
    //MARK: - IBActions
    
    @IBAction func recentButtonTapped(_ sender: UIButton) {
        moveHighLightBar(to: sender)
        isRecentButtonPressed = true
        setLabel()
        diffArticleTableView.reloadData()
    }
    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        moveHighLightBar(to: sender)
        isRecentButtonPressed = false
        setLabel()
        diffArticleTableView.reloadData()
    }
}

//MARK: - Private Method
extension ExploreVC {
    
    private func setThoughtCollectionView() {
        
        let cellWidth: CGFloat = view.bounds.width - 55.0
        let cellHeight: CGFloat = cellWidth * 229.0 / 320.0
//        floor(view.frame.height * cellRatio)
        
        // 상하, 좌우 inset value 설정
        let insetX: CGFloat = (view.bounds.width - cellWidth) / 2.0
        let lineSpacing: CGFloat = 12.0
        
        let layout = diffThoughtCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        layout.minimumLineSpacing = lineSpacing
        layout.scrollDirection = .horizontal
        diffThoughtCollectionView.contentInset = UIEdgeInsets(top: 0, left: insetX, bottom: 0, right: insetX)

        diffThoughtCollectionView.delegate = self
        diffThoughtCollectionView.dataSource = self
        
        diffThoughtCollectionView.decelerationRate = UIScrollView.DecelerationRate.fast
    }
    
    private func setLabel() {
        diffArticleSubTitle.alpha = 0.0
        UIView.animate(withDuration: 0.6, animations: {
            self.diffArticleSubTitle.alpha = 1.0
            self.diffArticleSubTitle.text = self.isRecentButtonPressed ? "내가 답한 질문에 대한 다른 사람들의 최신 답변이에요" : "내가 관심있어 할 다른 사람들의 답변이에요"
            
            
        }) { (_) in
            
        }
        
    }
    
    private func setLayout() {
        headerView.center.y -= view.bounds.height
        
    }
    
    private func setTableViewHeight() {
        diffArticleTableViewHeight.constant = diffArticleTableView.contentSize.height
    }
    
    private func moveHighLightBar(to button: UIButton) {
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveLinear], animations: {
            
            // Slide Animation
            self.highLightBar.frame.origin.x = 30 + button.frame.minX
            self.headerHighLightBar.frame.origin.x = 30 + button.frame.minX
            
            // FadeIn Animation
//                        self.highLightBarLeading.constant = 30 + button.frame.minX
//                        self.headerHighLightBarConstraint.constant = 30 + button.frame.minX
            
        }) { _ in
            
        }
    }
    
    private func adjustScrollViewInset() {
        if #available(iOS 11.0, *) {
            exploreScrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
    }
    
    private func hideTabBarWhenScrollingUp() {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveLinear], animations: {
            self.headerViewHeight.constant = self.minHeight
            //            self.headerView.center.y = -self.headerView.frame.height
            self.headerView.alpha = 0.0
        }) { _ in
            
        }
    }
    
    private func showTabBarWhenScrollingDown() {
        UIView.animate(withDuration: 0.3, delay: 0.3, options: [.curveLinear], animations: {
            self.headerViewHeight.constant = self.maxHeight
            //            self.headerView.center.y = self.headerView.frame.height
            self.headerView.alpha = 1.0
        }) { _ in
            
        }
    }
}

//MARK: - ScrollViewDelegate
extension ExploreVC: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        if scrollView == diffThoughtCollectionView {
            let layout = self.diffThoughtCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
            let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
            
            var offset = targetContentOffset.pointee
            let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
            var roundedIndex = round(index)
            
            if scrollView.contentOffset.x > targetContentOffset.pointee.x {
                roundedIndex = floor(index)
            } else if scrollView.contentOffset.x < targetContentOffset.pointee.x {
                roundedIndex = ceil(index)
            } else {
                roundedIndex = round(index)
            }
            
            if isOneStepPaging {
                if currentIndex > roundedIndex {
                    currentIndex -= 1
                    roundedIndex = currentIndex
                } else if currentIndex < roundedIndex {
                    currentIndex += 1
                    roundedIndex = currentIndex
                }
            }
            
            // 위 코드를 통해 페이징 될 좌표값을 targetContentOffset에 대입하면 된다.
            offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
            targetContentOffset.pointee = offset
        }
        
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = exploreScrollView.contentOffset.y
        
        // iphone safe area 문제 해결 코드
        self.view.backgroundColor = currentOffset > 388 ? .white : UIColor.init(named: "background")
        
        if (currentOffset > 432 + 69 + 32) {
            if (lastContentOffset < currentOffset) {
                // scroll up
                hideTabBarWhenScrollingUp()
            } else {
                // scroll down
                showTabBarWhenScrollingDown()
            }
        } else {
            hideTabBarWhenScrollingUp()
        }
        
        lastContentOffset = currentOffset
    }
    
}

//MARK: - CollectionViewDelegate
extension ExploreVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: DiffThoughtCVC.identifier,
                for: indexPath) as? DiffThoughtCVC else {
            return UICollectionViewCell()
        }
        // border 계산 다시하기
        cell.layer.cornerRadius = 10
        cell.setAnswer()
        cell.backgroundColor = .white
        return cell
    }
    
}

//MARK: - TableView

extension ExploreVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellNumber
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            guard let category = tableView
                    .dequeueReusableCell(withIdentifier: CategoryTVC.identifier, for: indexPath)
                    as? CategoryTVC else { return UITableViewCell() }
            category.delegate = self
            return category
        } else if indexPath.row == cellNumber - 1 {
            guard let more = tableView
                    .dequeueReusableCell(withIdentifier: MoreTVC.identifier, for: indexPath)
                    as? MoreTVC else { return UITableViewCell() }
            
            more.isUserInteractionEnabled = false
            
            return more
        } else {
            guard let article = tableView
                    .dequeueReusableCell(withIdentifier: ArticleTVC.identifier, for: indexPath)
                    as? ArticleTVC else { return UITableViewCell() }
            
            
            return article
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 62
        } else if indexPath.row == cellNumber - 1 {
            return UITableView.automaticDimension
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            // no animation
            
        } else if indexPath.row == cellNumber - 1 {
            // animation 2
            cell.alpha = 0
            UIView.animate(withDuration: 0.75) {
                
                cell.alpha = 1.0
            }
        } else {
            // animation 1
            let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, 0, 320, 0)
            cell.layer.transform = rotationTransform
            cell.alpha = 0.5
            
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
                cell.layer.transform = CATransform3DIdentity
                cell.alpha = 1.0
            }) { (_) in
                
            }
            
        }
        
    }
}

extension ExploreVC: CategoryButtonPressedDelegate {
    func categoryButtonTapped(_ indexPath: IndexPath) {
        
        // indexPath 서버에 보내줘서 비동기 처리 (로딩화면)
        diffArticleTableView.reloadData()
    }
}
