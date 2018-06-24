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

enum HomeSectionType: Int {
    case all, mine
    
    static func numberOfItems() -> Int { return 2 }
    
    func headerText() -> String {
        switch self {
        case .all:
            return "公開中の本"
        case .mine:
            return "自分の本"
        }
    }
}

class HomeViewModel {
    private(set) var booksDataSource: DataSource<Book>?
    private(set) var myBooksDataSource: DataSource<Book>?
    
    weak var delegate: HomeViewModelDelegate?
    
    // MARK: - public methods
    
    func section(indexPath: IndexPath) -> HomeSectionType? {
        return HomeSectionType(rawValue: indexPath.section)
    }
    
    func book(at indexPath: IndexPath) -> Book? {
        guard let type = HomeSectionType(rawValue: indexPath.section) else { return nil }
        switch type {
        case .all:
            return booksDataSource?[indexPath.item]
        case .mine:
            return myBooksDataSource?[indexPath.item]
        }
    }
    
    func booksCount(at section: Int) -> Int {
        guard let type = HomeSectionType(rawValue: section) else { return 0 }
        switch type {
        case .all:
            return booksDataSource?.count ?? 0
        case .mine:
            return myBooksDataSource?.count ?? 0
        }
    }
    
    func headerText(at indexPath: IndexPath) -> String {
        guard let type = HomeSectionType(rawValue: indexPath.section) else { return "" }
        return type.headerText()
    }
    
    func loadBooks(type: HomeSectionType, completion: @escaping ((QuerySnapshot?, CollectionChange) -> Void)) {
        switch type {
        case .all:
            loadPublicBooks(completion: completion)
        case .mine:
            loadPrivateBooks(completion: completion)
        }
    }
    
    func sessionStart() {
        User.login() { [weak self] user in
            self?.delegate?.onSignin()
        }
    }
    
    // MARK: - private methods
    
    private func loadPublicBooks(completion: @escaping ((QuerySnapshot?, CollectionChange) -> Void)) {
        booksDataSource = Book.where(\Book.isPublic, isEqualTo: true).order(by: \Book.updatedAt).limit(to: 30).dataSource()
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
    
    /**
     * FIXME: this is not good way to load recent books...
     private func loadRecentBooks(completion: @escaping ((QuerySnapshot?, CollectionChange) -> Void)) {
     User.default?.readStatuses.order(by: \ReadStatus.updatedAt).get() { (snapshot, error) in
     snapshot?.documents.forEach { document in
     Book.get(document.documentID) { [weak self] (book, error) in
     guard let book = book else { return }
     self?.recentBooks.append(book)
     }
     }
     }
     }
     **/
}
