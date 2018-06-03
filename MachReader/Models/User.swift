//
//  User.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/05/26.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import UIKit
import Pring
import Firebase

@objcMembers
class User: Object {
    
    dynamic var name: String?
    dynamic var avatar: File?
    dynamic var books: ReferenceCollection<Book> = []
    dynamic var highlights: ReferenceCollection<Highlight> = []
    
    // MARK: -
    static let loggedInNotification = NSNotification.Name(rawValue: "loggedInNotification")
    static let loggedOutNotification = NSNotification.Name(rawValue: "loggedOutNotification")
    
    @discardableResult
    func autoSignup(_ block: ((DocumentReference?, Error?) -> Void)? = nil) -> [String : StorageUploadTask] {
        return save { (ref, error) in
            if let error = error {
                block?(nil, error)
                return
            }
            NotificationCenter.default.post(name: User.loggedInNotification, object: ref)
            block?(ref, nil)
        }
    }
    
    func autoSignin() {
        NotificationCenter.default.post(name: User.loggedInNotification, object: nil)
    }

    class func loggedIn(_ block: @escaping () -> Void) -> NSObjectProtocol {
        return NotificationCenter.default.addObserver(forName: User.loggedInNotification, object: nil, queue: .main) { (notification) in
            print("login")
            block()
        }
    }
    
    class func loggedOut(_ block: @escaping () -> Void) -> AuthStateDidChangeListenerHandle {
        return Auth.auth().addStateDidChangeListener { (auth, user) in
            if user == nil {
                print("logout")
                block()
            }
        }
    }
    
    class func signout() {
        _ = try? Auth.auth().signOut()
    }
    
    /// Return current user
    class func current(_ completionHandler: @escaping ((User?) -> Void)) {
        guard let currentUser = Auth.auth().currentUser else {
            completionHandler(nil)
            return
        }
        User.get(currentUser.uid) { (user, _) in
            guard let user = user else {
                // the user is not saved in Firebase DB
                completionHandler(nil)
                return
            }
            completionHandler(user)
        }
    }
}
