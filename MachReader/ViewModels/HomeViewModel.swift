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

protocol HomeViewModelDelegate: class {
    func onSignin() -> Void
}

class HomeViewModel {
    
    private(set) var booksDataSource: DataSource<Book>?
    private(set) var myBooksDataSource: DataSource<Book>?
    // private var currentUser: User?
    
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
        myBooksDataSource = User.default?.books.order(by: \Book.createdAt).limit(to: 30).dataSource()
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
        User.login() { [weak self] user in
            self?.delegate?.onSignin()
        }
    }
}
