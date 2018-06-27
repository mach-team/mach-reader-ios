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

    private var highlightDataSource: DataSource<Highlight>?
    
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
    
    func registerBookInfoIfNeeded() {
        // once register a book, then downloadURL becomes non null.
        if book.thumbnail?.downloadURL != nil { return }
        
        if let document = document {
            book.update(fromDocument: document)
        }
    }
    
    func getTappedHighlight(bounds: CGRect) -> Highlight? {
        return Highlight.filter(highlightDataSource, withBounds: bounds)
    }
    
    func loadHighlights(page: Int, completion: @escaping (Highlight) -> ()) {
        let withOthers = UserDefaultsUtil.showOthersHighlight
        if withOthers {
            // TODO: filter with isPublic but this should consider the case if a user set isPrivateActivity true, the query is not easy...
            highlightDataSource = book.highlights
                .where(\Highlight.page, isEqualTo: String(page))
                .dataSource()
                .on({ (snapshot, changes) in
                    // do something
                })
                .onCompleted() { snapshot, storedHighlights in
                    storedHighlights.forEach { storedHighlight in
                        completion(storedHighlight)
                    }
                }.listen()
        } else {
            highlightDataSource = book.highlights
                .where(\Highlight.page, isEqualTo: String(page))
                .where(\Highlight.userID, isEqualTo: User.default!.id)
                .dataSource()
                .on({ (snapshot, changes) in
                    // do something
                })
                .onCompleted() { snapshot, storedHighlights in
                    storedHighlights.forEach { storedHighlight in
                        completion(storedHighlight)
                    }
                }.listen()
        }
    }
    
    func createHighlight(text: String, page: Int, bounds: CGRect) {
        let _ = Highlight.create(inBook: book, text: text, pageNumber: page, bounds: bounds)
    }
    
    func newHighlight(text: String, page: Int, bounds: CGRect) -> Highlight {
        return Highlight.new(text: text, page: page, bounds: bounds)
    }

    func loadLastClosePageNumber() {
        User.default?.readStatuses.get(self.book.id) { readStatus, error in
            self.delegate?.go(to: readStatus?.pageNumber ?? 0)
        }
    }
    
    func saveCurrentPageNumber(_ page: Int) {
        ReadStatus.saveCurrentPageNumber(page, byBookID: book.id)
    }
}
