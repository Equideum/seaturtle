//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'PSCCreateNoteFromTextSelectionExample.m' for the Objective-C version of this example.

class CreateNoteFromTextSelectionExample: PSCExample, PSPDFViewControllerDelegate {

    override init() {
        super.init()

        title = "Create Note from selected text"
        contentDescription = "Adds a new menu item that will create a note at the selected position with the text contents."
        category = .annotations
        priority = 60
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController? {
        let document = PSCAssetLoader.document(withName: .JKHF)
        document!.annotationSaveMode = .disabled

        let pdfController = PSPDFViewController(document: document)
        pdfController.delegate = self
        return pdfController
    }

    func pdfViewController(_ pdfController: PSPDFViewController, shouldShow menuItems: [PSPDFMenuItem], atSuggestedTargetRect rect: CGRect, forSelectedText selectedText: String, in textRect: CGRect, on pageView: PSPDFPageView) -> [PSPDFMenuItem] {
        if !selectedText.isEmpty {
            let createNoteMenu = PSPDFMenuItem(title: "Create Note") {
                PSPDFUsernameHelper.ask(forDefaultAnnotationUsernameIfNeeded: pdfController) { _ in
                    let noteAnnotation = PSPDFNoteAnnotation()
                    noteAnnotation.pageIndex = pdfController.pageIndex
                    noteAnnotation.boundingBox = CGRect(x: textRect.maxX, y: textRect.origin.y, width: 32, height: 32)
                    noteAnnotation.contents = selectedText
                    pageView.presentationContext?.document?.add([noteAnnotation])
                    pageView.selectionView.discardSelection(animated: false)
                    pageView.showNoteController(for: noteAnnotation, animated: true)
                }
            }
            return menuItems + [createNoteMenu]
        }
        return menuItems
    }
}
