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
    dynamic var pdfHash: String?
    dynamic var text: String?
    dynamic var page: Int = 0
    dynamic var comments: ReferenceCollection<Comment> = []
}
