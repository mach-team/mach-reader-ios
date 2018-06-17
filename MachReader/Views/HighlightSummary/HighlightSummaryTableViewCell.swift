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
    var disposer: Disposer<Highlight>?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    func render(highlightText: String, commentText: String?) {
        highlightTextView.text = highlightText
//        let attributedText =  highlightTextView.mutableCopy() as? NSMutableAttributedString
//        attributedText?.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.yellow, range: NSMakeRange(0, highlightText.count - 10))
//        highlightTextView.attributedText = attributedText
        guard let comment = commentText else {
            commentTextView.isHidden = true
            return
        }
        commentTextView.isHidden = false
        commentTextView.text = comment
    }

}
