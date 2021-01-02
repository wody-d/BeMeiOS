//
//  HomeVC.swift
//  BeMe
//
//  Created by Yunjae Kim on 2020/12/28.
//

import UIKit
import Then
import SnapKit
import UserNotifications

class HomeVC: UIViewController {
    //MARK:- IBOutlets
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var cardCollectionView: UICollectionView!
    
    
    let alertHorizontalSeperator = UIView().then{
        $0.backgroundColor = .gray
        
    }
    let alertVerticalSeperator = UIView().then {
        $0.backgroundColor = .gray
    }
    @IBOutlet weak var timeLabelTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var collectionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    var firstImage = UIImageView().then {
        $0.image = UIImage(named: "icEdit")
        
    }
    var firstLabel = UILabel().then {
        $0.text = "수정하기"
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 15)
    }
    
    var secondImage = UIImageView().then {
        $0.image = UIImage(named: "icDelete")
    }
    var secondLabel = UILabel().then {
        $0.text = "삭제하기"
        $0.textColor = .grapefruit
        $0.font = UIFont.systemFont(ofSize: 15)
    }
    var lineView = UIView().then {
        $0.backgroundColor = .slateGrey
    }
    var cancelButton = UIButton().then {
        $0.setTitle("", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16)
    }
    var cancelLabel = UILabel().then {
        $0.text = "취소"
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 16)
    }
    var alertContainView = UIView().then {
        $0.backgroundColor = .charcoalGrey
    }
    var blurView = UIView().then {
        $0.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
    }
    var changeButton = UIButton().then {
        $0.backgroundColor = .charcoalGrey
    }
    var removeButton = UIButton().then {
        $0.backgroundColor = .charcoalGrey
    }
    
    //MARK:- User Define Variables
    private var collectionViewWidth = 0
    private var cardWidth : CGFloat = 0.0
    private var pastCards = 0
    private var todayCards = 0
    var currentCardIdx = 0
    private var initialScrolled = false
    private var cardHeight = 0.0
    var nowPos = CGPoint(x: -1.0, y: 0)
    let deviceBound = UIScreen.main.bounds.height/812.0
    let deviceWidthBound = UIScreen.main.bounds.width/375.0
    var locks = [false,false,false,false,false,false,false,false,]
    let userNotificationCenter = UNUserNotificationCenter.current()
    private var flexible = false
    var answerDataList : [AnswerDataForViewController] = []
    
    let tmpPastData = AnswerDataForViewController(lock: true,
                                              questionInfo: "미래에 관한 3번째 질문",
                                              answerDate: "2020.12.24",
                                              question: "이번 주말을 후회 없이\n보낼 수 있는 방법은 무엇인가요?"
                                              , answer: "저는 몇일 전 퇴사를 했어요. 수많은 고민 끝에 결국 저질렀습니다. 몇 년간 원해 왔던 일이라 꿈만 같아요. 제가 스스로의 힘으로 하고 싶은 걸 해볼 수있는 시간적 여유를 가지게 된게 정말 만족스러워요.",
                                              index: 0
                                              )
    let tmpNowData = AnswerDataForViewController(lock: true,
                                                 questionInfo: "미래에 관한 3번째 질문",
                                                 answerDate: "2020.12.24",
                                                 question: "이번 주말을 후회 없이\n보낼 수 있는 방법은 무엇인가요?"
                                                 , answer: "",
                                                 index: 0)
}


//MARK:- LifeCycle Methods
extension HomeVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        pastCards = 3
        todayCards = 1
        cardCollectionView.delegate = self
        cardCollectionView.dataSource = self
        let customLayout = HomeCardCustomFlowLayout()
        cardCollectionView.collectionViewLayout = customLayout
        //        cardCollectionView.reloadData()
        timeLabelTopConstraint.constant = 103 * deviceBound
        collectionViewTopConstraint.constant = 150 * deviceBound
        if deviceBound < 1 {
            collectionViewHeightConstraint.constant = 450
            cardHeight = 450
            cardWidth = 315
        }
        else {
            collectionViewHeightConstraint.constant = 491*deviceBound
            cardHeight = Double(491*deviceBound)
            cardWidth = 315*deviceBound
        }
//        userNotificationCenter.delegate = self
        requestNotificationAuthorization()
        sendNotification()
        
        
        for _ in 0..<pastCards{
            answerDataList.append(tmpPastData)
        }
        for _ in 0..<todayCards{
            answerDataList.append(tmpNowData)
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if initialScrolled == false {
            cardCollectionView.scrollToItem(at: IndexPath(item: pastCards, section: 0),
                                            at: .centeredHorizontally,
                                            animated: false)
            initialScrolled = true
            currentCardIdx = pastCards + todayCards - 1
        }
        
        
    }
    
    
    
    
}
//MARK:- User Define functions
extension HomeVC {
    
