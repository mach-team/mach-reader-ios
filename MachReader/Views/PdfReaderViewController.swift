//
//  PdfReaderViewController.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/05/25.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import UIKit
import Foundation
import PDFKit

class PdfReaderViewController: UIViewController {

    @IBOutlet private weak var pdfView: PDFView!
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        // This is supposed to block user interaction when loading...
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicator.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        indicator.center = self.view.center
        indicator.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private var book: Book! = nil {
        didSet {
            activityIndicator.stopAnimating()
        }
    }
    
    // MARK: - Life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        setupDocument()
        setupPDFView()
        createMenu()
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(highlight(_:)) {
            return true
        } else if action == #selector(comment(_:)) {
            return true
        }
        return false
    }
    
    // MARK: - private methods
    
    private func setupDocument() {
        guard let path = Bundle.main.path(forResource: "sample", ofType: "pdf") else {
            print("failed to get path.")
            return
        }
        
        let pdfURL = URL(fileURLWithPath: path)
        let document = PDFDocument(url: pdfURL)
        pdfView.document = document
        
        let hashID = SHA1.hexString(fromFile: path) ?? ""
        Book.findOrCreate(by: hashID) { [weak self] book, error in
             self?.book = book
        }
    }
    
    private func setupPDFView() {
        pdfView.backgroundColor = .lightGray
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.usePageViewController(true)
    }

    private func createMenu() {
        let highlightItem = UIMenuItem(title: "Highlight", action: #selector(highlight(_:)))
        let commentItem = UIMenuItem(title: "Comment", action: #selector(comment(_:)))
        UIMenuController.shared.menuItems = [highlightItem, commentItem]
    }
    
    /**
     * Just add highlight view
     */
    private func highlight(selection: PDFSelection, page: PDFPage) {
        selection.selectionsByLine().forEach { s in
            let highlight = PDFAnnotation(bounds: s.bounds(for: page), forType: .highlight, withProperties: nil)
            highlight.endLineStyle = .square
            page.addAnnotation(highlight)
        }
    }
    
    /**
     * Add Highlight(call above method and save this Highlight to Firestore)
     */
    @objc private func highlight(_ sender: UIMenuController?) {
        guard let currentSelection = pdfView.currentSelection else { return }
        guard let page = currentSelection.pages.first else { return }
        
        highlight(selection: currentSelection, page: page)
        
        pdfView.clearSelection()
        
        book.saveHighlight(text: currentSelection.string, pageNumber: pdfView.document?.index(for: page))
    }
    
    /**
     * Add both Comment and Highlight(go to AddCommentViewController)
     */
    @objc private func comment(_ sender: UIMenuController?) {
        guard let currentSelection = pdfView.currentSelection else { return }
        guard let page = currentSelection.pages.first else { return }
        guard let text = currentSelection.string else { return }
        guard let pageNumber = pdfView.document?.index(for: page) else { return }
        
        pdfView.clearSelection()
        
        let h = Highlight()
        h.text = text
        h.page = pageNumber
        let vc = AddCommentViewController.instantiate(highlight: h, book: book) { [weak self] in
            self?.highlight(selection: currentSelection, page: page)
        }
        present(vc, animated: true)
    }
}
