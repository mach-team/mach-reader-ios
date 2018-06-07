//
//  HomeViewModel.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/06/02.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import Foundation
import Pring
import Firebase
import FirebaseAuth

protocol HomeViewModelDelegate: class {
    func onSignin() -> Void
}

class HomeViewModel {
    
    private(set) var booksDataSource: DataSource<Book>?
    private(set) var myBooksDataSource: DataSource<Book>?
    private var currentUser: User?
    
    weak var delegate: HomeViewModelDelegate?
    
    enum SectionType: Int {
        case all, mine
        
        static func numberOfItems() -> Int { return 2 }
    }
    
    // MARK: - private methods
    
    private func loadPublicBooks(completion: @escaping ((QuerySnapshot?, CollectionChange) -> Void)) {
        booksDataSource = Book.where(\Book.isPublic, isEqualTo: true).order(by: \Book.createdAt).limit(to: 30).dataSource()
            .on({ (snapshot, changes) in
                completion(snapshot, changes)
            })
            .listen()
    }
    
    private func loadPrivateBooks(completion: @escaping ((QuerySnapshot?, CollectionChange) -> Void)) {
        myBooksDataSource = currentUser?.books.order(by: \Book.createdAt).limit(to: 30).dataSource()
            .on({ (snapshot, changes) in
                completion(snapshot, changes)
            })
            .listen()
    }
    
    // MARK: - public methods
    
    func loadBooks(isPublic: Bool, completion: @escaping ((QuerySnapshot?, CollectionChange) -> Void)) {
        
        if isPublic {
            loadPublicBooks(completion: completion)
        } else {
            loadPrivateBooks(completion: completion)
        }
    }
    
    func sessionStart() {
        User.current() { firebaseUser in
            // signup or signin
            Auth.auth().signInAnonymously { [weak self] (auth, error) in
                if let error: Error = error {
                    print(error)
                    User.signout()
                    return
                }
                
                let u = User(id: auth!.user.uid)
                
                if firebaseUser == nil {
                    // for registration
                    u.name = "ngo275"
                    u.autoSignup() { [weak self] ref, error in
                        self?.currentUser = u
                        self?.delegate?.onSignin()
                    }
                } else {
                    // for login
                    u.autoSignin()
                    self?.currentUser = firebaseUser
                    self?.delegate?.onSignin()
                }
            }
        }
    }
    
}
