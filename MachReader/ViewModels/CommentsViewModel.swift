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
    private(set) var dataSource: DataSource<Comment>?
    
    init(_ highlight: Highlight) {
        self.highlight = highlight
    }
    
    var highlightText: String {
        return highlight.text ?? ""
    }

    var commentsCount: Int {
        return dataSource?.count ?? 0
    }
    
    func loadComments(completion: @escaping ((QuerySnapshot?, CollectionChange) -> Void)) {
        dataSource = highlight.comments.order(by: \Comment.createdAt).limit(to: 30).dataSource()
            .on({ (snapshot, changes) in
                completion(snapshot, changes)
            })
            .listen()
    }
    
    func comment(at indexPath: IndexPath) -> Comment? {
        return dataSource?[indexPath.item]
    }
    
    func saveComment(text: String?) {
        highlight.saveComment(text: text)
    }
}
