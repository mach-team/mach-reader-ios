//
//  HomeViewController.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/05/28.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import UIKit
import PDFKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Private methods
    
    private func openReader(with url: URL) {
        guard let document = PDFDocument(url: url) else { return }
        guard let hashID = SHA1.hexString(fromFile: url.path) else { return }

        let vc = PdfReaderViewController.instantiate(document: document, hashID: hashID)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func openSample() {
        guard let path = Bundle.main.path(forResource: "sample", ofType: "pdf") else { return }
        let pdfURL = URL(fileURLWithPath: path)
        openReader(with: pdfURL)
    }
    
    // MARK: - IBActions
    
    @IBAction func handleOpenICloud(_ sender: Any) {
        let documentPickerController = UIDocumentPickerViewController(documentTypes: ["org.idpf.epub-container", "com.adobe.pdf"], in: .import)
        documentPickerController.delegate = self
        present(documentPickerController, animated: true)
    }
}

// MARK: - UIDocumentPickerDelegate
extension HomeViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        openReader(with: url)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("cancelled")
    }
}
