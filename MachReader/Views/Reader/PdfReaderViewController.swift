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
        
        startAnimating(type: .circleStrokeSpin)
        
        viewModel.delegate = self
        
        NotificationObserver.add(name: .PDFViewAnnotationHit, method: handleHitAnnotation)
        NotificationObserver.add(name: .PDFViewPageChanged, method: handlePageChanged)
        NotificationObserver.add(name: .UIApplicationWillResignActive, method: handleSaveCurrentPage)
        
        setupDocument()
        setupPDFView()
        createMenu()
        
        drawStoredHighlights()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewModel.loadLastClosePageNumber()
//        guard let page = pdfView.document?.page(at: 3) else { return }
//        pdfView.go(to: page)
//
        stopAnimating()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        viewModel.saveCurrentPageNumber(currentPageNumber)
        NotificationObserver.removeAll(from: self)
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
        
        viewModel.registerBookInfo()
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
        
        let vc = CommentsViewController.instantiate(highlight: h)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }
    
    /// Notification handler for the current page change.
    @objc private func handlePageChanged(notification: Notification) {
        viewModel.pageChanged()
        drawStoredHighlights()
    }
    
    @objc private func handleSaveCurrentPage(notification: Notification) {
        viewModel.saveCurrentPageNumber(currentPageNumber)
    }
    
    /// Fetch Highlights stored at Firestore and display those annotation views.
    private func drawStoredHighlights() {
        viewModel.loadHighlights(page: currentPageNumber) { highlight in
            guard let selection = self.pdfView.document?.findString(highlight.text ?? "", withOptions: .caseInsensitive).first else { return }
            guard let page = selection.pages.first else { return }
            self.addHighlightView(selection: selection, page: page)
        }
    }
    
    /// Add highlight annotation view.
    private func addHighlightView(selection: PDFSelection, page: PDFPage) {
        selection.selectionsByLine().forEach { s in
            let highlight = PDFAnnotation(bounds: s.bounds(for: page), forType: .highlight, withProperties: nil)
            highlight.endLineStyle = .square
            page.addAnnotation(highlight)
        }
    }
    
    /// Call above method and save this Highlight at Firestore.
    @objc private func highlightAction(_ sender: UIMenuController?) {
        guard let currentSelection = pdfView.currentSelection else { return }
        guard let page = currentSelection.pages.first else { return }
        
        addHighlightView(selection: currentSelection, page: page)
        pdfView.clearSelection()
        
        viewModel.saveHighlight(text: currentSelection.string ?? "", page: currentPageNumber, bounds: currentSelection.bounds(for: page))
    }
    
    /// Go to AddCommentViewController to save both Highlight and Comment.
    @objc private func commentAction(_ sender: UIMenuController?) {
        guard let currentSelection = pdfView.currentSelection else { return }
        guard let page = currentSelection.pages.first else { return }
        guard let text = currentSelection.string else { return }
        guard let pageNumber = pdfView.document?.index(for: page) else { return }
        
        pdfView.clearSelection()

        let h = viewModel.newHighlight(text: text, page: pageNumber, bounds: currentSelection.bounds(for: page))
        
        let vc = AddCommentViewController.instantiate(highlight: h, book: viewModel.book) { [weak self] in
            self?.addHighlightView(selection: currentSelection, page: page)
            self?.viewModel.addVisibleHighlight(h)
        }
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet

        present(nav, animated: true)
    }
}

extension PdfReaderViewController: PdfReaderViewModelDelegate {
    func go(to pageNumber: Int) {
        guard let page = pdfView.document?.page(at: pageNumber) else { return }
        pdfView.go(to: page)
    }
}

// MARK: - NVActivityIndicatorViewable
extension PdfReaderViewController: NVActivityIndicatorViewable {}
