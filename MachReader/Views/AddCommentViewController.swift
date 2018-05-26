//
//  AddCommentViewController.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/05/26.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import UIKit
import PDFKit
import GrowingTextView

class AddCommentViewController: UIViewController {

    @IBOutlet private weak var highlightTextLabel: UILabel!
    @IBOutlet private weak var commentTextView: GrowingTextView!
    
    private var highlight: Highlight!
    
    static func instantiate(text: String, page: Int) -> AddCommentViewController {
        let sb = UIStoryboard(name: "AddComment", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! AddCommentViewController
        let highlight = Highlight()
        highlight.text = text
        highlight.page = page
        vc.highlight = highlight
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        highlightTextLabel.text = highlight.text
    }
    
    // MARK: - IBActions
    
    @IBAction func handleSaveAction(_ sender: Any) {
        highlight.save()
    }
    
    @IBAction func handleCancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
}
