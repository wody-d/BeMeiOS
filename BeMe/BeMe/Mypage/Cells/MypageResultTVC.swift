//
//  MypageResultTVC.swift
//  BeMe
//
//  Created by 박세란 on 2021/01/03.
//

import UIKit

class MypageResultTVC: UITableViewCell {
    
    //MARK:**- IBOutlet Part**
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var questionInfoLabel: UILabel!
    @IBOutlet weak var answerDateLabel: UILabel!
    @IBOutlet weak var lockButton: UIButton!
    
    //MARK:**- Variable Part**
    private var isLocked = false
    static let identifier = "MypageResultTVC"
    
    
    //MARK:**- Life Cycle Part**
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setCardView(question: "dbnd`", questionInfo: "아요 1번째 경험", answerDate: "202020202", isLocked: true)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    //MARK:**- IBAction Part**
    
    @IBAction func lockButtonTapped(_ sender: UIButton) {
        if isLocked {
            isLocked = false
            sender.setImage(UIImage.init(named: "btnLickBlack"), for: .normal)
            
        } else {
            isLocked = true
            sender.setImage(UIImage.init(named: "btnUnlockExplore"), for: .normal)
            
        }
    }
    
    //MARK:**- default Setting Function Part**
    
    func setCardView(question: String, questionInfo: String, answerDate: String, isLocked: Bool){
        
        // text init
        questionLabel.text = question
        questionInfoLabel.text = questionInfo
        answerDateLabel.text = answerDate
        
        // button image init
        if isLocked {
            lockButton.setImage(UIImage.init(named: "btnLickBlack"), for: .normal)
            
        } else {
            lockButton.setImage(UIImage.init(named: "btnUnlockExplore"), for: .normal)
            
        }
        
        
        // color
        questionLabel.textColor = .black
        questionInfoLabel.textColor = .slateGrey
        answerDateLabel.textColor = .rgb3A3A3C
        
        // 하이라이팅
        let attributedString = NSMutableAttributedString(string: questionInfoLabel.text!)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                      value: UIColor.rgb1C1C1E,
                                      range: (questionInfoLabel.text! as NSString).range(of: #"[0-9]*번째"#,
                                                                                         options: .regularExpression))
        // cardview init
        cardView.backgroundColor = .white
        cardView.setBorderWithRadius(borderColor: .rgbededed, borderWidth: 1, cornerRadius: 6)
        
    }
    
    //MARK:**- Function Part**
    
    
}
