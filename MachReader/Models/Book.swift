//
//  Book.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/05/26.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import UIKit
import Pring

@objcMembers
class Book: Object {
    @objc enum BookType: Int {
        case pdf
        case epub
    }
    dynamic var hashID: String?
    dynamic var type: BookType = .pdf
    dynamic var viewers: ReferenceCollection<User> = []
    // dynamic var name: String?
}
