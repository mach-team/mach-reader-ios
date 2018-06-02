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

    // MARK: - Private methods
    
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
    
    // https://dev.classmethod.jp/smartphone/iphone/ios-11-pdfkit/
    private func openReader(with url: URL, hashID: String = "", isLocal: Bool = false) {
        
        startAnimating(type: .circleStrokeSpin) // FIXME: This does not work...
        
        if isLocal {
            guard let document = PDFDocument(url: url) else { return }
            guard let id = SHA1.hexString(fromFile: url.path) else { return }
            let vc = PdfReaderViewController.instantiate(document: document, hashID: id, url: url)
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let data = try! Data(contentsOf: url)
            guard let document = PDFDocument(data: data) else { return }
            // guard let hashID = SHA1.hexString(fromFile: url.path) else { return }
            let vc = PdfReaderViewController.instantiate(document: document, hashID: hashID, url: url)
            navigationController?.pushViewController(vc, animated: true)
        }
        
        stopAnimating()
    }
    
    private func openSample() {
        guard let path = Bundle.main.path(forResource: "sample", ofType: "pdf") else { return }
        let pdfURL = URL(fileURLWithPath: path)
        openReader(with: pdfURL, isLocal: true)
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

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let book = dataSource?[indexPath.item] else { return }
        guard let url = book.contents?.downloadURL else { return }
        openReader(with: url, hashID: book.id)
    }
}

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
        cell.render(title: book.id)
        cell.disposer = book.listen { book, error in
            cell.render(title: book?.id ?? "")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: BookCollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.disposer?.dispose()
    }
}

// MARK: - UIDocumentPickerDelegate
extension HomeViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        openReader(with: url, isLocal: true)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("cancelled")
    }
}

// MARK: - NVActivityIndicatorViewable
extension HomeViewController: NVActivityIndicatorViewable {}
