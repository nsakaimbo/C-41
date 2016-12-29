//
//  ASHTimerViewController.swift
//  C-41
//
//  Created by Nicholas Sakaimbo on 12/20/16.
//  Copyright © 2016 Ash Furrow. All rights reserved.
//

import UIKit

fileprivate extension Selector {
    static let cancel = #selector(ASHTimerViewController.cancel(_:))
    static let pause = #selector(ASHTimerViewController.pause(_:))
    static let resume = #selector(ASHTimerViewController.resume(_:))
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
        RAC(stepNameLabel, #keyPath(UILabel.text)) ~> RACObserve(viewModel, #keyPath(ASHTimerViewModel.currentStepString))
        RAC(timeRemainingLabel, #keyPath(UILabel.text)) ~> RACObserve(viewModel, #keyPath(ASHTimerViewModel.timeRemainingString))
        RAC(nextStepLabel, #keyPath(UILabel.text)) ~> RACObserve(viewModel, #keyPath(ASHTimerViewModel.nextStepString))
        
        RAC(navigationItem, #keyPath(UINavigationItem.rightBarButtonItem)) ~> RACObserve(viewModel, #keyPath(ASHTimerViewModel.running))
            .distinctUntilChanged()
            .map { (isRunning) -> UIBarButtonItem in
                
                if let isRunning = isRunning as? NSNumber, isRunning.boolValue {
                    return UIBarButtonItem(barButtonSystemItem: .pause, target: self, action: .pause)
                } else {
                    return UIBarButtonItem(barButtonSystemItem: .play, target: self, action: .resume)
                }
        }
        
        RACObserve(viewModel, #keyPath(ASHTimerViewModel.complete)).subscribeNext { complete in
            
            guard let complete = complete as? Bool, complete else {
                return
            }
            
            let alert = UIAlertController(title: "Recipe Complete", message: "Your film has been developed.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.dismiss()
            })
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func dismiss() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func cancel(_ sender: UIBarButtonItem) {
        dismiss()
    }
    
    @objc fileprivate func pause(_ sender: UIBarButtonItem) {
        viewModel?.pause()
    }
    
    @objc fileprivate func resume(_ sender: UIBarButtonItem) {
        viewModel?.resume()
    }
}
