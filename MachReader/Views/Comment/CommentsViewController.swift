//
//  CommentsViewController.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/06/04.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import UIKit

class CommentsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var highlight: Highlight!
    
    static func instantiate(highlight: Highlight) -> CommentsViewController {
        let sb = UIStoryboard(name: "Comments", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! CommentsViewController
        vc.highlight = highlight
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
    }

    // MARK: - Private methods
    
    private func setupNavigationBar() {
        title = "Comments"
        // UIBarButtonItem(image: closeImage, style: .plain, target: self, action: #selector(handleCancelAction(_:)))
        let backButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancelAction(_:)))
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSaveAction(_:)))
        navigationItem.leftBarButtonItem = backButtonItem
        navigationItem.rightBarButtonItem = saveButton
    }
    
    @objc private func handleSaveAction(_ sender: Any) {
//        if commentTextView.text.isEmpty {
//            dismiss(animated: true)
//        } else {
//            // comment
//            let comment = Comment()
//            comment.text = commentTextView.text
//            comment.save()
//
//            // highlight
//            highlight.comments.insert(comment)
//            highlight.save() // Currently, only save is considered.
//
//            // book
//            book.highlights.insert(highlight)
//            // book.viewers.insert(currentUser)
//            book.update()
//
//            dismiss(animated: true) { [weak self] in
//                self?.callback?()
//            }
//        }
    }
    
    @objc private func handleCancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension CommentsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tapped!!")
    }
}

extension CommentsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
