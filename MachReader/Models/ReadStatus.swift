//
//  ReadStatus.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/06/07.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import Foundation
import Pring

@objcMembers
final class ReadStatus: Object {
    // NOTE: this model's primary key is book id
    dynamic var pageNumber: Int = 0
}
