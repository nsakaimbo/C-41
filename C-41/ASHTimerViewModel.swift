//
//  ASHTimerViewModel.swift
//  C-41
//
//  Created by Nicholas Sakaimbo on 12/22/16.
//  Copyright © 2016 Ash Furrow. All rights reserved.
//

import AudioToolbox
import Foundation

fileprivate extension Selector {
    static let clockTick = #selector(ASHTimerViewModel.clockTick)
}

class ASHTimerViewModel: RVMViewModel {
    
    private(set) var recipeName: String!
    
    private(set) dynamic var currentStepString: NSString!
    
    private(set) dynamic var nextStepString: NSString!
    
    private(set) dynamic var timeRemainingString: NSString!
    
    private(set) dynamic var running: NSNumber!
    
    private(set) dynamic var complete: NSNumber!
    
    private dynamic var currentStepIndex: NSNumber!
    
    private dynamic lazy var currentStepTimeRemaining: CFTimeInterval = {
        
        guard let recipe = self.model as? ASHRecipe,
        let step = recipe.steps[0] as? ASHStep else {
            fatalError()
        }
        
        return CFTimeInterval(step.duration)
    }()
    
    private dynamic var timer: Timer?
    
    override init!(model: Any!) {
        super.init(model: model)
        
        currentStepIndex = 0
        
        // Reactive Bindings
        RAC(self, #keyPath(recipeName)) ~> RACObserve(model, #keyPath(ASHRecipe.name))
        
        let stepSignal = RACObserve(model, #keyPath(ASHRecipe.steps))
        
        let currentStepIndexSignal = RACObserve(self, #keyPath(currentStepIndex))
        
        RAC(self, #keyPath(currentStepString)) ~> RACSignal
            .combineLatest([stepSignal, currentStepIndexSignal] as NSArray)
            .map {
            
            if let tuple = $0 as? RACTuple,
                let steps = tuple.first as? NSOrderedSet,
                let index = tuple.second as? Int,
                0..<steps.count ~= index,
                
                let step = steps[index] as? ASHStep,
                let name = step.name {
                
                let temperature = String(format: "%d℃", step.temperatureC)
                return "\(name) - \(temperature)"
                
            } else {
                return ""
            }
        }
        
        // RAC nextStepString
        RAC(self, #keyPath(nextStepString)) ~> RACSignal
            .combineLatest([stepSignal, currentStepIndexSignal] as NSArray)
            .map {
                
                if let tuple = $0 as? RACTuple,
                    let steps = tuple.first as? NSOrderedSet,
                    let index = tuple.second as? Int,
                    0..<steps.count ~= (index+1),
                    let nextStep = steps[index + 1] as? ASHStep {
                    return nextStep.name
                }
                return nil
        }
        
        RAC(self, #keyPath(timeRemainingString)) ~> RACObserve(self, #keyPath(currentStepTimeRemaining))
            .map { (value) -> NSString? in
                
                guard let duration = value as? NSNumber else {
                    return nil
                }
                
                let seconds: Int = {
                    let s = duration.intValue % 60
                    
                    return s < 0 ? 0 : s
                }()
                let minutes = (duration.intValue - seconds) / 60
        
                return String(format: "%d:%02d", minutes, seconds) as NSString
        }
        
        RAC(self, #keyPath(complete)) ~> RACSignal
            .combineLatest([stepSignal, currentStepIndexSignal] as NSArray)
            .map {
                
                if let tuple = $0 as? RACTuple,
                    let steps = tuple.first as? NSOrderedSet,
                    let index = tuple.second as? Int {
                    return index < 0 || index >= steps.count
                }
                return nil
        }
        
        RAC(self, #keyPath(running)) ~> RACObserve(self, #keyPath(timer))
            .map {
                return $0 != nil
            }
    
    }
    
    func pause() {
        timer?.invalidate()
        timer = nil
    }
    
    func resume() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: .clockTick, userInfo: nil, repeats: true)
    }
    
    @objc func clockTick(_ timer: Timer) {
        
        guard let recipe = self.model as? ASHRecipe else {
            return
        }
        
        currentStepTimeRemaining.add(-1)
        
        if currentStepTimeRemaining < 0 {
            
            currentStepIndex = NSNumber(value:currentStepIndex.intValue + 1)
            
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            
            if currentStepIndex.intValue >= recipe.steps.count {
                
                pause()
                
            } else {
        
                if let step = recipe.steps[currentStepIndex as Int] as? ASHStep {
                    currentStepTimeRemaining = CFTimeInterval(step.duration)
                }
            }
        }
    }
}
