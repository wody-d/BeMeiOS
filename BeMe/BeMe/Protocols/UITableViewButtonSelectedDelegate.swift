//
//  UITableViewButtonSelectedDelegate.swift
//  BeMe
//
//  Created by 이재용 on 2021/01/06.
//

import Foundation

protocol UITableViewButtonSelectedDelegate: class {
    
    // 탐색 디테일 페이지의 설정 버튼 눌릴때
    func settingButtonDidTapped(to indexPath: IndexPath)
    
    // 댓글 페이지의 댓글 보기 버튼 눌릴 때
    func moreCellButtonDidTapped(to indexPath: IndexPath)
    
    // ?
    func moreAnswerButtonDidTapped(to indexPath: IndexPath)
    
    // 댓글 페이지의 답글 달기 버튼 눌릴 때
    func sendCommentButtonDidTapped(to indexPath: IndexPath)
}

extension UITableViewButtonSelectedDelegate {
    func settingButtonDidTapped(to indexPath: IndexPath) {}
    
    func moreCellButtonDidTapped(to: IndexPath) {}
    
    func moreAnswerButtonDidTapped(to indexPath: IndexPath) {}
    
    func sendCommentButtonDidTapped(to indexPath: IndexPath) {}
}
