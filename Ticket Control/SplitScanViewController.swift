//
//  SplitScanViewController.swift
//  Ticket Control
//
//  Created by Yevgen Lysenko on 12.04.18.
//  Copyright © 2018 v-Ticket system. All rights reserved.
//

import UIKit

class SplitScanViewController: UIViewController {
    private var cameraBarcodeReaderVC: CameraBarcodeReaderViewController!
    private var scanVC: VTKScanViewController!

    /// @inheritDoc
    override func viewDidLoad() {
        // We need to reach the instances of nested View Controllers
        for i in 0...childViewControllers.count - 1 {
            let vc = childViewControllers[i]
            if vc is CameraBarcodeReaderViewController {
                cameraBarcodeReaderVC = vc as! CameraBarcodeReaderViewController
                continue
            }
            if vc is VTKScanViewController {
                scanVC = vc as! VTKScanViewController
            }
        }

        // We must set the appropriate properties of these VCs
        cameraBarcodeReaderVC.delegate = scanVC
        VTKScannerManager.sharedInstance().setupScanner(cameraBarcodeReaderVC,
                                                        withFrameworkType: .barcodeFrameworkAppleCamera,
                                                        withDelegate: scanVC)
        if cameraBarcodeReaderVC.initSuccess {
            scanVC.scanButton.isHidden = true
            scanVC.scannerBatStatusIcon.isHidden = true
            scanVC.scannerConnectedNotification()
        }
    }


    /// @inheritDoc
    override func viewDidAppear(_ animated: Bool) {
        // TODO: Init scanner here
    }
}
