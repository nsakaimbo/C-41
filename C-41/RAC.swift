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
    weak var target : NSObject!
    let keyPath : String
    let nilValue : AnyObject!
    
    init(_ target: NSObject, _ keyPath: String, nilValue: AnyObject? = nil) {
        
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

func RACObserve(_ target: Any!, _ keyPath: String) -> RACSignal  {
    
    guard let target = target as? NSObject else {
        fatalError("RACObserve for target failed. Cannot initialize with non-NSObject types.")
    }
    
    return target.rac_values(forKeyPath: keyPath, observer: target)
}
