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
        
        userImageView.image = nil
    }

    func render(text: String, avatarURL: URL?) {
        commentLabel.text = text
        //let url = URL(string: "https://s3-ap-northeast-1.amazonaws.com/credify.assets/images/avatars/avatar-01.svg")
        //let image = Identicon().icon(from: "string", size: CGSize(width: 80, height: 80))
        userImageView.kf.setImage(with: avatarURL)
        //userImageView.image = image
    }
}
