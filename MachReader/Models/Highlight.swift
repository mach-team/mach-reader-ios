//
//  Highlight.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/05/26.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import UIKit
import Pring

@objcMembers
final class Highlight: Object {
    dynamic var text: String?
    dynamic var page: Int = 0
    dynamic var originX: Double = 0
    dynamic var originY: Double = 0
    dynamic var width: Double = 0
    dynamic var height: Double = 0
    dynamic var comments: ReferenceCollection<Comment> = []
    
    static func new(text: String, page: Int, bounds: CGRect) -> Highlight {
        let id = SHA1.hexString(from: "\(text)\(page)")!
        let highlight = Highlight(id: id)
        highlight.text = text
        highlight.page = page
        highlight.originX = Double(bounds.origin.x)
        highlight.originY = Double(bounds.origin.y)
        highlight.width = Double(bounds.width)
        highlight.height = Double(bounds.height)
        
        return highlight
    }
    
    static func filter(_ highlights: [Highlight], withBounds bounds: CGRect) -> Highlight? {
        return highlights.filter { $0.bounds == bounds }.first
    }
    
    var bounds: CGRect {
        let b = CGRect(x: CGFloat(originX), y: CGFloat(originY), width: CGFloat(width), height: CGFloat(height))
        return b
    }
}
