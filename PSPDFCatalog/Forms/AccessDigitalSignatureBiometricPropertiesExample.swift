//
//  Copyright © 2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

class CustomDigitalSignatureCoordinator: PSPDFDigitalSignatureCoordinator {
    override func presentSignedDocument(_ signedDocument: PSPDFDocument, showingPageIndex pageIndex: PageIndex, with presentationContext: PSPDFPresentationContext) {
        super.presentSignedDocument(signedDocument, showingPageIndex: pageIndex, with: presentationContext)

        let signedAnnotations = signedDocument.annotationsForPage(at: 0, type: AnnotationType.widget)
        let signedFormElement = signedAnnotations.filter({ annotation in
            return annotation.isKind(of: PSPDFSignatureFormElement.self)
        }).first

        let signedSignatureFormElement = signedFormElement as! PSPDFSignatureFormElement
        var privateKey: PSPDFPrivateKey?
        let signatureManager = PSPDFKit.sharedInstance.signatureManager
        let p12signer = signatureManager.registeredSigners.first as! PSPDFPKCS12Signer
        let p12 = p12signer.p12
        p12.unlock(withPassword: "test") { _, key, _ in
            privateKey = key
        }

        let biometricProperties = signedSignatureFormElement.signatureBiometricProperties(privateKey!)
        print("Biometric Properties")
        print("pressure list: \(biometricProperties?.pressureList ?? []))")
        print("time points: \(biometricProperties?.timePointsList ?? [])")
        print("touch radius: \(biometricProperties?.touchRadius ?? 0)")
        print("input mode: \(biometricProperties?.inputMethod ?? PSPDFDrawInputMethod.none)")

        let alert = UIAlertController(title: "Biometric Properties", message: "See the console logs for the Biometric Properties.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))

        // Wait for the "Signed" HUD to disappear.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            presentationContext.actionDelegate.present(alert, options: nil, animated: true, sender: nil)
        }
    }
}

class AccessDigitalSignatureBiometricPropertiesExample: PSCExample {

    override init() {
        super.init()

        title = "Access Biometric Properties after digitally signing a document"
        contentDescription = "Password is 'test'"
        category = .forms
        priority = 40
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let p12URL = samplesURL.appendingPathComponent("JohnAppleseed.p12")
        let p12data = try? Data(contentsOf: p12URL)
        let p12 = PSPDFPKCS12(data: p12data!)
        let p12signer = PSPDFPKCS12Signer(displayName: "John Appleseed", pkcs12: p12)
        let signatureManager = PSPDFKit.sharedInstance.signatureManager
        signatureManager.clearRegisteredSigners()
        signatureManager.register(p12signer)
        signatureManager.clearTrustedCertificates()

        // Add certs to trust store for the signature validation process
        let certURL = samplesURL.appendingPathComponent("JohnAppleseed.p7c")
        let certData = try? Data(contentsOf: certURL)
        let certificates = try? PSPDFX509.certificates(fromPKCS7Data: certData!)
        for x509 in certificates! {
            signatureManager.addTrustedCertificate(x509)
        }

        let sourceURL = samplesURL.appendingPathComponent("Form_example.pdf")
        let writeableURL = PSCCopyFileURLToDocumentFolderAndOverride(sourceURL, true)
        let document = PSPDFDocument(url: writeableURL)
        document.annotationSaveMode = .embedded

        let configuration = PSPDFConfiguration { builder in
            builder.overrideClass(PSPDFDigitalSignatureCoordinator.self, with: CustomDigitalSignatureCoordinator.self)
        }

        let controller = PSPDFViewController(document: document, configuration: configuration)
        return controller
    }
}
