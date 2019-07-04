//
//  Copyright © 2018-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import PSPDFKit

class AsynchronousExternalDigitalSignatureExample: PSCExample {

    /// A sample `PSPDFDocumentSignerDelegate` implementation that asynchronously asks the user for a password to extract
    /// the private key with which the document will be signed.
    class PinEntryDocumentSignerDelegate: NSObject, PSPDFDocumentSignerDelegate {
        let viewController: UIViewController

        init(with viewController: UIViewController) {
            self.viewController = viewController
        }

        func documentSigner(_ signer: PSPDFSigner, sign data: Data,
                            hashAlgorithm: PSPDFSignatureHashAlgorithm, completion: @escaping PSPDFDocumentSignDataCompletionBlock) {
            DispatchQueue.main.async(execute: { () -> Void in
                let alert = UIAlertController(title: "Please enter the .p12 password to sign the document:", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alert.addTextField { textField in
                    textField.placeholder = "Enter the .p12 password here..."
                    textField.isSecureTextEntry = true
                }
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    if let password = alert.textFields?.first?.text {
                        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
                        let certURL = samplesURL.appendingPathComponent("JohnAppleseed.p12")
                        let pkcsBlob = try! Data(contentsOf: certURL)
                        let pkcs12 = PSPDFPKCS12(data: pkcsBlob)
                        pkcs12.unlock(withPassword: password) { _, privateKey, error in
                            // If we can't unlock the .p12 bundle, or we couldn't extract a private key, signal an error.
                            if error != nil {
                                completion(false, nil)
                                return
                            }
                            if privateKey == nil {
                                completion(false, nil)
                                return
                            }
                            let signedData = signer.sign(data, privateKey: privateKey!, hashAlgorithm: hashAlgorithm)
                            completion(true, signedData)
                        }
                    }
                }))
                self.viewController.present(alert, animated: true)
            })
        }
    }

    /// A sample `PinEntryDocumentSignerDataSource` implementation that provides information for the signature:
    /// A particular appearance, and that it should use RSA/SHA512.
    class PinEntryDocumentSignerDataSource: NSObject, PSPDFDocumentSignerDataSource {
        func documentSigner(_ signer: PSPDFSigner, signatureAppearance formFieldFqn: String) -> PSPDFSignatureAppearance {
            return PSPDFSignatureAppearance { builder in
                builder.showSignerName = true
                builder.showSignatureReason = true
                builder.appearanceMode = .signatureAndDescription
            }
        }

        func documentSigner(_ signer: PSPDFSigner, signatureHashAlgorithm formFieldFqn: String) -> PSPDFSignatureHashAlgorithm {
            return .SHA512
        }

        func documentSigner(_ signer: PSPDFSigner, signatureEncryptionAlgorithm formFieldFqn: String) -> PSPDFSignatureEncryptionAlgorithm {
            return .RSA
        }
    }

    override init() {
        super.init()
        title = "Signs a document asynchronously, simulating a PIN-entry screen."
        contentDescription = "Password is 'test'"
        category = .forms
        priority = 25
    }

    private func getFirstSignatureFormElement(from document: PSPDFDocument) -> PSPDFSignatureFormElement {
        let signatureFormElement = document.annotationsForPage(at: 0, type: .widget).first { annotation -> Bool in
            return annotation is PSPDFSignatureFormElement
        } as! PSPDFSignatureFormElement
        return signatureFormElement
    }

    private func generateDestinationFilePath() -> String {
        let destinationFileName = "\(UUID().uuidString).pdf"
        return NSTemporaryDirectory().appending(destinationFileName)
    }

    private func getCertificates(from samplesURL: URL) -> [PSPDFX509] {
        let certURL = samplesURL.appendingPathComponent("JohnAppleseed.p7c")
        let certData = try? Data(contentsOf: certURL)
        return try! PSPDFX509.certificates(fromPKCS7Data: certData!)
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController? {
        // Load a sample document.
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let documentURL = samplesURL.appendingPathComponent("Form_example.pdf")
        let newURL = PSCCopyFileURLToDocumentFolderAndOverride(documentURL, true)
        let unsignedDocument = PSPDFDocument(url: newURL)
        let signatureFormElement = getFirstSignatureFormElement(from: unsignedDocument)
        let destinationFilePath = generateDestinationFilePath()

        // Configure a signer instance.
        let signer = PSPDFSigner()
        signer.reason = "I agree with the terms of this contract."
        let certificates = getCertificates(from: samplesURL)
        let signCertificate = certificates.first!

        // We start the signing process asynchronously and push a view controller with the signed document when we are finished.
        // If the signing process failed, we show an error message instead.
        DispatchQueue.global(qos: .default).async(execute: {() -> Void in
            // Set a custom delegate and data source for this signer instance.
            let signerDelegate = PinEntryDocumentSignerDelegate(with: delegate.currentViewController!)
            signer.delegate = signerDelegate
            let documentSignerDataSource = PinEntryDocumentSignerDataSource()
            signer.dataSource = documentSignerDataSource
            signer.sign(signatureFormElement, withCertificate: signCertificate,
                        writeTo: destinationFilePath) { (success, signedDocument, error) -> Void in
                if success {
                    DispatchQueue.main.async(execute: { () -> Void in
                        delegate.currentViewController?.navigationController?.pushViewController(PSPDFViewController(document: signedDocument), animated: true)
                    })
                } else {
                    if let error = error {
                        DispatchQueue.main.async(execute: { () -> Void in
                            let alert = UIAlertController(title: "Error", message: "The document could not be signed. Error: \(String(describing: error)).", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            delegate.currentViewController?.present(alert, animated: true)
                        })
                    }
                }
            }
        })

        return nil
    }
}
