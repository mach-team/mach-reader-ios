//
//  CommentsViewModel.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/06/16.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import Foundation
import Pring
import Firebase

class CommentsViewModel {
    
    private let highlight: Highlight
    private let book: Book?
    private let isNewHighlight: Bool
    private var dataSource: DataSource<Comment>?
    
    init(_ highlight: Highlight, isNew: Bool, book: Book?) {
        self.highlight = highlight
        self.isNewHighlight = isNew
        self.book = book
    }
    
    var highlightText: String {
        return highlight.text ?? ""
    }

    var commentsCount: Int {
        return dataSource?.count ?? 0
    }
    
    func loadComments(completion: @escaping ((QuerySnapshot?, CollectionChange) -> Void)) {
        dataSource = highlight.comments.order(by: \Comment.updatedAt).limit(to: 30).dataSource()
            .on(parse: { (_, comment, done) in
                comment.loadUser() {
                    done(comment)
                }
            })
            .on({ (snapshot, changes) in
                completion(snapshot, changes)
            })
            .listen()
    }
    
    func comment(at indexPath: IndexPath) -> Comment? {
        return dataSource?[indexPath.item]
    }
    
    func saveComment(text: String?) {
        if isNewHighlight {
            guard let book = book else { return }
            highlight.save(inBook: book) { [unowned self] in
                Comment.save(text: text, highlight: self.highlight)
            }
        } else {
            Comment.save(text: text, highlight: highlight)
        }
    }
}
