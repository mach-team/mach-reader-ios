//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by ShuichiNagao on 2018/06/28.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {

    private let suiteName = "group.tech.mach.mach-reader"
    private let keyName = "SHARE_DATA"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        title = "アプリに保存"
        placeholder = "空でも大丈夫！"
        
        let controller: UIViewController = navigationController!.viewControllers.first!
        controller.navigationItem.rightBarButtonItem!.title = "保存"
    }
    
    override func isContentValid() -> Bool {
        print(contentText)
        return true
    }

    override func didSelectPost() {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem else { return }
        guard let itemProvider = extensionItem.attachments?.first as? NSItemProvider else { return }

        let publicPDF = String(kUTTypePDF)  // "public.pdf"

        if itemProvider.hasItemConformingToTypeIdentifier(publicPDF) {
            itemProvider.loadItem(forTypeIdentifier: publicPDF) { (item, error) in
                guard let url = item as? URL else { return }
                guard let sharedDefaults = UserDefaults(suiteName: self.suiteName) else { return }
                let data = NSData(contentsOf: url)
                sharedDefaults.set(data, forKey: self.keyName)
                sharedDefaults.synchronize()
                print("save ok")
                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
            }
        }
    }

    override func configurationItems() -> [Any]! {
        return []
    }

}
