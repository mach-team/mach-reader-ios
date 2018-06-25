//
//  Comment.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/05/26.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import UIKit
import Pring

@objcMembers
final class Comment: Object {
    dynamic var text: String?
    // dynamic var threadID: String?
    dynamic var userID: String?
    
    var user: User?
    
    func loadUser(completion: @escaping () -> Void) {
        guard let uid = userID else { return }
        User.get(uid) { user, error in
            self.user = user
            completion()
        }
    }
}
