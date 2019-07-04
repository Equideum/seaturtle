//
//  Copyright © 2016-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import Foundation
import PSPDFKit
import PSPDFKitUI
import PSPDFKitSwift

class FormHighlightExample: PSCExample {

    private weak var pdfController: PSPDFViewController?

    // MARK: PSCExample

    override init() {
        super.init()
        title = "Custom Form Highlight Color"
        contentDescription = "Shows how to toggle the form highlight color."
        category = .viewCustomization
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let document = PSCAssetLoader.document(withName: PSCAssetName(rawValue: "Form_example.pdf"))!
        // Start by not highlighting forms.
        document.updateRenderOptions([.interactiveFormFillColor(UIColor.clear)], type: .all)

        let image = PSPDFKit.imageNamed("highlight.png")!
        let toggleButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(toggleHighlight))

        let pdfController = PSPDFViewController(document: document)
        pdfController.navigationItem.rightBarButtonItems = [toggleButton]
        self.pdfController = pdfController
        return pdfController
    }

    // MARK: Actions

    @objc func toggleHighlight() {
        guard let pdfController = self.pdfController else { return }
        guard let document = pdfController.document else { return }

        // Toggle between highlighted forms and clear forms.
        let currentColor = document.renderOptionsTyped(for: .page, context: nil).interactiveFormFillColor!
        if currentColor == UIColor.clear {
            let highlightColor = UIColor.pspdf().withAlphaComponent(0.2)
            document.updateRenderOptions([.interactiveFormFillColor(highlightColor)], type: .page)
        } else {
            document.updateRenderOptions([.interactiveFormFillColor(UIColor.clear)], type: .page)
        }

        pdfController.reloadData()
    }
}
