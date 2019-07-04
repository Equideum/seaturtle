//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'PSCCustomStampAnnotationsExample.m' for the Objective-C version of this example.

class CustomStampAnnotationsExample: PSCExample, PSPDFViewControllerDelegate {

    override init() {
        super.init()

        title = "Custom stamp annotations"
        contentDescription = "Customizes the default set of stamps in the PSPDFStampViewController."
        category = .annotations
        priority = 200
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController? {
        var defaultStamps = [PSPDFStampAnnotation]()
        for stampTitle in ["Great!", "Stamp", "Like"] {
            let stamp = PSPDFStampAnnotation(title: stampTitle)
            stamp.boundingBox = CGRect(x: 0, y: 0, width: 200, height: 70)
            defaultStamps.append(stamp)
        }
        // Careful with memory - you don't wanna add large images here.
        let imageStamp = PSPDFStampAnnotation()
        imageStamp.image = UIImage(named: "exampleimage.jpg")
        imageStamp.boundingBox = CGRect(x: 0, y: 0, width: (imageStamp.image?.size.width)! / 4, height: (imageStamp.image?.size.height)! / 4)
        defaultStamps.append(imageStamp)

        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let logoURL = samplesURL.appendingPathComponent("PSPDFKit Logo.pdf")

        let vectorStamp = PSPDFStampAnnotation()
        vectorStamp.boundingBox = CGRect(x: 0, y: 0, width: 200, height: 200)
        vectorStamp.appearanceStreamGenerator = PSPDFFileAppearanceStreamGenerator(fileURL: logoURL)
        defaultStamps.append(vectorStamp)
        PSPDFStampViewController.defaultStampAnnotations = defaultStamps

        let document = PSCAssetLoader.document(withName: .JKHF)
        let pdfController = PSPDFViewController(document: document)
        pdfController.delegate = self
        pdfController.navigationItem.rightBarButtonItems = [pdfController.annotationButtonItem]

        // Add cleanup block so other examples will use the default stamps.
        pdfController.psc_addDeallocBlock {
            PSPDFStampViewController.defaultStampAnnotations = nil
        }
        return pdfController
    }

///////////////////////////////////////////////////////////////////////////////////////////
// MARK: - PSPDFViewControllerDelegate

    func pdfViewController(_ pdfController: PSPDFViewController, shouldShow controller: UIViewController, options: [String: Any]? = nil, animated: Bool) -> Bool {
        let stampController = PSPDFChildViewControllerForClass(controller, PSPDFStampViewController.self) as? PSPDFStampViewController
        stampController?.customStampEnabled = false
        stampController?.dateStampsEnabled = false

        return true
    }
}
