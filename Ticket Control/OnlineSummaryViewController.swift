//
//  OnlineSummaryViewController.swift
//  Ticket Control
//
//  Created by Yevgen Lysenko on 12.04.18.
//  Copyright © 2018 v-Ticket system. All rights reserved.
//

import UIKit

class OnlineSummaryViewController: UIViewController {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        tabBarItem.title = NSLocalizedString("Онлайн", comment: "Название закладки")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /// Instantiates and presents the scanning view controller depending on the scanner type
    @IBAction func startScanAction() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        var vcName: String

        if shouldScanWithCamera() {
            vcName = "SplitScanViewController"
        } else {
            vcName = "ScanViewController"
        }
        let svc                              = storyboard.instantiateViewController(withIdentifier: vcName)
        let navController                    = UINavigationController.init(rootViewController: svc)
        navController.restorationIdentifier  = String(describing: self)
        navController.modalPresentationStyle = .formSheet
        navController.modalTransitionStyle   = .flipHorizontal
        present(navController, animated: true, completion: nil)
    }


    /// Returns true if the scan device to be used is the built-in Apple Camera
    ///
    /// - Returns: true if camera should be used
    private func shouldScanWithCamera() -> Bool {
        return VTKSettings.storage().scannerDeviceType == .barcodeFrameworkAppleCamera
    }
}
