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
class Book: Object {
    @objc enum BookType: Int {
        case pdf
        case epub
    }
    dynamic var hashID: String? // sha1 hash
    dynamic var type: BookType = .pdf
    dynamic var viewers: ReferenceCollection<User> = []
    dynamic var highlights: ReferenceCollection<Highlight> = []
    
    static func findOrCreate(by hashID: String, block: @escaping (Book?, Error?) -> Void) {
        Book.where(\Book.hashID, isEqualTo: hashID).get { (snapshot, error) in
            if let e = error {
                print(e.localizedDescription)
                return
            }
            
            if let id = snapshot?.documents.first?.documentID {
                Book.get(id, block: { document, error in
                    block(document, error)
                })
            } else {
                let book = Book()
                book.hashID = hashID
                book.save()
                block(book, nil)
            }
            
        }
    }
    
    func saveHighlight(text: String?, pageNumber: Int?) {
        guard let text = text, let page = pageNumber else { return }
        
        let highlight = Highlight()
        highlight.text = text
        highlight.page = page
        highlight.save()
        
        highlights.insert(highlight)
        // viewers.insert(currentUser)
        
        update()
    }
}
