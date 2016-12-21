//
//  RAC.swift
//  C-41
//
//  Created by Nicholas Sakaimbo on 12/20/16.
//  Copyright © 2016 Ash Furrow. All rights reserved.
//

import Foundation

// a struct that replaces the RAC macro
struct RAC  {
    var target : NSObject!
    var keyPath : String!
    var nilValue : AnyObject!
    
    init(_ target: NSObject!, _ keyPath: String, nilValue: AnyObject? = nil) {
        self.target = target
        self.keyPath = keyPath
        self.nilValue = nilValue
    }
    
    func assignSignal(_ signal : RACSignal) {
        signal.setKeyPath(self.keyPath, on: self.target, nilValue: self.nilValue)
    }
}

infix operator ~>
func ~> (_ rac: RAC, _ signal: RACSignal) {
    rac.assignSignal(signal)
}

func RACObserve(_ target: NSObject!, _ keyPath: String) -> RACSignal  {
    return target.rac_values(forKeyPath: keyPath, observer: target)
}
