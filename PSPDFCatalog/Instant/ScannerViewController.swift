//
//  Copyright © 2018-2019 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

import AVFoundation
import PSPDFKitUI

/**
 * BarcodeScan is used by BarcodeScanner to state the result of the barcode scanning.
 */
enum BarcodeScanResult {
    case success(barcode: String)
    case failure(error: String)
}

protocol ScannerViewControllerDelegate: class {
    func didFinishScanning(with scan: BarcodeScanResult)
}

class BarcodeScannerView: UIView {

    weak var previewLayer: AVCaptureVideoPreviewLayer?

    convenience init(_ previewLayer: AVCaptureVideoPreviewLayer) {
        self.init()

        previewLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let previewLayer = previewLayer else { return }
        previewLayer.frame = self.layer.bounds
        previewLayer.connection?.videoOrientation = UIApplication.shared.statusBarOrientation.convertToAVCaptureVideoOrientation()
    }
}

class ScannerViewController: UIViewController {
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var scannerQueue = DispatchQueue(label: "com.pspdfkit.viewer.scanner-queue", qos: .userInitiated)
    weak var delegate: ScannerViewControllerDelegate?

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("Scan QR Code", comment: "Instant Code Scan QR Code Text")
        self.edgesForExtendedLayout = []
        view.backgroundColor = UIColor.black

        let captureSession = AVCaptureSession()
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)

        scannerQueue.async { [weak self] in
            guard let self = self else { return }
            self.setupScanning(captureSession: captureSession)
        }

        let scannerView = BarcodeScannerView(previewLayer)
        scannerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scannerView)

        NSLayoutConstraint.activate([
            scannerView.topAnchor.constraint(equalTo: self.view.topAnchor),
            scannerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            scannerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            scannerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
            ])

        self.previewLayer = previewLayer
        navigationController?.navigationBar.prefersLargeTitles = true

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: PSPDFKit.imageNamed("x"), style: .done, target: self, action: #selector(closePressed))
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let captureSession = previewLayer?.session, captureSession.isRunning {
            scannerQueue.async {
                captureSession.stopRunning()
            }
        }
    }

    func setupScanning(captureSession: AVCaptureSession) {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
            let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else { return }

        precondition(captureSession.canAddInput(videoInput))
        captureSession.addInput(videoInput)

        // Metadata output is used to get callbacks when camera detects barcode
        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.metadataObjectTypes = [.qr]

            // See explanation at the top of this class to find out why this is necessary.
            metadataOutput.perform(#selector(AVCaptureMetadataOutput.setMetadataObjectsDelegate(_:queue:)), with: self, with: scannerQueue)

            metadataOutput.setMetadataObjectsDelegate(self, queue: scannerQueue)

            // start running the capture session only once the setup is completed
            captureSession.startRunning()
        } else {
            let errorString = NSLocalizedString("Scanning is not supported on this device.", comment: "Instant barcode scan unsupported device message")
            self.delegate?.didFinishScanning(with: .failure(error: errorString))
        }
    }

    @objc func closePressed() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let captureSession = previewLayer?.session, captureSession.isRunning {
            captureSession.stopRunning()
        }

        guard let metadataObject = metadataObjects.first,
            let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
            let stringValue = readableObject.stringValue else {
                DispatchQueue.main.async {
                    self.delegate?.didFinishScanning(with: .failure(error: NSLocalizedString("Failed to read barcode.", comment: "Instant Barcode Reader Failure Title")))
                }
                return
        }

        DispatchQueue.main.async {
            self.delegate?.didFinishScanning(with: .success(barcode: stringValue))
        }
    }
}

extension UIInterfaceOrientation {
    func convertToAVCaptureVideoOrientation() -> AVCaptureVideoOrientation {
        switch self {
        case .landscapeLeft:
            return AVCaptureVideoOrientation.landscapeLeft
        case .landscapeRight:
            return AVCaptureVideoOrientation.landscapeRight
        case .portraitUpsideDown:
            return AVCaptureVideoOrientation.portraitUpsideDown
        case .portrait, .unknown:
            return AVCaptureVideoOrientation.portrait
        @unknown default:
            fatalError()
        }
    }
}
