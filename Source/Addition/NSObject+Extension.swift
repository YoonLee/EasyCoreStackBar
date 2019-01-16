//
//  NSObject+Extension.swift
//  EasyCoreStackBar
//
//  Created by Yoon Lee on 1/15/19.
//  Copyright © 2019 Yoon Lee. All rights reserved.
//

import Foundation

extension NSObject {
    public class var nameOfClass: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
}
