//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'PSCStampButtonExample.m' for the Objective-C version of this example.

import PSPDFKitSwift

class StampButtonExample: PSCExample, PSPDFViewControllerDelegate {

    override init() {
        super.init()

        title = "Stamp Annotation Button"
        contentDescription = "Uses a stamp annotation as button."
        category = .annotations
        priority = 130
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController? {
        let document = PSCAssetLoader.document(withName: .JKHF)
        document?.annotationSaveMode = .disabled

        let imageStamp = PSPDFStampAnnotation()
        imageStamp.image = UIImage(named: "exampleimage.jpg")
        imageStamp.boundingBox = CGRect(x: 100.0, y: 100.0, width: imageStamp.image!.size.width / 4.0, height: imageStamp.image!.size.height / 4.0)

        imageStamp.pageIndex = 0

        // We need to define an action to get a highlight.
        // You can also use an empty script and do custom processing in the didTapOnAnnotation: delegate.
        imageStamp.additionalActionDict = [PSPDFAnnotationTriggerEvent.mouseUp: PSPDFJavaScriptAction(script: "app.alert(\"Hello, it's me. I was wondering...\");")]

        document?.add([imageStamp])
        let pdfController = PSPDFViewController(document: document)
        pdfController.delegate = self
        return pdfController
    }

///////////////////////////////////////////////////////////////////////////////////////////
// MARK: - PSPDFViewControllerDelegate

    private func pdfViewController(_: PSPDFViewController, didTapOn annotation: PSPDFAnnotation, annotationPoint: CGPoint, annotationView: PSPDFAnnotationPresenting, pageView: PSPDFPageView, viewPoint: CGPoint) -> Bool {
        return false
    }
}
