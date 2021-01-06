//
//  CommentTestVC.swift
//  BeMe
//
//  Created by 이재용 on 2021/01/06.
//

import UIKit

//MARK: - Comment 모델

struct CommentA {
    let comment: String
    let children: [CommentA]?
    var open: Bool
}
class CommentVC: UIViewController {
    
    @IBOutlet weak var commentTableView: UITableView!
    @IBOutlet weak var scrapButton: UIButton!
    
    @IBOutlet weak var commentTextWrapper: UIView!
    @IBOutlet weak var commentBorderView: UIView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var lockButton: UIView!
    @IBOutlet weak var commentSendButton: UIButton!
    @IBOutlet weak var commentTextWrapperBottomAnchor: NSLayoutConstraint!
    lazy var popupBackgroundView: UIView = UIView()
    
    var pageNumber: Int?
    
    var isMoreButtonHidden: Bool?
    
    var isMyAnswer: Bool = false
    
    var isScrapped: Bool = false {
        didSet {
            
        }
    }
    
    private var commentArray: [CommentA] = [
        CommentA(comment: "안녕!", children: [CommentA(comment: "오! 안녕!", children: [], open: false),
                                                CommentA(comment: "오! 안녕!", children: [], open: false),
                                                CommentA(comment: "오! 안녕!", children: [], open: false)], open: false),
        CommentA(comment: "안녕!", children: [], open: false),
        CommentA(comment: "안녕!", children: [CommentA(comment: "오! 안녕!", children: [], open: false),
                                                CommentA(comment: "오! 안녕!", children: [], open: false)], open: false),
        CommentA(comment: "안녕!", children: [CommentA(comment: "오! 안녕!", children: [], open: false),
                                                CommentA(comment: "오! 안녕!", children: [], open: false),
                                                CommentA(comment: "오! 안녕!", children: [], open: false)], open: false),
    ]
    
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPopupView()
        setCommentTableView()
        setNotificationCenter()
        setCommentView()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func scrapButtonTapped(_ sender: UIButton) {
        
        if isScrapped {
            isScrapped = false
            scrapButton.setImage(UIImage(named: "btnScrapUnselected"), for: .normal)
        } else {
            isScrapped = true
            scrapButton.setImage(UIImage(named: "btnScrapSelected"), for: .normal)
        }
    }
    
    @IBAction func moreSettngButtonTapped(_ sender: Any) {
        popupBackgroundView.animatePopupBackground(true)
        guard let settingActionSheet = UIStoryboard.init(name: "CustomActionSheet", bundle: .main).instantiateViewController(withIdentifier: CustomActionSheet.identifier) as?
                CustomActionSheet else { return }
        
        settingActionSheet.modalPresentationStyle = .overCurrentContext
        self.present(settingActionSheet, animated: true, completion: nil)
    }
    
    @IBAction func commentSendButtonTapped(_ sender: UIButton) {
        
        // 서버 통신
        if let comment = commentTextView.text {
            commentArray.append(CommentA(comment: comment, children: [], open: false))
        }
        commentTableView.reloadData()
        commentTableView.scrollToRow(at: IndexPath.init(row: 0, section: commentArray.endIndex), at: .bottom, animated: true)
    }
    
}

//MARK: - Private Method
extension CommentVC {
    
    private func setCommentView() {
        commentBorderView.setBorderWithRadius(borderColor: UIColor.Border.textView, borderWidth: 1.0, cornerRadius: 6.0)
    }
    private func setCommentTableView() {
        commentTableView.delegate = self
        commentTableView.dataSource = self
        commentTableView.estimatedRowHeight = 30
        commentTableView.rowHeight = UITableView.automaticDimension
        commentTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 166, right: 0)
        commentTableView.keyboardDismissMode = .onDrag
    }
    
    private func setPopupView() {
        popupBackgroundView.setPopupBackgroundView(to: view)
    }
    
    private func setNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(closePopup), name: .init("closePopupNoti"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func closePopup() {
        popupBackgroundView.animatePopupBackground(false)
    }
    
    
    @objc func keyboardWillShow(_ sender: Notification) {
        handleKeyboardIssue(sender, isAppearing: true)
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        handleKeyboardIssue(sender, isAppearing: false)
    }
    
    private func handleKeyboardIssue(_ notification: Notification, isAppearing: Bool) {
        guard let userInfo = notification.userInfo as? [String: Any] else { return }
        guard let keyboardAnimationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        guard let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else { return }
        
        // 기기별 bottom safearea 계산하기
        let heightConstant = isAppearing ? keyboardHeight - 34 : 0
        
        UIView.animate(withDuration: keyboardAnimationDuration, animations: {
            self.commentTextWrapperBottomAnchor.constant = heightConstant
            self.view.layoutIfNeeded()
        }) { (_) in
        }
        
        if isAppearing {
            let inset = UIEdgeInsets(top: 0, left: 0, bottom: 61 + keyboardHeight, right: 0)
            commentTableView.contentInset = inset
            commentTableView.setContentInsetAndScrollIndicatorInsets(inset)
        } else {
            let inset = UIEdgeInsets(top: 0, left: 0, bottom: 166, right: 0)
            commentTableView.contentInset = inset
            commentTableView.setContentInsetAndScrollIndicatorInsets(inset)
        }
        
        print(commentTextWrapperBottomAnchor.constant)
    }
}