    func changeLock(){
        locks[currentCardIdx] = !locks[currentCardIdx]
        answerDataList[currentCardIdx].lock!     = !answerDataList[currentCardIdx].lock!
        cardCollectionView.reloadData()
        
    }
    
    func makeAlertTitle() -> String {
        if locks[currentCardIdx] == false {
            return "공개 질문으로 전환하시겠어요?"
        }
        else{
            return "비공개 질문으로 전환하시겠어요?"
        }
        
    }
    
    func requestNotificationAuthorization() {
        let authOptions = UNAuthorizationOptions(arrayLiteral: .alert, .badge, .sound)

        userNotificationCenter.requestAuthorization(options: authOptions) { success, error in
            if let error = error {
                print("Error: \(error)")
            }
        }
    }

    func sendNotification() {
        let notificationContent = UNMutableNotificationContent()

        notificationContent.title = "오늘의 질문이 도착했어요"
        notificationContent.body = "질문을 보러가려면 눌러주세요"

        
        
       
        
        var date = DateComponents()
        date.hour = 22
        date.minute = 00
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        
        let request = UNNotificationRequest(identifier: "testNotification",
                                            content: notificationContent,
                                            trigger: trigger)

        userNotificationCenter.add(request) { error in
            if let error = error {
                print("Notification Error: ", error)
            }
        }
    }
    
    
}

extension HomeVC : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item >= pastCards && indexPath.item <= pastCards + todayCards - 1{
            
            guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: NewCardCVC.identifier,
                    for: indexPath) as? NewCardCVC else {return UICollectionViewCell()}
            cell.index = indexPath.item
            cell.changePublicDelegate = self
            cell.homeAnswerButtonDelegate = self
            cell.answerData = answerDataList[indexPath.item]
            cell.setItems()
            
            
            return cell
        }
        
        else if indexPath.item < pastCards {
            guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PastCardCVC.identifier,
                    for: indexPath) as? PastCardCVC else {return UICollectionViewCell()}
            cell.index = indexPath.item
            cell.changePublicDelegate = self
            cell.homeFixButtonDelegate = self
            cell.answerData = answerDataList[indexPath.item]
            
            cell.setItems()
            return cell
        }
        else{
            guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: AddCardCVC.identifier,
                    for: indexPath) as? AddCardCVC else {return UICollectionViewCell()}
            
            cell.addDelegate = self
            return cell
            
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return pastCards + todayCards + 1
    }
    
    
}




extension HomeVC : UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        collectionViewWidth = Int(collectionView.frame.width)
        return CGSize(width: cardWidth ,
                      height: collectionView.frame.height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right:20)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
        
    }
    
    
    
}

extension HomeVC : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let curPos = scrollView.contentOffset
        if Int(curPos.x) < (pastCards-1)*collectionViewWidth {
            timeLabel.text = "과거의 질문"
        }
        else{
            timeLabel.text = "오늘의 질문"
            
        }
        
        if flexible {
            if Int(curPos.x) > Int(cardWidth+10) + Int(cardWidth+20)*(currentCardIdx-1) - 200
                && Int(curPos.x) < Int(cardWidth+10) + Int(cardWidth+20)*(currentCardIdx-1) + 200{
                flexible = !flexible
            }
        }
        
        if initialScrolled == true && !flexible{

            if Int(curPos.x) < Int(cardWidth+10) + Int(cardWidth+20)*(currentCardIdx-1) - 200 {
                cardCollectionView.scrollToItem(at: IndexPath(item: currentCardIdx-1, section: 0),
                                                at: .centeredHorizontally,
                                                animated: true)
                currentCardIdx = currentCardIdx-1


            }
            else if Int(curPos.x) > Int(cardWidth+10) + Int(cardWidth+20)*(currentCardIdx-1) + 200{
                cardCollectionView.scrollToItem(at: IndexPath(item: currentCardIdx+1, section: 0),
                                                at: .centeredHorizontally,
                                                animated: true)
                currentCardIdx = currentCardIdx+1


            }

        }

        
    }

}

