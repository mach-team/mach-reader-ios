//
//  PdfReaderViewController.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/05/25.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import UIKit
import PDFKit
import Pring
import NVActivityIndicatorView

class PdfReaderViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet private weak var pdfView: PDFView!
    @IBOutlet private weak var pdfThumbnailView: PDFThumbnailView!
    
    private var viewModel: PdfReaderViewModel!

    private var currentPageNumber: Int {
        let page = pdfView.currentPage
        return pdfView.document?.index(for: page!) ?? 0
    }
    
    // MARK: - Initialize method
    
    static func instantiate(book: Book) -> PdfReaderViewController {
        let sb = UIStoryboard(name: "PdfReader", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! PdfReaderViewController
        vc.viewModel = PdfReaderViewModel(withBook: book)
        return vc
    }
    
    // MARK: - Life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // this is not necessary becasuse animation is triggered in previous screen.
        // startAnimating(type: .circleStrokeSpin)
        
        viewModel.delegate = self
        
        setupDocument()
        setupPDFView()
        setupNavBar()
        createMenu()
        
        drawStoredHighlights()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationObserver.add(name: .PDFViewAnnotationHit, method: handleHitAnnotation)
        NotificationObserver.add(name: .PDFViewPageChanged, method: handlePageChanged)
        NotificationObserver.add(name: .UIApplicationWillResignActive, method: handleSaveCurrentPage)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewModel.loadLastClosePageNumber()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        viewModel.saveCurrentPageNumber(currentPageNumber)
    }
    
    deinit {
        // FIXME: not called because of notificaiton.
        NotificationObserver.removeAll()
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(highlightAction(_:)) {
            return true
        } else if action == #selector(commentAction(_:)) {
            return true
        }
        return false
    }
    
    // MARK: - private methods
    
    /// PDF data handling for init
    private func setupDocument() {
        pdfView.document = viewModel.document
        
        viewModel.registerBookInfoIfNeeded()
    }
    
    /// Base settings for PDFView.
    private func setupPDFView() {
        pdfView.backgroundColor = .lightGray
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .horizontal
        pdfView.usePageViewController(true)
        
        pdfThumbnailView.pdfView = pdfView
        pdfThumbnailView.layoutMode = .horizontal
        pdfThumbnailView.backgroundColor = UIColor.gray
    }

    private func setupNavBar() {
        let openHighlightListButton = UIBarButtonItem(image: UIImage(named: "ic_list"), style: .plain, target: self, action: #selector(handleHighlightListAction(_:)))
        let settingsButton = UIBarButtonItem(image: UIImage(named: "ic_setting"), style: .plain, target: self, action: #selector(handleSettingsAction(_:)))

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.view.tintColor = UIColor.white
        navigationItem.rightBarButtonItems = [settingsButton, openHighlightListButton]
    }
    
    /// Customize UIMenuController.
    private func createMenu() {
        let highlightItem = UIMenuItem(title: "Highlight", action: #selector(highlightAction(_:)))
        let commentItem = UIMenuItem(title: "Comment", action: #selector(commentAction(_:)))
        UIMenuController.shared.menuItems = [highlightItem, commentItem]
    }
    
    /// Notification handler for hitting of annotation, such as an existing highlight.
    @objc private func handleHitAnnotation(notification: Notification) {
        guard let annotation = notification.userInfo?["PDFAnnotationHit"] as? PDFAnnotation else { return }
        guard let h = viewModel.getTappedHighlight(bounds: annotation.bounds) else { return }
        
        let vc = CommentsViewController.instantiate(highlight: h, isNew: false)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }
    
    /// Notification handler for the current page change.
    @objc private func handlePageChanged(notification: Notification) {
        drawStoredHighlights()
    }
    
    @objc private func handleSaveCurrentPage(notification: Notification) {
        viewModel.saveCurrentPageNumber(currentPageNumber)
    }
    
    @objc private func handleHighlightListAction(_ sender: Any) {
        let vc = HighlightListViewController.instantiate(book: viewModel.book) { [weak self] page in
            self?.go(to: page)
        }
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }
    
    @objc private func handleSettingsAction(_ sender: Any) {
        let vc = BookSettingsViewController.instantiate(book: viewModel.book)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }
    
    /// Fetch Highlights stored at Firestore and display those annotation views.
    private func drawStoredHighlights() {
        viewModel.loadHighlights(page: currentPageNumber) { [weak self] highlight in
            guard let selection = self?.pdfView.document?.findString(highlight.text ?? "", withOptions: .caseInsensitive).first else { return }
            guard let page = selection.pages.first else { return }
            
            self?.addHighlightView(selection: selection, page: page, isMine: highlight.isMine)
        }
    }
    
    /// Add highlight annotation view.
    private func addHighlightView(selection: PDFSelection, page: PDFPage, isMine: Bool) {
        selection.selectionsByLine().forEach { s in
            let highlight = PDFAnnotation(bounds: s.bounds(for: page), forType: .highlight, withProperties: nil)
            if !isMine {
                highlight.color = UIColor.cyan
            }
            highlight.endLineStyle = .square
            page.addAnnotation(highlight)
        }
    }
    
    /// Call above method and save this Highlight at Firestore.
    @objc private func highlightAction(_ sender: UIMenuController?) {
        guard let currentSelection = pdfView.currentSelection else { return }
        guard let page = currentSelection.pages.first else { return }

        pdfView.clearSelection()
        
        viewModel.createHighlight(text: currentSelection.string ?? "", page: currentPageNumber, bounds: currentSelection.bounds(for: page))
    }
    
    /// Go to AddCommentViewController to save both Highlight and Comment.
    @objc private func commentAction(_ sender: UIMenuController?) {
        guard let currentSelection = pdfView.currentSelection else { return }
        guard let page = currentSelection.pages.first else { return }
        guard let text = currentSelection.string else { return }
        guard let pageNumber = pdfView.document?.index(for: page) else { return }
        
        pdfView.clearSelection()

        let h = viewModel.newHighlight(text: text, page: pageNumber, bounds: currentSelection.bounds(for: page))
        
        let vc = CommentsViewController.instantiate(highlight: h, isNew: true, book: viewModel.book)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }
}

// MAEK: - PdfReaderViewModelDelegate
extension PdfReaderViewController: PdfReaderViewModelDelegate {
    func go(to pageNumber: Int) {
        guard let page = pdfView.document?.page(at: pageNumber) else { return }
        pdfView.go(to: page)
        stopAnimating()
    }
}

// MARK: - NVActivityIndicatorViewable
extension PdfReaderViewController: NVActivityIndicatorViewable {}
