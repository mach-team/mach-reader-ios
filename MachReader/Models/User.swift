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
import IGIdenticon

@objcMembers
class User: Object {
    
    static var `default`: User?
    
    dynamic var name: String?
    dynamic var avatar: File?
    dynamic var books: ReferenceCollection<Book> = []
    dynamic var highlights: ReferenceCollection<Highlight> = []
    dynamic var readStatuses: NestedCollection<ReadStatus> = []
    
    // MARK: -
    static let loggedInNotification = NSNotification.Name(rawValue: "loggedInNotification")
    static let loggedOutNotification = NSNotification.Name(rawValue: "loggedOutNotification")
    
    static var isLoggedin: Bool {
        return `default` != nil
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
        User.default = nil
    }

    class func login(_ completionHandler: @escaping ((User?) -> Void)) {
        // signup or signin
        Auth.auth().signInAnonymously { (auth, error) in
            if let error: Error = error {
                print(error)
                User.default = nil
                User.signout()
                completionHandler(nil)
                return
            }
            
            // In case that FirebaseAuth did not recognize this user
            guard let currentUser = Auth.auth().currentUser else {
                User.default = nil
                User.signout()
                completionHandler(nil)
                print("FirebaseAuth Error")
                return
            }
    
            // FirebaseAuth check is OK, next step is checking user status in Firestore
            User.get(currentUser.uid) { (user, _) in
                if let user = user {
                    // In case of an existing user
                    User.default = user
                    completionHandler(user)
                    print("Success login of an existing user")
                    NotificationCenter.default.post(name: User.loggedInNotification, object: nil)
                } else {
                    // In case of non-existing user
                    let u = User(id: auth!.user.uid)
                    let randomName = RandomString.generate(length: 8)
                    u.name = randomName
                    guard let avatar = Identicon().icon(from: randomName, size: CGSize(width: 100, height: 100)) else { return }
                    guard let imageData = UIImageJPEGRepresentation(avatar, 1) else { return }
                    u.avatar = File(data: imageData, mimeType: .jpeg)
                    u.save() { ref, error in
                        User.default = u
                        completionHandler(u)
                        print("Success login of a new user")
                        NotificationCenter.default.post(name: User.loggedInNotification, object: ref)
                    }
                }
            }
        }
    }
}
