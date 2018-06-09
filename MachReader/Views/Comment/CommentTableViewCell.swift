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
    @IBOutlet weak var commentTextView: UITextView!
    
    
    var disposer: Disposer<Comment>?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        userImageView.image = nil
    }

    func render(text: String, avatarURL: URL?) {
        commentTextView.text = text
        userImageView.kf.setImage(with: avatarURL)
    }
}
