//
//  InitialViewController.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/07/01.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import UIKit
import LTMorphingLabel

class InitialViewController: UIViewController, LTMorphingLabelDelegate {

    @IBOutlet weak var label: LTMorphingLabel!
    
    fileprivate var i = -1
    fileprivate var textArray = [
        "マッハリーダー", "それは", "新しい電子書籍リーダー", "みんなでコメント", "盛り上げろ！"
    ]
    fileprivate var text: String {
        i = i >= textArray.count - 1 ? 0 : i + 1
        return textArray[i]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        label.delegate = self
        label.morphingEffect = .burn
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        label.text = text
    }

    func morphingDidStart(_ label: LTMorphingLabel) {

    }
    
    func morphingDidComplete(_ label: LTMorphingLabel) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if self.i == self.textArray.count - 1 {
               UIApplication.shared.keyWindow?.rootViewController = HomeViewController.instantiate()
            } else {
                self.label.text = self.text
            }
        }
    }
    
    func morphingOnProgress(_ label: LTMorphingLabel, progress: Float) {
        
    }
}
