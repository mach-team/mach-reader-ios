//
//  RandomString.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/06/09.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import Foundation

class RandomString {
    static func generate(length: Int) -> String {
        let letters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
}
