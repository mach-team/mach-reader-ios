//
//  BookCollectionViewCell.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/06/02.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import UIKit
import Pring
import Kingfisher

class BookCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var disposer: Disposer<Book>?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        bookImageView.image = nil
    }
    
    func render(title: String, imageURL: URL?) {
        titleLabel.text = title
        bookImageView.kf.setImage(with: imageURL)
    }
}
