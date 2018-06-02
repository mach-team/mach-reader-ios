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

class HomeViewController: UIViewController {

    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var dataSource: DataSource<Book>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupObserver()
    }

    // MARK: - Private methods
    
    /// configure collectionView
    private func setupCollectionView() {
        collectionView.register(UINib(nibName: "BookCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BookCollectionViewCell")
        let flowLayout = UICollectionViewFlowLayout()
        let margin: CGFloat = 8
        flowLayout.itemSize = CGSize(width: 144, height: 144 * 1.8)
        flowLayout.minimumLineSpacing = margin
        flowLayout.minimumInteritemSpacing = margin
        flowLayout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
        collectionView.collectionViewLayout = flowLayout
    }
    
    /// start observation of Book model
    private func setupObserver() {
        dataSource = Book.order(by: \Book.updatedAt).limit(to: 30).dataSource()
            .on({ [weak self] (snapshot, changes) in
                guard let collectionView = self?.collectionView else { return }
                switch changes {
                case .initial:
                    collectionView.reloadData()
                case .update(let deletions, let insertions, let modifications):
                    collectionView.performBatchUpdates({
                        collectionView.insertItems(at: insertions.map { IndexPath(row: $0, section: 0) })
                        collectionView.deleteItems(at: deletions.map { IndexPath(row: $0, section: 0) })
                        collectionView.reloadItems(at: modifications.map { IndexPath(row: $0, section: 0) })
                    })
                case .error(let error):
                    print(error)
                }
            })
            .listen()
    }
    
    // https://dev.classmethod.jp/smartphone/iphone/ios-11-pdfkit/
    /// Go to reader screen with book
    private func openReader(book: Book?) {
        guard let book = book else { return }
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
    
    // MARK: - IBActions
    
    @IBAction func handleOpenICloud(_ sender: Any) {
        let documentPickerController = UIDocumentPickerViewController(documentTypes: [/* "org.idpf.epub-container", */"com.adobe.pdf"], in: .import)
        documentPickerController.delegate = self
        present(documentPickerController, animated: true)
    }
    
    @IBAction func handleOpenSample(_ sender: Any) {
        openSample()
    }
}

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let book = dataSource?[indexPath.item] else { return }
        openReader(book: book)
    }
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCollectionViewCell", for: indexPath) as! BookCollectionViewCell
        configure(cell, at: indexPath)
        return cell
    }
    
    func configure(_ cell: BookCollectionViewCell, at indexPath: IndexPath) {
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
        
        guard let id = SHA1.hexString(fromFile: url.path) else { return }
        
        Book.findOrCreate(by: id, fileUrl: url) { [weak self] book, error in
            self?.openReader(book: book)
            self?.stopAnimating()
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("cancelled")
    }
}

// MARK: - NVActivityIndicatorViewable
extension HomeViewController: NVActivityIndicatorViewable {}
