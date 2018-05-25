//
//  ViewController.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/05/25.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let sb = UIStoryboard(name: "PdfReader", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! PdfReaderViewController
        present(vc, animated: true)
    }

}

