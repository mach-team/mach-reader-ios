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
    
    private let book = Book()
    
    // MARK: - Life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    private func getDocument() -> PDFDocument? {
        guard let path = Bundle.main.path(forResource: "sample", ofType: "pdf") else {
            print("failed to get path.")
            return nil
        }
        let pdfURL = URL(fileURLWithPath: path)
        let document = PDFDocument(url: pdfURL)

        book.hashID = SHA1.hexString(fromFile: path)
        Book.get(hashID: SHA1.hexString(fromFile: path)!)
        // book.save()

        return document
    }
    
    private func setupPDFView() {
        pdfView.document = getDocument()
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
    
    private func highlight(selection: PDFSelection, page: PDFPage) {
        selection.selectionsByLine().forEach { s in
            let highlight = PDFAnnotation(bounds: s.bounds(for: page), forType: .highlight, withProperties: nil)
            highlight.endLineStyle = .square
            page.addAnnotation(highlight)
        }
    }
    
    @objc private func highlight(_ sender: UIMenuController?) {
        guard let currentSelection = pdfView.currentSelection else { return }
        guard let page = currentSelection.pages.first else { return }
        
        highlight(selection: currentSelection, page: page)
        
        pdfView.clearSelection()
    }
    
    @objc private func comment(_ sender: UIMenuController?) {
        guard let currentSelection = pdfView.currentSelection else { return }
        guard let page = currentSelection.pages.first else { return }
        guard let text = currentSelection.string else { return }
        guard let pageNumber = pdfView.document?.index(for: page) else { return }
        
        highlight(selection: currentSelection, page: page)
        
        pdfView.clearSelection()
        
        let vc = AddCommentViewController.instantiate(text: text, page: pageNumber, book: book)
        present(vc, animated: true)
    }
}
