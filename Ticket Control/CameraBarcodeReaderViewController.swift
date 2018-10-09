//
//  CameraBarcodeReaderViewController.swift
//  Ticket Control
//
//  Created by Yevgen Lysenko on 13.03.18.
//  Copyright © 2018 v-Ticket system. All rights reserved.
//

import UIKit
import AVFoundation


/// Displays the camera view for barcode scanning
class CameraBarcodeReaderViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, VTKBarcodeScanner {
    @IBOutlet var videoPreviewView: UIView!
    @IBOutlet var flashSwitch: UISwitch!
    @IBOutlet var flashIcon: UIImageView!

    var delegate: VTKScannerDelegate!
    var initSuccess: Bool = false

    private var session: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!

    /// @inheritDoc
    override func viewDidLoad() {
        super.viewDidLoad()

        initCamera()
    }


    /// @inheritDoc
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if initSuccess {
            previewLayer              = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.frame        = videoPreviewView.layer.bounds
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewView.layer.addSublayer(previewLayer)

            session.startRunning()
        } else {
            alertScanningNotPossible()
        }
    }


    /// @inheritDoc
    func captureOutput(_ output: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if let barcodeData = metadataObjects.first {
            let barcodeReadable = barcodeData as? AVMetadataMachineReadableCodeObject

            // Vibrate the device for a tactile feedback
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

            if let readableCode = barcodeReadable {
                barcodeDetected(readableCode.stringValue)
            }
        }
    }


    /// Action that toggle devices' built-in flash
    ///
    /// - Parameter sender: the UIView that was toggled
    @IBAction func flashSwitched(_ sender: UISwitch) {
        if sender.isOn {
            switchFlash(true)
        } else {
            switchFlash(false)
        }
    }

    // MARK: - Protocol methods

    /// Returns true if the camera is present and has been initialized correctly
    ///
    /// - Returns: true if connected
    func isConnected() -> Bool {
        return initSuccess
    }


    /// Does nothing with built-in Camera scanner
    func postponeBatteryRemain() {
        // do nothing
    }

    /// Always returns -1 as the hardware sanner is not present
    ///
    /// - Returns: -1
    func getBatteryRemain() -> NSNumber! {
        return -1
    }


    /// This is for the protocol conformance
    func invocateBarcodeScan() {
        // do nothing
    }

    /// Stop camera session if true given or resumes it otherwise
    ///
    /// - Parameter yes: stops camera session if true given
    func avoidScans(_ yes: Bool) {
        if yes {
            switchFlash(false)
            session.stopRunning()
        } else {
            session.startRunning()
            if (flashSwitch.isOn) {
                switchFlash(true)
            }
        }
    }

    /// This is a stub for compatibility with hardware scanners
    func wakeup() {
        // do nothing
    }

    // MARK: - Private


    /// Turns device's torch on or off if present
    ///
    /// - Parameter on: true to turn on torch
    private func switchFlash(_ on: Bool) {
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        if let device = device, device.hasTorch {
            do {
                try device.lockForConfiguration()
                if on {
                    do {
                        try device.setTorchModeOnWithLevel(0.25)
                    } catch {
                        print(error)
                    }
                } else {
                    device.torchMode = AVCaptureTorchMode.off
                }
                device.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
    }

    
    /// Initializes the camera for further barcode scan
    private func initCamera() {
        session = AVCaptureSession()

        let videoCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let videoInput: AVCaptureDeviceInput?

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if let captureDevice = videoCaptureDevice, !captureDevice.hasTorch {
            flashSwitch.isHidden = true
            flashIcon.isHidden = true
        }

        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        } else {
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [
                AVMetadataObjectTypeCode128Code,
                AVMetadataObjectTypeCode39Code,
                AVMetadataObjectTypeEAN13Code,
                AVMetadataObjectTypeQRCode
            ]
        } else {
            return
        }

        // Flag that we've successfully initialized the camera for further barcode scan
        initSuccess = true
    }


    /// Calls delegate to handle the barcode scan event
    ///
    /// - Parameter barcode: A String containing barcode
    private func barcodeDetected(_ barcode: String) {
        delegate.scannerBarcodeScannedNotification(barcode)
    }


    /// Shows an alert with an "unable to scan" message
    private func alertScanningNotPossible() {
        let alert = UIAlertController(
            title: NSLocalizedString("Ошибка", comment: "Заголовок алерта с ошибкой"),
            message: NSLocalizedString("Невозможно инициализировать камеру для сканирования!", comment: "Сообщение об ошибке в алерте"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil) // TODO: действие по завершению
        session = nil
    }
}
