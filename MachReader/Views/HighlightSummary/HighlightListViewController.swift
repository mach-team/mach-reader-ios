//
//  HighlightListViewController.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/06/17.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import UIKit

class HighlightListViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    private var viewModel: HighlightListViewModel!
    private var tapCallback: ((Int) -> ())!
    
    static func instantiate(book: Book, tapCallback: @escaping (Int) -> Void) -> HighlightListViewController {
        let sb = UIStoryboard(name: "HighlightList", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! HighlightListViewController
        vc.viewModel = HighlightListViewModel(book: book)
        vc.tapCallback = tapCallback
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        setupTableView()
        setData()
    }
    
    // MARK: - private methods
    
    private func setupTableView() {
        tableView.register(UINib(nibName: "HighlightSummaryTableViewCell", bundle: nil), forCellReuseIdentifier: "HighlightSummaryTableViewCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
    }
    
    private func setupNavBar() {
        title = viewModel.showOthersHighlightList ? "Every Note" : "My Note"
        let backButtonItem = UIBarButtonItem(image: UIImage(named: "ic_close"), style: .plain, target: self, action: #selector(handleCancelAction(_:)))
        let switchImage = viewModel.showOthersHighlightList ? UIImage(named: "ic_person") : UIImage(named: "ic_group")
        let switchRangeButton = UIBarButtonItem(image: switchImage, style: .plain, target: self, action: #selector(handleSwitchFetchRange(_:)))
        
        navigationItem.rightBarButtonItem = switchRangeButton
        navigationItem.leftBarButtonItem = backButtonItem
    }
    
    private func setData() {
        viewModel.loadHighlights() { [weak self] (snapshot, changes) in
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
            case .error(let error):
                print(error)
            }
        }
    }
    
    private func refresh() {
        // setData() FIXME: this crashes
        setupNavBar()
    }
    
    @objc private func handleCancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @objc private func handleSwitchFetchRange(_ sender: Any) {
        viewModel.switchHighlightListRange()
        refresh()
    }
}

// MARK: - UITableViewDelegate
extension HighlightListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let highlight = viewModel.highlight(at: indexPath) else { return }
        guard let page = highlight.page else { return }
        guard let pageNumber = Int(page) else { return }

        dismiss(animated: true) { [weak self] in
            self?.tapCallback(pageNumber)
        }
    }
}

// MARK: - UITableViewDataSource
extension HighlightListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.highlightsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HighlightSummaryTableViewCell") as! HighlightSummaryTableViewCell
        configure(cell, at: indexPath)
        return cell
    }
    
    func configure(_ cell: HighlightSummaryTableViewCell, at indexPath: IndexPath) {
        guard let highlight = viewModel.highlight(at: indexPath) else { return }
        cell.render(highlightText: highlight.text ?? "", page: highlight.page ?? "", date: highlight.createdAt, commentText: viewModel.commentText(at: indexPath))
        cell.disposer = highlight.listen { [weak self] (highlight, error) in
            cell.render(highlightText: highlight?.text ?? "", page: highlight?.page ?? "", date: highlight?.createdAt, commentText: self?.viewModel.commentText(at: indexPath))
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: HighlightSummaryTableViewCell, forRowAt indexPath: IndexPath) {
        cell.disposer?.dispose()
    }
}
