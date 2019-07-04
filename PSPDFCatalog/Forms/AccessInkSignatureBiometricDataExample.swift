//
//  Copyright © 2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

class CustomSignatureViewController: PSPDFSignatureViewController {
    override func done(_ sender: Any?) {
        super.done(sender)
        print("point sequences: \(self.drawView.pointSequences)")
        print("pressure list: \(self.drawView.pressureList)")
        print("time points: \(self.drawView.timePoints)")
        print("touch radii: \(self.drawView.touchRadii)")
        print("input mode: \(self.drawView.inputMode)")

        let alert = UIAlertController(title: "Biometric Data", message: "See the console logs for the biometric data.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.view.window?.rootViewController?.present(alert, animated: true)
    }
}

class AccessInkSignatureBiometricDataExample: PSCExample {

    override init() {
        super.init()

        title = "Access Biometric Data for an Ink Signature"
        contentDescription = "Shows how to access the biometric data of an ink signature from the signature controller's draw view."
        category = .forms
        priority = 45
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let sourceURL = samplesURL.appendingPathComponent("Form_example.pdf")
        let writeableURL = PSCCopyFileURLToDocumentFolderAndOverride(sourceURL, false)
        let document = PSPDFDocument(url: writeableURL)

        let configuration = PSPDFConfiguration { builder in
            builder.overrideClass(PSPDFSignatureViewController.self, with: CustomSignatureViewController.self)
        }

        let controller = PSPDFViewController(document: document, configuration: configuration)
        return controller
    }
}
