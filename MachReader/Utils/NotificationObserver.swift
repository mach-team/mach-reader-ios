//
//  NotificationObserver.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/05/27.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import Foundation

class NotificationObserver {
    static var observers: [Notification.Name: NSObjectProtocol] = [:]
    
    static func add(name: Notification.Name, method: @escaping (Notification) -> Void) {
        let token = NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil, using: method)
        observers[name] = token
    }
    
    static func removeAll() {
        observers.forEach { NotificationCenter.default.removeObserver($0.value) }
    }
    
    static func remove(name: NSNotification.Name) {
        guard let observer: NSObjectProtocol = observers[name] else { return }
        NotificationCenter.default.removeObserver(observer)
    }
}