extension HomeVC : AddQuestionDelegate {
    func addQuestion() {
        
        for i in pastCards..<pastCards+todayCards{
            if answerDataList[i].answer == "" || answerDataList[i].answer == nil{
                showAlert(titleLabel: "새로운 질문을 받기 위해\n오늘의 질문을 먼저 대답해주세요",
                          leftButtonTitle: "취소",
                          rightButtonTitle: "확인",
                          topConstraint: 24)
                return
            }
        }
        answerDataList.append(tmpNowData)
        let customCard = CustomTodayCardView(frame: .zero)
        let customAddCard = CustomAddCardView(frame: .zero)

        self.view.addSubview(customCard)
        self.view.addSubview(customAddCard)
        customCard.snp.makeConstraints{
            $0.width.equalTo(cardWidth)
            $0.height.equalTo(cardHeight)
            $0.top.equalToSuperview().offset(150*deviceBound)
            $0.leading.equalToSuperview().offset(40)
            
        }
        customAddCard.snp.makeConstraints{
            $0.width.equalTo(cardWidth)
            $0.height.equalTo(cardHeight)
            $0.top.equalToSuperview().offset(150*deviceBound)
            $0.leading.equalToSuperview().offset(40)
            
        }
        UIView.transition(from: customAddCard,
                          to: customCard,
                          duration: 1.5,
                          options: .transitionCurlUp,
                          completion: { f in
                            customCard.removeFromSuperview()
                            self.todayCards = self.todayCards+1
                            self.cardCollectionView.reloadData()
                            self.cardCollectionView.scrollToItem(at: IndexPath(
                                                                    item: self.currentCardIdx,
                                                                    section: 0),
                                                            at: .centeredHorizontally,
                                                            animated: true)
                            
                          })
        
    }
    
}


extension HomeVC : ChangePublicDelegate{
    func changePublic() {
        
        showAlert(titleLabel: makeAlertTitle(),leftButtonTitle: "취소",
                  rightButtonTitle: "확인",topConstraint: 30)
        
        
    }
    
    
    func showAlert(titleLabel: String,leftButtonTitle: String,rightButtonTitle: String,topConstraint: Int){
        let blurView = UIView(frame: .zero).then{
            $0.backgroundColor = UIColor(cgColor: CGColor(red: 0, green: 0, blue: 0, alpha: 0.6))
            
        }
        
        let alertView = CustomAlertView(frame: .zero)
        
        self.view.addSubview(blurView)
        self.view.addSubview(alertView)
        
        alertView.setTitles(titleLabel: titleLabel,
                            leftButtonTitle: "취소",
                            rightButtonTitle: "확인")
        
        alertView.setTopConstraint(top: topConstraint)
        blurView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        
        alertView.snp.makeConstraints {
            $0.width.equalTo(270)
            if topConstraint < 30 {
                $0.height.equalTo(128)
            }
            else{
                $0.height.equalTo(122)
            }
            
            $0.centerX.centerY.equalToSuperview()
        }
        
        alertView.leftButtonClicked = { [weak self] in
            blurView.removeFromSuperview()
            alertView.removeFromSuperview()
            
        }
        alertView.rightButtonClicked = { [weak self] in
            if topConstraint == 30{
                self?.changeLock()
            }
            
            blurView.removeFromSuperview()
            alertView.removeFromSuperview()
        }
        
        
    }
    
    
}


extension HomeVC: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
}

extension HomeVC : HomeTabBarDelegate{
    func homeButtonTapped() {
        flexible = true

        self.cardCollectionView.scrollToItem(at: IndexPath(item: self.pastCards+self.todayCards-1, section: 0),
                                        at: .centeredHorizontally,
                                        animated: true)
        
        currentCardIdx = pastCards
        
        
    
        
    }
}


extension HomeVC : HomeFixButtonDelegate{
    func fixButtonTapped() {
        makeUnderAlertView()
    }
}

extension HomeVC : HomeAnswerButtonDelegate {
    func answerButtonTapped(question: String, questionInfo: String, answerDate: String,index: Int) {
        guard let answerVC = UIStoryboard(name: "Answer",
                                          bundle: nil).instantiateViewController(
                                              withIdentifier: "AnswerVC") as? AnswerVC
              else{
                  
                  return
          }
        answerVC.answerDataDelegate = self
        answerVC.curCardIdx = index
        self.navigationController?.pushViewController(answerVC, animated: true)
        answerVC.question = question
        answerVC.questionInfo = questionInfo
        answerVC.answerDate = answerDate

    }
}

extension HomeVC : HomeGetDataFromAnswerDelegate {
    func setNewAnswer(answerData: AnswerDataForViewController) {
        print("called")
        answerDataList[answerData.index!] = answerData
        print(answerDataList[answerData.index!])
        cardCollectionView.reloadData()
    }
    
    
}
