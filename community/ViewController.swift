//
//  ViewController.swift
//  community
//
//  Created by Jonathan Landon on 7/13/18.
//

import UIKit
import MessageUI

class ViewController: UIViewController {
    
    private var didLayoutCount = 0
    private var didAppearOnce = false
    
    func viewDidLayout() {
        
    }
    
    func viewDidAppearForFirstTime() {
        
    }
    
    func setup() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard !didAppearOnce else { return }
        
        didAppearOnce = true
        viewDidAppearForFirstTime()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard view.bounds.width > 0, view.bounds.height > 0, didLayoutCount < 2 else { return }
        
        didLayoutCount += 1
        viewDidLayout()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
}

extension ViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
}
