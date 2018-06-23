//
//  HomeBooksHeaderView.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/06/23.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import UIKit

class HomeBooksHeaderView: UICollectionReusableView {
        
    @IBOutlet private weak var headerLabel: UILabel!
    
    static let identifier = "HomeBooksHeaderView"
    
    static func instantiate() -> UINib {
        return UINib(nibName: "HomeBooksHeaderView", bundle: nil)
    }
    
    func render(text: String) {
        headerLabel.text = text
    }
}
