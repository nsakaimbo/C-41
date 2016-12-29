//
//  Debug Helpers.swift
//  C-41
//
//  Created by Nicholas Sakaimbo on 12/29/16.
//  Copyright © 2016 Ash Furrow. All rights reserved.
//

import Foundation

// Love this handy-dandy debugging helper for chained if/guard-let statements
// From: http://ericasadun.com/2016/06/06/sneaky-swift-tricks-the-fake-boolean/
func diagnose(file: String = #file, line: Int = #line) -> Bool {
    print("Testing \(file):\(line)")
    return true
}
