//
//  Book.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/05/26.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import UIKit
import Pring

@objcMembers
final class Book: Object {
    @objc enum BookType: Int {
        case pdf
        case epub
    }
    dynamic var type: BookType = .pdf
    dynamic var title: String?
    dynamic var author: String?
    dynamic var contents: File?
    dynamic var thumbnail: File?
    dynamic var isPublic: Bool = false
    dynamic var viewers: ReferenceCollection<User> = []
    dynamic var highlights: NestedCollection<Highlight> = []
    
    private(set) var highlightDataSource: DataSource<Highlight>?
    
    static func findOrCreate(by hashID: String, fileUrl: URL? = nil, block: @escaping (Book?, Error?) -> Void) {
        Book.get(hashID) { (book, error) in
            if let e = error {
                print(e.localizedDescription)
                return
            }
            if book == nil {
                let book = Book(id: hashID)
                if let u = fileUrl {
                    book.contents = File(url: u, mimeType: .pdf)
                }
                
                User.default?.books.insert(book)
                User.default?.update()
                
                let tasks = book.save() { ref, error in
                }

                let task = tasks["contents"]
                // TODO: show task progress
                
                block(book, nil)
            } else if book != nil {
                User.default?.books.insert(book!)
                User.default?.update()
                
                block(book, nil)
            }
        }
    }
    
    func saveHighlight(text: String?, pageNumber: Int?, bounds: CGRect?) -> Highlight? {
        guard let text = text, let page = pageNumber, let bounds = bounds else { return nil }
        let highlight = Highlight.new(text: text, page: page, bounds: bounds)
        highlights.insert(highlight)
        update()
        return highlight
    }
    
    func getHighlights(page: Int, block: @escaping ((Highlight?, Error?) -> Void)) {
        highlightDataSource = highlights
            .where(\Highlight.page, isEqualTo: String(page))
            .dataSource()
            .on({ (snapshot, changes) in
                // do something
            })
            .onCompleted() { snapshot, storedHighlights in
                storedHighlights.forEach { storedHighlight in
                    block(storedHighlight, nil)
                }
            }.listen()
    }
}
