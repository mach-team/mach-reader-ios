//
//  User.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/05/26.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import UIKit
import Pring

@objcMembers
class User: Object {
    dynamic var name: String?
    dynamic var highlights: ReferenceCollection<Highlight> = []
}
