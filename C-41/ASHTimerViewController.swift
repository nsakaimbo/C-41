//
//  ASHTimerViewController.swift
//  C-41
//
//  Created by Nicholas Sakaimbo on 12/20/16.
//  Copyright © 2016 Ash Furrow. All rights reserved.
//

import UIKit

fileprivate extension Selector {
    static let cancel = #selector(ASHTimerViewController.cancel(sender:))
    static let pause = #selector(ASHTimerViewController.pause(sender:))
    static let resume = #selector(ASHTimerViewController.resume(sender:))
}

class ASHTimerViewController: UIViewController {

    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var stepNameLabel: UILabel!
    @IBOutlet weak var nextStepLabel: UILabel!
    
    var viewModel: ASHTimerViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure Self
        title = viewModel.recipeName
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: .cancel)
        
        // Configure subviews
        timeRemainingLabel.layer.cornerRadius = timeRemainingLabel.frame.height / 2.0
        timeRemainingLabel.layer.borderWidth = 5.0
        timeRemainingLabel.layer.borderColor = UIColor(hexString: "DE9726").cgColor
        timeRemainingLabel.textColor = UIColor(hexString: "522404")
        
        // Reactive Bindings
        // FIXME: We're using stringly-typed keypaths here. Isn't there a better/safer way by which we can add some compile-time checks?
        RAC(stepNameLabel, "text") ~> RACObserve(viewModel, "currentStepString")
        RAC(timeRemainingLabel, "text") ~> RACObserve(viewModel, "timeRemainingString")
        RAC(nextStepLabel, "text") ~> RACObserve(viewModel, "nextStepString")
        RAC(navigationItem, "rightBarButtonItem") ~> RACObserve(viewModel, "isRunning")
            .distinctUntilChanged()
            .map { (isRunning) -> UIBarButtonItem? in
                
                guard let isRunning = isRunning as? Bool else { return nil }
                
                if isRunning {
                    return UIBarButtonItem(barButtonSystemItem: .pause, target: self, action: .pause)
                } else {
                    return UIBarButtonItem(barButtonSystemItem: .play, target: self, action: .resume)
                }
        }
        
        RACObserve(viewModel, "complete").subscribeNext { complete in
            
            guard let complete = complete as? Bool, complete else { return }
            
            let alert = UIAlertController(title: "Recipe Complete", message: "Your film has been developed.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                
                self?.dismiss()
            })
        }
    }
    
    private func dismiss() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func cancel(sender: UIBarButtonItem) {
        dismiss()
    }
    
    @objc fileprivate func pause(sender: UIBarButtonItem) {
        viewModel?.pause()
    }
    
    @objc fileprivate func resume(sender: UIBarButtonItem) {
        viewModel?.resume()
    }
}
