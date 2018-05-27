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
    // dynamic var name: String?
    
    
    static func get(hashID: String) {
        var book: Book? = nil
        Book.where(\Book.hashID, isEqualTo: hashID).get { (snapshot, error) in
            print("bbbbb")
            guard let id = snapshot?.documents.first?.documentID else { return }
            Book.get(id, block: { document, error in
                // print(document?.hashID)
                book = document
            })
        }
        
        print(book?.hashID)
    }
}
