//
//  AddCommentViewController.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/05/26.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import UIKit
import PDFKit

class AddCommentViewController: UIViewController {

    private var highlightText: String!
    private var page: Int!
    
    static func instantiate(text: String, page: Int) -> AddCommentViewController {
        let sb = UIStoryboard(name: "AddComment", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! AddCommentViewController
        vc.highlightText = text
        vc.page = page
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
}
