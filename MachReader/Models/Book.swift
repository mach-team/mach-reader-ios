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
    dynamic var highlights: ReferenceCollection<Highlight> = []
    
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
                
                User.current() { user in
                    guard let user = user else { return }
                    user.books.insert(book)
                    user.update()
                }
                
                let tasks = book.save() { ref, error in
                }

                let task = tasks["contents"]
                // TODO: show task progress
                
                block(book, nil)
            } else if book != nil {
                User.current() { user in
                    guard let user = user else { return }
                    user.books.insert(book!)
                    user.update()
                }
                
                block(book, nil)
            }
        }
    }
    
    func saveHighlight(text: String?, pageNumber: Int?, bounds: CGRect?) {
        guard let text = text, let page = pageNumber, let bounds = bounds else { return }
        let highlight = Highlight.new(text: text, page: page, bounds: bounds)
        highlight.save()
        highlights.insert(highlight)
        // viewers.insert(currentUser)
        
        update()
    }
    
    func getHighlights(block: @escaping ((Highlight?, Error?) -> Void)) {
        highlights.order(by: \Highlight.updatedAt).get { snapshot, error in
            guard let ss = snapshot else { return }
            ss.documents.forEach { document in
                let highlightID = document.reference.documentID
                Highlight.get(highlightID) { highlight, error in
                    block(highlight, error)
                }
            }
        }
//        highlights
//            .order(by: \Highlight.updatedAt)
//            //.where(\Highlight.text, isEqualTo: "acroread")
//            .dataSource().onCompleted() { snapshot, storedHighlights in
//                storedHighlights.forEach { storedHighlight in
//                    block(storedHighlight, nil)
//                }
//            }.listen()
    }
}
