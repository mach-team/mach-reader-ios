//
//  HighlightSummaryTableViewCell.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/06/17.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import UIKit
import Pring

class HighlightSummaryTableViewCell: UITableViewCell {

    @IBOutlet private weak var highlightTextView: UITextView!
    @IBOutlet private weak var commentTextView: UITextView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var pageLabel: UILabel!
    var disposer: Disposer<Highlight>?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    func render(highlightText: String, page: String, date: Date?, commentText: String?) {
        highlightTextView.text = highlightText
        pageLabel.text = "P.\(page)"
        if let date = date {
            dateLabel.text = DateUtil.toString(from: date)
        }
        guard let comment = commentText else {
            commentTextView.isHidden = true
            return
        }
        commentTextView.isHidden = false
        commentTextView.text = comment
    }

}
