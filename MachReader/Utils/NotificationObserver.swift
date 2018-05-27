//
//  NotificationObserver.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/05/27.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import Foundation

class NotificationObserver {
    static func add(name: Notification.Name, method: @escaping (Notification) -> Void) {
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil, using: method)
    }
    
    static func removeAll(from observer: Any) {
        NotificationCenter.default.removeObserver(observer)
    }
}
