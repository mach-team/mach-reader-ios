//
//  CommentTableViewCell.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/06/05.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import UIKit
import Pring
import Kingfisher

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var commentLabel: UILabel!
    
    var disposer: Disposer<Comment>?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        userImageView?.image = nil
    }

    func render(text: String) {
        commentLabel?.text = text
        // userImageView.kf.setImage(with: )
    }

}
