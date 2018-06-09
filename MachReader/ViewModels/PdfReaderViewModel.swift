//
//  PdfReaderViewModel.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/06/05.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import Foundation
import PDFKit
import Pring

protocol PdfReaderViewModelDelegate: class {
    func go(to: Int) -> Void
}

class PdfReaderViewModel {
    
    // a page keeps its highlight list
    private var visibleHighlights: Set<Highlight> = []
    
    init(withBook book: Book) {
        self.book = book
    }
    
    let book: Book
    
    lazy var document: PDFDocument? = {
        guard let url = book.contents?.downloadURL else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        guard let document = PDFDocument(data: data) else { return nil }
        return document
    }()
    
    weak var delegate: PdfReaderViewModelDelegate?
    
    func registerBookInfo() {
        // once register a book, then downloadURL becomes non null.
        if book.thumbnail?.downloadURL != nil { return }
        
        if let document = document {
            guard let attr = document.documentAttributes else { return }
            book.title = attr["Title"] as? String
            book.author = attr["Author"] as? String
            guard let firstPage = document.page(at: 0) else { return }
            let uiImage = firstPage.thumbnail(of: CGSize(width: 400, height: 400 / 0.7), for: .artBox)
            guard let imageData = UIImagePNGRepresentation(uiImage) else { return }
            book.thumbnail = File(data: imageData, mimeType: .png)
            book.isPublic = false
            book.update()
        }
    }
    
    func getTappedHighlight(bounds: CGRect) -> Highlight? {
        return Highlight.filter(visibleHighlights, withBounds: bounds)
    }
    
    func pageChanged() {
        visibleHighlights = []
    }
    
    func loadHighlights(page: Int, completion: @escaping (Highlight) -> ()) {
        book.getHighlights() { [weak self] highlight, error in
            guard let `self` = self else { return }
            guard let h = highlight else { return }
            
            if h.page == page {
                self.visibleHighlights.insert(h)
                completion(h)
            }
        }
    }
    
    func saveHighlight(text: String, page: Int, bounds: CGRect) {
        let highlight = book.saveHighlight(text: text, pageNumber: page, bounds: bounds)
        if highlight != nil { addVisibleHighlight(highlight!) }
    }
    
    func newHighlight(text: String, page: Int, bounds: CGRect) -> Highlight {
        return Highlight.new(text: text, page: page, bounds: bounds)
    }
    
    func addVisibleHighlight(_ highlight: Highlight) {
        visibleHighlights.insert(highlight)
    }
    
    func loadLastClosePageNumber() {
//        User.current() { [weak self] user in
//            guard let `self` = self else { return }
//            guard let user = user else { return }
//
//            user.readStatuses
//                .get(self.book.id) { readStatus, error in
//                    self.delegate?.go(to: readStatus?.pageNumber ?? 0)
//                }
//        }
//
        User.default?.readStatuses.get(self.book.id) { readStatus, error in
            self.delegate?.go(to: readStatus?.pageNumber ?? 0)
        }
    }
    
    func saveCurrentPageNumber(_ page: Int) {
//        User.current() { [weak self] user in
//            guard let `self` = self else { return }
//            guard let user = user else { return }
//
//            user.readStatuses
//                .get(self.book.id) { readStatus, error in
//                    if let rs = readStatus {
//                        rs.pageNumber = page
//                        rs.update()
//                    } else {
//                        let readStatus = ReadStatus(id: self.book.id)
//                        readStatus.pageNumber = page
//                        user.readStatuses.insert(readStatus)
//                        user.update()
//                    }
//                }
//        }
        User.default?.readStatuses
            .get(self.book.id) { readStatus, error in
                if let rs = readStatus {
                    rs.pageNumber = page
                    rs.update()
                } else {
                    let readStatus = ReadStatus(id: self.book.id)
                    readStatus.pageNumber = page
                    User.default?.readStatuses.insert(readStatus)
                    User.default?.update()
                }
        }
    }
}
