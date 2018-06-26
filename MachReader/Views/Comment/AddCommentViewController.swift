//
//  AddCommentViewController.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/05/26.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import UIKit
import PDFKit

class AddCommentViewController: UIViewController {

    @IBOutlet private weak var highlightTextLabel: UILabel!
    @IBOutlet private weak var commentTextView: UITextView!
    
    private var highlight = Highlight()
    private var book = Book()
    
    static func instantiate(highlight: Highlight, book: Book) -> AddCommentViewController {
        let sb = UIStoryboard(name: "AddComment", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! AddCommentViewController
        vc.highlight = highlight
        vc.book = book
        return vc
    }
    
    // MARK: Life cycle method
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        highlightTextLabel.text = highlight.text
        commentTextView.becomeFirstResponder()
    }
    
    // MARK: - Private methods
    
    private func setupNavigationBar() {
        title = "Add Comment"
        // UIBarButtonItem(image: closeImage, style: .plain, target: self, action: #selector(handleCancelAction(_:)))
        let backButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancelAction(_:)))
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSaveAction(_:)))
        navigationItem.leftBarButtonItem = backButtonItem
        navigationItem.rightBarButtonItem = saveButton
    }
    
    @objc private func handleSaveAction(_ sender: Any) {
        if commentTextView.text.isEmpty {
            dismiss(animated: true)
        } else {
            // book
            book.highlights.insert(highlight)
            book.update() { [weak self] error in
                if error == nil {
                    Comment.save(text: self?.commentTextView.text, highlight: self!.highlight)
                } else {
                    print(error.debugDescription)
                }
            }

            dismiss(animated: true)
        }
    }
    
    @objc private func handleCancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
}
