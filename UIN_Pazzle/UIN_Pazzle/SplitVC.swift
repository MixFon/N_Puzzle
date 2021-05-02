//
//  SplitVC.swift
//  UIN_Pazzle
//
//  Created by Михаил Фокин on 01.05.2021.
//

import Cocoa

class SplitVC: NSSplitViewController {
    @IBOutlet weak var leftVC: NSSplitViewItem!
    @IBOutlet weak var gameVC: NSSplitViewItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let left = leftVC.viewController as? LeftVC {
            left.gameVC = gameVC.viewController as? GameViewController
        }
    }
}
