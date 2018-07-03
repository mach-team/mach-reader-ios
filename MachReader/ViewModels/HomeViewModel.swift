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
import PDFKit

protocol HomeViewModelDelegate: class {
    func onSignin() -> Void
}

enum HomeSectionType: Int {
    case all, mine, recent
    
    // Currently, set 2 not 3 to hide .recent
    static func numberOfItems() -> Int { return 2 }
    
    func headerText() -> String {
        switch self {
        case .all:
            return "公開中の本"
        case .mine:
            return "自分の本"
        case .recent:
            return "最近開いた本"
        }
    }
}

class HomeViewModel {
    private var booksDataSource: DataSource<Book>?
    private var myBooksDataSource: DataSource<Book>?
    private var recentBookStatusDataSource: DataSource<ReadStatus>?
    private var recentBooks: [Book] = [] {
        didSet {
            print(recentBooks)
        }
    }
    
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
        case .recent:
            return recentBooks[indexPath.item]
        }
    }
    
    func booksCount(at section: Int) -> Int {
        guard let type = HomeSectionType(rawValue: section) else { return 0 }
        switch type {
        case .all:
            return booksDataSource?.count ?? 0
        case .mine:
            return myBooksDataSource?.count ?? 0
        case .recent:
            return recentBooks.count
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
        case .recent:
            loadRecentBooks(completion: completion)
        }
    }
    
    func sessionStart() {
        User.login() { [weak self] user in
            self?.delegate?.onSignin()
        }
    }
    
    func uploadBookIfNeeded() {
        if !User.isLoggedin { return }
        guard var sharedData = UserDefaultsUtil.sharedBookData else { return }
        guard let sha1 = SHA1.hexString(from: &sharedData) else { return }
        Book.findOrCreate(by: sha1, data: sharedData) { book, error in
            if let e = error {
                e.displayAlert()
            } else if let b = book {
                guard let doc = PDFDocument(data: sharedData) else { return }
                b.update(fromDocument: doc)
            }
            UserDefaultsUtil.sharedBookData = nil
        }
    }
    
    // MARK: - private methods
    
    private func loadPublicBooks(completion: @escaping ((QuerySnapshot?, CollectionChange) -> Void)) {
        let options: Options = Options()
        let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
        options.sortDescirptors = [sortDescriptor]
        booksDataSource = Book.where(\Book.isPublic, isEqualTo: true).order(by: \Book.updatedAt).limit(to: 30).dataSource(options: options)
            .on({ (snapshot, changes) in
                completion(snapshot, changes)
            })
            .listen()
    }
    
    private func loadPrivateBooks(completion: @escaping ((QuerySnapshot?, CollectionChange) -> Void)) {
        let options: Options = Options()
        let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        options.sortDescirptors = [sortDescriptor]
        myBooksDataSource = User.default?.books.order(by: \Book.createdAt).limit(to: 30).dataSource(options: options)
            .on({ (snapshot, changes) in
                completion(snapshot, changes)
            })
            .listen()
    }
    
    private func loadRecentBooks(completion: @escaping ((QuerySnapshot?, CollectionChange) -> Void)) {
        recentBookStatusDataSource = User.default?.readStatuses.order(by: \ReadStatus.updatedAt).limit(to: 30).dataSource()
            .on(parse: { (_, readStatus, done) in
                Book.get(readStatus.id) { book, error in
                    self.recentBooks.append(book!)
                }
            })
            .on({ (snapshot, changes) in
            })
            .onCompleted() { (snapshot, readStatuses) in
            }
            .listen()
    }
    
}
