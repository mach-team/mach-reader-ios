//
//  Error.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/06/24.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import UIKit

extension Error {
    func displayAlert(completion: (() -> Void)? = nil) {
        let alert = AlertController(title: "エラー", message: localizedDescription, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        alert.show(completion: completion)
    }
}

enum APIError: Error {
    case failUpload
    case failRequestTimeout
    case failAuth
    case cancelled
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .failUpload:
            return "ファイルのアップデートに失敗しました"
        case .failRequestTimeout:
            return "通信がタイムアウトになりました"
        case .failAuth:
            return "認証エラーになりました"
        case .cancelled:
            return "キャンセルされました"
        case .unknown:
            return "予期しないエラーが発生しました"
        }
    }
}
