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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startAnimating(type: .circleStrokeSpin)
        
        setupCollectionView()
        setup3DTouch()
        
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
        flowLayout.sectionInset = UIEdgeInsets(top: margin, left: margin * 2, bottom: margin * 2, right: margin * 2)
        flowLayout.headerReferenceSize = CGSize(width: view.bounds.width, height: 40)

        collectionView.collectionViewLayout = flowLayout
        
        collectionView.register(HomeBooksHeaderView.instantiate(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: HomeBooksHeaderView.identifier)
    }
    
    private func setup3DTouch() {
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        }
    }
    
    private func loadBooks(type: HomeSectionType) {
        viewModel.loadBooks(type: type) { [weak self] snapshot, changes in
            guard let collectionView = self?.collectionView else { return }
            switch changes {
            case .initial:
                collectionView.reloadData()
            case .update(let deletions, let insertions, let modifications):
                collectionView.performBatchUpdates({
                    collectionView.insertItems(at: insertions.map { IndexPath(row: $0, section: type.rawValue) })
                    collectionView.deleteItems(at: deletions.map { IndexPath(row: $0, section: type.rawValue) })
                    collectionView.reloadItems(at: modifications.map { IndexPath(row: $0, section: type.rawValue) })
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
        
        startAnimating(type: .circleStrokeSpin)
        
        // Note: without this asyncAfter animation does not start
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            let vc = PdfReaderViewController.instantiate(book: book)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        // FOR DEBUG
//         book.remove()
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
        loadBooks(type: .all)
        loadBooks(type: .mine)
        stopAnimating()
    }
}

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let book = viewModel.book(at: indexPath) else { return }
        openReader(book: book)
    }
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return HomeSectionType.numberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.booksCount(at: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCollectionViewCell", for: indexPath) as! BookCollectionViewCell
        configure(cell, at: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: HomeBooksHeaderView.identifier, for: indexPath) as! HomeBooksHeaderView
            header.render(text: viewModel.headerText(at: indexPath))
            return header
        }
        return UICollectionReusableView()
    }
    
    func configure(_ cell: BookCollectionViewCell, at indexPath: IndexPath) {
        guard let book = viewModel.book(at: indexPath) else { return }
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
            Book.findOrCreate(by: id!, fileUrl: url) { [unowned self] book, error in
                self.stopAnimating()
                    
                if let e = error {
                    DispatchQueue.main.async {
                        self.stopAnimating()
                        e.displayAlert()
                    }
                }
                
                self.openReader(book: book)
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

// MARK: - UIViewControllerPreviewingDelegate
extension HomeViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = collectionView.indexPathForItem(at: location), let cellAttributes = collectionView.layoutAttributesForItem(at: indexPath) {
            previewingContext.sourceRect = cellAttributes.frame
            
            guard let book = viewModel.book(at: indexPath) else { return nil }
            return PdfReaderViewController.instantiate(book: book)
        }
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
    
    override var previewActionItems: [UIPreviewActionItem] {
        return []
    }
}

// MARK: - NVActivityIndicatorViewable
extension HomeViewController: NVActivityIndicatorViewable {}
