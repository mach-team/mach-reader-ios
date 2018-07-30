//
//  BookSettingsViewModel.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/06/23.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import Foundation

class BookSettingsViewModel {
    
    private let book: Book
    
    init(book: Book) {
        self.book = book
    }
    
    var isBookPublic: Bool {
        return book.isPublic
    }
    
    var isBookMine: Bool {
        return book.isMine
    }
    
    var bookTitle: String {
        return book.title ?? "No name"
    }
    
    func showOthersHighlight(isOn: Bool) {
        UserDefaultsUtil.showOthersHighlight = isOn
    }
    
    func changeActivityPrivacy(isPrivate: Bool) {
        UserDefaultsUtil.isPrivateActivity = isPrivate
    }
    
    func changeBookOpenScope(isPublic: Bool) {
        book.isPublic = isPublic
        book.update()
    }
    
    func removeBook() {
        book.remove()
    }
    
    func updateBookTitle(_ title: String) {
        book.title = title
        book.update()
    }
}
