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
    private var callback: (() -> Void)? = nil
    
    static func instantiate(highlight: Highlight, book: Book, block: (() -> Void)? = nil) -> AddCommentViewController {
        let sb = UIStoryboard(name: "AddComment", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! AddCommentViewController
        vc.highlight = highlight
        vc.book = book
        vc.callback = block
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
            highlight.comments.insert(comment)
            highlight.save() // Currently, only save is considered.
            
            dismiss(animated: true) { [weak self] in
                self?.callback?()
            }
        }
    }
    
    @IBAction func handleCancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
}
