//
//  Book.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/05/26.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import UIKit
import Pring
import Firebase
import FirebaseFirestore
import PDFKit

@objcMembers
final public class Book: Object {
    @objc enum BookType: Int {
        case pdf
        case epub
    }
    dynamic var type: BookType = .pdf
    dynamic var title: String?
    dynamic var author: String?
    dynamic var contents: File?
    dynamic var thumbnail: File?
    dynamic var isPublic: Bool = false
    dynamic var uploadUserID: String?
    dynamic var viewers: ReferenceCollection<User> = []
    dynamic var highlights: NestedCollection<Highlight> = []
    
    var isMine: Bool {
        if let uploader = uploadUserID, let userID = User.default?.id {
            return uploader == userID
        }
        return false
    }
    
    static func findOrCreate(by hashID: String, fileUrl: URL? = nil, data: Data? = nil, block: @escaping (Book?, Error?) -> Void) {
        Book.get(hashID) { (book, error) in
            if let e = error {
                print(e.localizedDescription)
                block(nil, e)
                return
            }
            
            // In case when this book is totally new
            if book == nil {
                let book = Book(id: hashID)
                book.uploadUserID = User.default?.id
                if let u = fileUrl {
                    book.contents = File(url: u, name: "book", mimeType: .pdf)
                }
                if let d = data {
                    book.contents = File(data: d, name: "book", mimeType: .pdf)
                }
                
                User.default?.books.insert(book)
                User.default?.update()
                
                let tasks = book.save() { ref, error in
                    if let e = error {
                        print(e.localizedDescription)
                        block(nil, APIError.failUpload)
                        return
                    }
                    print("book save success")
                    block(book, nil)
                }
                guard let task = tasks["contents"] else {
                    block(nil, APIError.failUpload)
                    return
                }

                task.observe(.progress) { snapshot in
                    // TODO: show task progress
                    print("upload started")
                    // https://firebase.google.com/docs/storage/ios/upload-files?authuser=0
                    let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                        / Double(snapshot.progress!.totalUnitCount)
                    print(percentComplete)
                }
                
                task.observe(.success) { snapshot in
                    print("upload success!!")
                }
                
                task.observe(.failure) { snapshot in
                    if let error = snapshot.error as NSError? {
                        switch StorageErrorCode(rawValue: error.code)! {
                        case .objectNotFound:
                            block(nil, APIError.failUpload)
                        case .unauthorized:
                            block(nil, APIError.failAuth)
                        case .cancelled:
                            block(nil, APIError.cancelled)
                        case .unknown:
                            block(nil, APIError.unknown)
                        default:
                            print("should retry")
                            book.save()
                        }
                    }
                }
                
            // In case when this book is already stored on server
            } else if book != nil {
                // record as a current user's reading book
                User.default?.books.insert(book!)
                User.default?.update() { error in
                    block(book, error)
                }
            }
        }
    }
    
    func remove() {
        let batch = Firestore.firestore().batch()
        batch.add(.delete, object: self)
        
        // FIXME: these remove should be executed in a batch
        User.default?.books.delete(id: id)
        User.default?.readStatuses.delete(id: id)

        batch.commit()
    }
    
    func update(fromDocument document: PDFDocument) {
        guard let attr = document.documentAttributes else { return }
        title = attr["Title"] as? String
        author = attr["Author"] as? String
        guard let firstPage = document.page(at: 0) else { return }
        let uiImage = firstPage.thumbnail(of: CGSize(width: 400, height: 400 / 0.7), for: .artBox)
        guard let imageData = UIImageJPEGRepresentation(uiImage, 1) else { return }
        thumbnail = File(data: imageData, mimeType: .jpeg)
        isPublic = false
        update() { error in print(error.debugDescription) }
    }
}
