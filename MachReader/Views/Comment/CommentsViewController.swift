//
//  CommentsViewController.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/06/04.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import UIKit
import Pring
import GrowingTextView

class CommentsViewController: UIViewController {

    @IBOutlet weak var highlightTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textView: GrowingTextView!
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewContainerHeight: NSLayoutConstraint!
    
    private var highlight: Highlight!
    private var commentsDataSource: DataSource<Comment>?

    static func instantiate(highlight: Highlight) -> CommentsViewController {
        let sb = UIStoryboard(name: "Comments", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! CommentsViewController
        vc.highlight = highlight
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentTableViewCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        
        NotificationObserver.add(name: .UIKeyboardWillChangeFrame, method: keyboardWillChangeFrame)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        view.addGestureRecognizer(tapGesture)
        
        highlightTextView.text = highlight.text
        
        textView.layer.cornerRadius = 4.0
        textView.maxHeight = 120
        tableView.tableFooterView = UIView()
        
        setupObserver()
        setupNavigationBar()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationObserver.removeAll(from: self)
    }

    // MARK: - Private methods
    
    private func setupObserver() {
        commentsDataSource = highlight.comments.order(by: \Comment.createdAt).limit(to: 30).dataSource()
            .on({ [weak self] (snapshot, changes) in
                guard let tableView = self?.tableView else { return }
                switch changes {
                case .initial:
                    tableView.reloadData()
                case .update(let deletions, let insertions, let modifications):
                    tableView.beginUpdates()
                    tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                    tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                    tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                    tableView.endUpdates()
                    self?.scrollToBottom()
                case .error(let error):
                    print(error)
                }
            })
            .listen()
    }
    
    private func setupNavigationBar() {
        title = "Comments"
        // UIBarButtonItem(image: closeImage, style: .plain, target: self, action: #selector(handleCancelAction(_:)))
        let backButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancelAction(_:)))
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSaveAction(_:)))
        navigationItem.leftBarButtonItem = backButtonItem
        navigationItem.rightBarButtonItem = saveButton
    }
    
    private func scrollToBottom() {
        guard let count = commentsDataSource?.count else { return }
        if count == 0 { return }
        let indexPath = IndexPath(row: count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    @objc private func handleSaveAction(_ sender: Any) {
        if textView.text.isEmpty {
            dismiss(animated: true)
            return
        }
        
        highlight.saveComment(text: textView.text)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.view.endEditing(true)
            self.dismiss(animated: true)
        }
    }
    
    @objc private func handleCancelAction(_ sender: Any) {
        view.endEditing(true)
        dismiss(animated: true)
    }
    
    @objc private func keyboardWillChangeFrame(notification: Notification) {
        if let endFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            var keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
            
            let isSameWidth = UIScreen.main.bounds.width == view.bounds.width
            let isSameHeight = UIScreen.main.bounds.height == view.bounds.height
            if (isSameWidth || isSameHeight) {
                if keyboardHeight > 0 {
                    keyboardHeight = keyboardHeight - view.safeAreaInsets.bottom
                }
            } else {
                // iPad
                if view.bounds.height + keyboardHeight + 20 - UIScreen.main.bounds.height > 0 {
                    keyboardHeight = view.bounds.height + keyboardHeight + 20 - UIScreen.main.bounds.height
                } else if view.bounds.height / 2 + keyboardHeight - UIScreen.main.bounds.height / 2 > 0 {
                    keyboardHeight = view.bounds.height / 2 + keyboardHeight - UIScreen.main.bounds.height / 2
                } else {
                    keyboardHeight = 0
                }
            }
            textViewBottomConstraint.constant = -keyboardHeight
            view.layoutIfNeeded()
        }
        scrollToBottom()
    }
    
    @objc func tapGestureHandler() {
        view.endEditing(true)
    }
    
    @IBAction func handleSaveButton(_ sender: Any) {
        view.endEditing(true)
        scrollToBottom()
        handleSaveAction(sender)
    }
}

extension CommentsViewController: GrowingTextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.textViewContainerHeight.constant = height + 20
            self.view.layoutIfNeeded()
        }
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
        return commentsDataSource?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell") as! CommentTableViewCell
        configure(cell, at: indexPath)
        return cell
    }
    
    func configure(_ cell: CommentTableViewCell, at indexPath: IndexPath) {
        guard let comment = commentsDataSource?[indexPath.item] else { return }
        
        cell.render(text: comment.text ?? "", avatarURL: User.default?.avatar?.downloadURL)
        cell.disposer = comment.listen { (comment, error) in
            cell.render(text: comment?.text ?? "", avatarURL: User.default?.avatar?.downloadURL)
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: CommentTableViewCell, forRowAt indexPath: IndexPath) {
        cell.disposer?.dispose()
    }
}