//MARK: - UITableViewDelegate

extension CommentVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return commentArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1 // header
        } else {
            if commentArray[section-1].open {
                return commentArray[section-1].children!.count + 1
            } else {
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            guard let header = tableView.dequeueReusableCell(withIdentifier: QuestionAnswerTVC.identifier, for: indexPath) as? QuestionAnswerTVC else { return UITableViewCell() }
            
            header.delegate = self
            header.indexPath = indexPath
            if let iMBH = isMoreButtonHidden {
                header.moreAnswerButton.isHidden = iMBH
            }
            header.profileView.isHidden = isMyAnswer
            return header
        } else {
            if indexPath.row == 0 {
                guard let comment = tableView.dequeueReusableCell(withIdentifier: CommentTVC.identifier, for: indexPath) as? CommentTVC else { return UITableViewCell() }
                
                comment.delegate = self
                comment.indexPath = indexPath
                if commentArray[indexPath.section-1].children!.count == 0 {
                    // 댓글 한개일 경우 "답글 보기" 없애는 로직 ******************고치기***********************
                    comment.moreCommentView.isHidden = true
                } else {
                    comment.moreCommentView.isHidden = false
                    if commentArray[indexPath.section-1].open {
                        comment.moreCommentLabel.text = "답글 접기"
                        comment.moreImageView.image = UIImage(named: "icArrowUp")
                        
                    } else {
                        comment.moreCommentLabel.text = "답글 보기"
                        comment.moreImageView.image = UIImage(named: "icArrowDown")
                    }
                }
                
                return comment
            } else {
                guard let secondComment = tableView.dequeueReusableCell(withIdentifier: SecondCommentTVC.identifier, for: indexPath) as? SecondCommentTVC else { return UITableViewCell() }
                
                return secondComment
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
        
    }
    
    
}

extension CommentVC: UITableViewButtonSelectedDelegate {
    
    func moreCellButtonDidTapped(to indexPath: IndexPath) {
        guard let cell = commentTableView.cellForRow(at: indexPath) as? CommentTVC else { return }
        guard let index = commentTableView.indexPath(for: cell) else { return }
        
        if indexPath.section == 0 {
            return
        } else {
            if indexPath.row == index.row {
                if indexPath.row == 0 {
                    if commentArray[index.section-1].open {
                        commentArray[index.section-1].open = false
                    } else {
                        commentArray[index.section-1].open = true
                    }
                    let section = IndexSet.init(integer: indexPath.section)
                    commentTableView.reloadSections(section, with: .none)
                }
            }
        }
    }
    
    func moreAnswerButtonDidTapped(to indexPath: IndexPath) {
        
        guard let detailVC = UIStoryboard.init(name: "Explore", bundle: nil).instantiateViewController(identifier: "ExploreDetailVC") as? ExploreDetailVC else { return }
        self.dismiss(animated: true, completion: {
            guard let nowVC = self.presentingViewController else { return }
            
            print("nowVC")
            print(nowVC)
            nowVC.navigationController?.pushViewController(detailVC, animated: true)
        })
    }
}

//MARK: - TextField

extension CommentVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView == commentTextView {
            commentSendButton.isHidden = textView.text.isEmpty
        }
    }
    
}

extension UIScrollView {
    
    func setContentInsetAndScrollIndicatorInsets(_ edgeInsets: UIEdgeInsets) {
           self.contentInset = edgeInsets
           self.scrollIndicatorInsets = edgeInsets
    }
}
