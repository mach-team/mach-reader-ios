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
    
    private var viewModel: CommentsViewModel!

    static func instantiate(highlight: Highlight, isNew: Bool, book: Book? = nil) -> CommentsViewController {
        let sb = UIStoryboard(name: "Comments", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! CommentsViewController
        let vm = CommentsViewModel(highlight, isNew: isNew, book: book)
        vc.viewModel = vm
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTextView()
        setupTableView()
        setupData()
        setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationObserver.add(name: .UIKeyboardWillChangeFrame, method: keyboardWillChangeFrame)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationObserver.remove(name: .UIKeyboardWillChangeFrame)
    }

    // MARK: - Private methods
    
    private func setupTableView() {
        tableView.register(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentTableViewCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
    }
    
    private func setupTextView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        view.addGestureRecognizer(tapGesture)
        
        highlightTextView.text = viewModel.highlightText
        
        textView.layer.cornerRadius = 4.0
        textView.maxHeight = 120
    }
    
    private func setupData() {
        viewModel.loadComments() { [weak self] (snapshot, changes) in
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
        }
    }
    
    private func setupNavigationBar() {
        title = "Comments"
        let backButtonItem = UIBarButtonItem(image: UIImage(named: "ic_close"), style: .plain, target: self, action: #selector(handleCancelAction(_:)))
        let saveButton = UIBarButtonItem(image: UIImage(named: "ic_check"), style: .plain, target: self, action: #selector(handleSaveAction(_:)))
        navigationItem.leftBarButtonItem = backButtonItem
        navigationItem.rightBarButtonItem = saveButton
    }
    
    private func scrollToBottom() {
        if viewModel.commentsCount == 0 { return }
        let indexPath = IndexPath(row: viewModel.commentsCount - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    @objc private func handleSaveAction(_ sender: Any) {
        if textView.text.isEmpty {
            dismiss(animated: true)
            return
        }
        
        viewModel.saveComment(text: textView.text)
        
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
        return viewModel.commentsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell") as! CommentTableViewCell
        configure(cell, at: indexPath)
        return cell
    }
    
    func configure(_ cell: CommentTableViewCell, at indexPath: IndexPath) {
        guard let comment = viewModel.comment(at: indexPath) else { return }

        cell.render(text: comment.text ?? "", avatarURL: comment.user?.avatar?.downloadURL)
        cell.disposer = comment.listen { (comment, error) in
            comment?.loadUser() {
                cell.render(text: comment?.text ?? "", avatarURL: comment?.user?.avatar?.downloadURL)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: CommentTableViewCell, forRowAt indexPath: IndexPath) {
        cell.disposer?.dispose()
    }
}
