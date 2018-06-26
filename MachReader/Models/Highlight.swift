//
//  Highlight.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/05/26.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import UIKit
import Pring
import Firebase

@objcMembers
final class Highlight: Object {
    dynamic var text: String?
    dynamic var page: String?
    dynamic var originX: Double = 0
    dynamic var originY: Double = 0
    dynamic var width: Double = 0
    dynamic var height: Double = 0
    dynamic var userID: String?
    dynamic var isPublic: Bool = true
    dynamic var comments: NestedCollection<Comment> = []
    
    static func new(text: String, page: Int, bounds: CGRect) -> Highlight {
        let id = SHA1.hexString(from: "\(text)\(page)")!
        let highlight = Highlight(id: id)
        highlight.text = text
        highlight.page = String(page)
        highlight.originX = Double(bounds.origin.x)
        highlight.originY = Double(bounds.origin.y)
        highlight.width = Double(bounds.width)
        highlight.height = Double(bounds.height)
        highlight.userID = User.default?.id
        highlight.isPublic = !UserDefaultsUtil.isPrivateActivity
        
        return highlight
    }
    
    static func filter(_ dataSource: DataSource<Highlight>?, withBounds bounds: CGRect) -> Highlight? {
        guard let data = dataSource else { return nil }

        let sameHighlight = data.filter {
            $0.bounds.origin.x == bounds.origin.x &&
            $0.bounds.origin.y == bounds.origin.y &&
            $0.bounds.width == bounds.width &&
            $0.bounds.height == bounds.height
        }.first
        if sameHighlight != nil {
            return sameHighlight
        }
        
        return data.filter {
            $0.bounds.origin.x <= bounds.origin.x &&
            $0.bounds.origin.x + $0.bounds.width >= bounds.origin.x &&
            $0.bounds.origin.y <= bounds.origin.y &&
            $0.bounds.origin.y + $0.bounds.height >= bounds.origin.y &&
            $0.bounds.width >= bounds.width &&
            $0.bounds.height >= bounds.height
        }.first
    }
    
    var bounds: CGRect {
        let b = CGRect(x: CGFloat(originX), y: CGFloat(originY), width: CGFloat(width), height: CGFloat(height))
        return b
    }
    
    var isMine: Bool {
        if let uid = userID, let userID = User.default?.id {
            return uid == userID
        }
        return false
    }
    
    func saveComment(text: String?) {
        guard let text = text else { return }
        let comment = Comment()
        comment.text = text
        comment.userID = User.default?.id
        comments.insert(comment)
        update() { error in
            print(error.debugDescription)
        }
    }
}
