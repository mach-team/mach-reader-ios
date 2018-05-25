//
//  PdfReaderViewController.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/05/25.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import UIKit
import PDFKit

class PdfReaderViewController: UIViewController {

    @IBOutlet weak var pdfView: PDFView!
    
    // MARK: - Life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pdfView.document = getDocument()
        pdfView.backgroundColor = .lightGray
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.usePageViewController(true)
        
        createMenu()
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(highlight(_:)) {
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
        return document
    }

    private func createMenu() {
        let highlightItem = UIMenuItem(title: "Highlight", action: #selector(highlight(_:)))
        UIMenuController.shared.menuItems = [highlightItem]
    }
    
    @objc private func highlight(_ sender: UIMenuController?) {
        guard let currentSelection = pdfView.currentSelection else { return }
        let selections = currentSelection.selectionsByLine()
        guard let page = selections.first?.pages.first else { return }
        
        selections.forEach { selection in
            let highlight = PDFAnnotation(bounds: selection.bounds(for: page), forType: .highlight, withProperties: nil)
            highlight.endLineStyle = .square
            page.addAnnotation(highlight)
        }
        
        pdfView.clearSelection()
    }
    
}
