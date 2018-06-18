//
//  DateUtil.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/06/19.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import Foundation

extension DateFormatter {

    enum Template: String {
        case date = "yMd"     // 2017/1/1
        case time = "Hms"     // 12:39:22
        case full = "yMdkHms" // 2017/1/1 12:39:22
        case onlyHour = "k"   // 17時
        case era = "GG"       // "西暦" (default) or "平成" (本体設定で和暦を指定している場合)
        case weekDay = "EEEE" // 日曜日
    }

    func setTemplate(_ template: Template) {
        dateFormat = DateFormatter.dateFormat(fromTemplate: template.rawValue, options: 0, locale: .current)
    }
}

class DateUtil {
    static func toString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.setTemplate(.full)
        return formatter.string(from: date)
    }
}
