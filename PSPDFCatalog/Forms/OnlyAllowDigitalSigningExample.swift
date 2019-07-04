//
//  Copyright © 2018-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import Foundation

class DigitalSignatureViewController: PSPDFSignatureViewController {

    // Use a specific signer to force creating a digital signature.
    override var signer: PSPDFSigner? {
        return OnlyAllowDigitalSigningExample.johnAppleseedSigner
    }

    // Set the certificate selection mode to `.never` to disable the ability for users to select a different signer.
    override var certificateSelectionMode: PSPDFSignatureCertificateSelectionMode {
        get { return .never }
        set {}
    }
}

class OnlyAllowDigitalSigningExample: PSCExample {

    override init() {
        super.init()
        title = "Only allow adding digital signatures, no ink signatures."
        contentDescription = "password: test"
        category = .forms
        priority = 25
    }

    static let johnAppleseedSigner: PSPDFSigner = {
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let p12URL = samplesURL.appendingPathComponent("JohnAppleseed.p12")
        let p12data = try! Data(contentsOf: p12URL)
        let p12 = PSPDFPKCS12(data: p12data)
        return PSPDFPKCS12Signer(displayName: "John Appleseed", pkcs12: p12)
    }()

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let signatureManager = PSPDFKit.sharedInstance.signatureManager
        signatureManager.clearRegisteredSigners()
        signatureManager.register(OnlyAllowDigitalSigningExample.johnAppleseedSigner)

        signatureManager.clearTrustedCertificates()

        // Add certs to trust store for the signature validation process
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let certURL = samplesURL.appendingPathComponent("JohnAppleseed.p7c")
        let certData = try! Data(contentsOf: certURL)
        let certificates = try! PSPDFX509.certificates(fromPKCS7Data: certData)
        for x509 in certificates {
            signatureManager.addTrustedCertificate(x509)
        }
        let documentURL = samplesURL.appendingPathComponent("Form_example.pdf")
        let newURL = PSCCopyFileURLToDocumentFolderAndOverride(documentURL, true)
        let document = PSPDFDocument(url: newURL)
        document.annotationSaveMode = .embedded

        let controller = PSPDFViewController(document: document, configuration: PSPDFConfiguration { builder in
            builder.overrideClass(PSPDFSignatureViewController.self, with: DigitalSignatureViewController.self)
        })

        // Remove any stored signatures.
        controller.configuration.signatureStore.signatures = []

        return controller
    }
}
