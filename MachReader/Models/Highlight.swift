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
    dynamic var comments: ReferenceCollection<Comment> = []
    
    static func new(text: String, page: Int) -> Highlight {
        let id = SHA1.hexString(from: "\(text)\(page)")!
        let highlight = Highlight(id: id)
        highlight.text = text
        highlight.page = page
        return highlight
    }
}
