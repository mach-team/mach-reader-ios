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
    
    private func openReader() {
        guard let path = Bundle.main.path(forResource: "sample", ofType: "pdf") else { return }
        let pdfURL = URL(fileURLWithPath: path)
        guard let document = PDFDocument(url: pdfURL) else { return }
        guard let hashID = SHA1.hexString(fromFile: path) else { return }
        
        let vc = PdfReaderViewController.instantiate(document: document, hashID: hashID)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - IBActions
    
    @IBAction func handleOpenICloud(_ sender: Any) {
        openReader()
    }
    
}
