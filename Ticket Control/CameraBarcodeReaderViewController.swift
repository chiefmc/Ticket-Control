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
class CameraBarcodeReaderViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var session: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var initSuccess: Bool = false

    /// @inheritDoc
    override func viewDidLoad() {
        super.viewDidLoad()

        initCamera()
    }


    /// Initializes the camera for further barcode scan
    func initCamera() {
        session = AVCaptureSession()

        let videoCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let videoInput: AVCaptureDeviceInput?

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
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

        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        view.layer.addSublayer(previewLayer)

        session.startRunning()
        // Flag that we've successfully initialized the camera for further barcode scan
        initSuccess = true
    }

    /// Shows an alert with an "unable to scan" message
    func alertScanningNotPossible() {
        let alert = UIAlertController(title: "Ошибка ", message: "Невозможно инициализировать камеру для сканирования!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil) // TODO: действие по завершению
        session = nil
    }


    /// @inheritDoc
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !initSuccess {
            alertScanningNotPossible()
        }
    }


    /// @inheritDoc
    func captureOutput(_ output: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if let barcodeData = metadataObjects.first {
            let barcodeReadable = barcodeData as? AVMetadataMachineReadableCodeObject
            if let readableCode = barcodeReadable {
                barcodeDetected(readableCode.stringValue)
            }

            // Vibrate the device for a tactile feedback
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

            // To avoid a double scan
            session.stopRunning()
        }
    }

    func barcodeDetected(_ barcode: String) {
        print("Detected barcode: \(barcode)")
        // TODO: реализовать
    }
}
