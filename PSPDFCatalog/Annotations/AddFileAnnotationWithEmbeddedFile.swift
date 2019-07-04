//
//  Copyright © 2018-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import Foundation
import PSPDFKit
import PSPDFKitUI

class AddFileAnnotationWithEmbeddedFile: PSCExample, PSPDFViewControllerDelegate, PSPDFDocumentPickerControllerDelegate {

    var pdfController: PSPDFViewController?
    var documentPickerController: PSPDFDocumentPickerController?
    var longPressedPoint: CGPoint?

    override init() {
        super.init()

        title = "Add and remove file annotations with embedded files from a custom menu item"
        contentDescription = "Adds new menu items that will create and delete file annotations at the selected position."
        category = .annotations
        priority = 65
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let sourceURL = samplesURL.appendingPathComponent(PSCAssetName.quickStart.rawValue)
        let writeableURL = PSCCopyFileURLToDocumentFolderAndOverride(sourceURL, false)
        let document = PSPDFDocument(url: writeableURL)

        documentPickerController = PSPDFDocumentPickerController(directory: "/Bundle/Samples", includeSubdirectories: true, library: PSPDFKit.sharedInstance.library)
        documentPickerController?.delegate = self

        pdfController = PSPDFViewController(document: document)
        pdfController?.delegate = self
        return pdfController!
    }

    // MARK: - PSPDFViewControllerDelegate

    func pdfViewController(_ pdfController: PSPDFViewController, shouldShow menuItems: [PSPDFMenuItem], atSuggestedTargetRect rect: CGRect, for annotations: [PSPDFAnnotation]?, in annotationRect: CGRect, on pageView: PSPDFPageView) -> [PSPDFMenuItem] {
        var allMenuItems: [PSPDFMenuItem] = menuItems
        // Long pressed on the page view.
        if annotations == nil {
            let attachFileMenuItem = PSPDFMenuItem(title: PSPDFLocalize("Attach File")) {
                // Store the long pressed point in PDF coordinates to be used to set the bounding box of the newly created file annotation.
                self.longPressedPoint = pageView.convert(rect, to: pageView.pdfCoordinateSpace).origin
                // Present the document picker.
                self.pdfController?.present(self.documentPickerController!, options: [PSPDFPresentationCloseButtonKey: true], animated: true, sender: nil, completion: nil)
            }
            // Add the new menu item to be the first (rightmost) item.
            allMenuItems.insert(attachFileMenuItem, at: 0)
        } else { // Tapped on one or more annotations.
            let fileAnnotations = annotations?.compactMap { $0 as? PSPDFFileAnnotation }
            // If one of the selected annotations is a file annotation, so we add the delete menu item to delete all selected annotations.
            if fileAnnotations?.isEmpty == false {
                let title = PSPDFLocalize("Delete Attachment")
                let deleteFileMenuItem = PSPDFMenuItem(title: PSPDFLocalize("Delete Attachment"), image: PSPDFKit.imageNamed("trash"), block: {
                    // Only remove selected annotations.
                    pdfController.document?.remove(annotations: annotations!)
                }, identifier: title)
                // Add the new menu item last, to be the leftmost item.
                allMenuItems.append(deleteFileMenuItem)
            }
        }
        return allMenuItems
    }

    // MARK: - PSPDFDocumentPickerControllerDelegate

    func documentPickerController(_ controller: PSPDFDocumentPickerController, didSelect document: PSPDFDocument, pageIndex: PageIndex, search searchString: String?) {
        let fileURL = document.fileURL
        let fileDescription = document.fileURL?.lastPathComponent

        // Create the file annotation and its embedded file
        let fileAnnotation = PSPDFFileAnnotation()
        fileAnnotation.pageIndex = pageIndex
        fileAnnotation.boundingBox = CGRect(x: (self.longPressedPoint?.x)!, y: (self.longPressedPoint?.y)!, width: 32, height: 32)
        let embeddedFile = PSPDFEmbeddedFile(fileURL: fileURL!, fileDescription: fileDescription)
        fileAnnotation.embeddedFile = embeddedFile

        // Add the embedded file to the document.
        pdfController?.document?.add([fileAnnotation])

        // Dismiss the document picker.
        controller.dismiss(animated: true, completion: nil)
    }
}
