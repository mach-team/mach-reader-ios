//
//  AddCommentViewController.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/05/26.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import UIKit
import PDFKit
import GrowingTextView

class AddCommentViewController: UIViewController {

    @IBOutlet private weak var highlightTextLabel: UILabel!
    @IBOutlet private weak var commentTextView: GrowingTextView!
    
    private var highlight = Highlight()
    private var book = Book()
    
    static func instantiate(highlight: Highlight, book: Book) -> AddCommentViewController {
        let sb = UIStoryboard(name: "AddComment", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! AddCommentViewController
        vc.highlight = highlight
        vc.book = book
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        highlightTextLabel.text = highlight.text
    }
    
    // MARK: - IBActions
    
    @IBAction func handleSaveAction(_ sender: Any) {
        if commentTextView.text.isEmpty {
            dismiss(animated: true)
        } else {
            // comment
            let comment = Comment()
            comment.text = commentTextView.text
            comment.save()
            
            // book
            book.highlights.insert(highlight)
            // book.viewers.insert(currentUser)
            book.update()
            
            // highlight
            // すでに存在しているところにコメントをするときはupdate
            // 一旦ハイライトも新規作成に絞って考える
            highlight.comments.insert(comment)
            highlight.save()
            
            dismiss(animated: true)
        }
    }
    
    @IBAction func handleCancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
}
