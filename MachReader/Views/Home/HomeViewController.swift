//
//  HomeViewController.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/05/28.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import UIKit
import PDFKit
import NVActivityIndicatorView
import Pring
import FirebaseAuth

class HomeViewController: UIViewController {

    @IBOutlet private weak var collectionView: UICollectionView!
    
    private let viewModel = HomeViewModel()
    
    enum SectionType: Int {
        case all, mine
        
        static func numberOfItems() -> Int { return 2 }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startAnimating(type: .circleStrokeSpin)
        
        setupCollectionView()
        
        viewModel.delegate = self
        viewModel.sessionStart()
    }


    // MARK: - Private methods
    
    /// configure collectionView
    private func setupCollectionView() {
        collectionView.register(UINib(nibName: "BookCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BookCollectionViewCell")
        let flowLayout = UICollectionViewFlowLayout()
        let margin: CGFloat = 12
        let cellWidth: CGFloat = 150
        flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth * 1.8)
        flowLayout.minimumLineSpacing = margin
        flowLayout.minimumInteritemSpacing = margin
        flowLayout.sectionInset = UIEdgeInsets(top: margin * 2, left: margin * 2, bottom: margin * 2, right: margin * 2)
        collectionView.collectionViewLayout = flowLayout
    }
    
    private func loadBooks(isPublic: Bool) {
        viewModel.loadBooks(isPublic: isPublic) { [weak self] snapshot, changes in
            guard let collectionView = self?.collectionView else { return }
            switch changes {
            case .initial:
                collectionView.reloadData()
            case .update(let deletions, let insertions, let modifications):
                let section = isPublic ? SectionType.all.rawValue : SectionType.mine.rawValue
                collectionView.performBatchUpdates({
                    collectionView.insertItems(at: insertions.map { IndexPath(row: $0, section: section) })
                    collectionView.deleteItems(at: deletions.map { IndexPath(row: $0, section: section) })
                    collectionView.reloadItems(at: modifications.map { IndexPath(row: $0, section: section) })
                })
            case .error(let error):
                print(error)
            }
        }
    }
    
    // https://dev.classmethod.jp/smartphone/iphone/ios-11-pdfkit/
    /// Go to reader screen with book
    private func openReader(book: Book?) {
        guard let book = book else { return }
//        book.remove()
        let vc = PdfReaderViewController.instantiate(book: book)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// open sample.pdf
    private func openSample() {
        guard let path = Bundle.main.path(forResource: "sample", ofType: "pdf") else { return }
        let pdfURL = URL(fileURLWithPath: path)
        
        startAnimating(type: .circleStrokeSpin)
        
        guard let id = SHA1.hexString(fromFile: pdfURL.path) else { return }
        Book.findOrCreate(by: id, fileUrl: pdfURL) { [weak self] book, error in
            self?.openReader(book: book)
            self?.stopAnimating()
        }
    }
    
    private func removeBook() {
        
    }
    
    // MARK: - IBActions
    
    @IBAction private func handleOpenICloud(_ sender: Any) {
        let documentPickerController = UIDocumentPickerViewController(documentTypes: [/* "org.idpf.epub-container", */"com.adobe.pdf"], in: .import)
        documentPickerController.delegate = self
        present(documentPickerController, animated: true)
    }
}

// MARK: - HomeViewModelDelegate
extension HomeViewController: HomeViewModelDelegate {
    func onSignin() {
        loadBooks(isPublic: true)
        loadBooks(isPublic: false)
        stopAnimating()
    }
}

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let type = SectionType(rawValue: indexPath.section) else { return }
        
        var book: Book?
        switch type {
        case .all:
            book = viewModel.booksDataSource?[indexPath.item]
        case .mine:
            book = viewModel.myBooksDataSource?[indexPath.item]
        }
        if let b = book {
            openReader(book: b)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return SectionType.numberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let type = SectionType(rawValue: section) else { return 0 }
        switch type {
        case .all:
            return viewModel.booksDataSource?.count ?? 0
        case .mine:
            return viewModel.myBooksDataSource?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCollectionViewCell", for: indexPath) as! BookCollectionViewCell
        configure(cell, at: indexPath)
        return cell
    }
    
    func configure(_ cell: BookCollectionViewCell, at indexPath: IndexPath) {
        var dataSource: DataSource<Book>?
        guard let type = SectionType(rawValue: indexPath.section) else { return }
        switch type {
        case .all:
            dataSource = viewModel.booksDataSource
        default:
            dataSource = viewModel.myBooksDataSource
        }
        guard let book = dataSource?[indexPath.item] else { return }
        cell.render(title: book.id, imageURL: book.thumbnail?.downloadURL)
        cell.disposer = book.listen { book, error in
            cell.render(title: book?.title ?? "No Name.", imageURL: book?.thumbnail?.downloadURL)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: BookCollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.disposer?.dispose()
    }
}

// MARK: - UIDocumentPickerDelegate
extension HomeViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        
        startAnimating(type: .circleStrokeSpin)
        
        var id: String? = nil
        DispatchQueue.global().async {
            id = SHA1.hexString(fromFile: url.path)!
        }
        
        wait( { return id == nil } ) {
            Book.findOrCreate(by: id!, fileUrl: url) { [weak self] book, error in
                self?.openReader(book: book)
                self?.stopAnimating()
            }
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("cancelled")
    }
    
    // ref: https://qiita.com/asashin227/items/9fe627609bcfcba023d9
    func wait(_ waitContinuation: @escaping (()->Bool), compleation: @escaping (()->Void)) {
        var wait = waitContinuation()
        
        // wait for 0.01 sec until a stop condition get true
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue.global().async {
            while wait {
                DispatchQueue.main.async {
                    wait = waitContinuation()
                    semaphore.signal()
                }
                semaphore.wait()
                Thread.sleep(forTimeInterval: 0.01)
            }
            // stop condition got OK
            DispatchQueue.main.async {
                compleation()
            }
        }
    }
}

// MARK: - NVActivityIndicatorViewable
extension HomeViewController: NVActivityIndicatorViewable {}
