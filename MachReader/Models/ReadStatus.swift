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
    
    static func saveCurrentPageNumber(_ page: Int, byBookID id: String) {
        User.default?.readStatuses
            .get(id) { readStatus, error in
                if let rs = readStatus {
                    rs.pageNumber = page
                    rs.update()
                } else {
                    let readStatus = ReadStatus(id: id)
                    readStatus.pageNumber = page
                    User.default?.readStatuses.insert(readStatus)
                    User.default?.update()
                }
        }
    }
}
