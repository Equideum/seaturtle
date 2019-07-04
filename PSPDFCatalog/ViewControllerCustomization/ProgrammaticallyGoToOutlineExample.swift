//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import Foundation

class ProgrammaticallyGoToOutlineExample: PSCExample {
    override init() {
        super.init()

        title = "Programmatically Go to a Specific Outline."
        contentDescription = ""
        category = .controllerCustomization
        priority = .max
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let sourceURL = samplesURL.appendingPathComponent(PSCAssetName.quickStart.rawValue)
        let document = PSPDFDocument(url: sourceURL)
        let controller = PSPDFViewController(document: document)

        // Check that the PDF has an outline.
        guard let outline = document.outline else {
            return controller
        }

        guard let matchingOutline = matchingOutlineByTitle(outline: outline, title: "Swift 4") else {
            return controller
        }

        controller.setPageIndex(matchingOutline.pageIndex, animated: false)

        return controller
    }

    // Recursive function to find the matching outline element by title.
    private func matchingOutlineByTitle(outline: PSPDFOutlineElement, title: String) -> PSPDFOutlineElement! {

        // Return the passed outline if the title matches
        if outline.title == title {
            return outline
        }

        if let children = outline.children {
            // Loop through the outline's children to to find a matching outline
            for child in children {
                // Match found
                if let match = matchingOutlineByTitle(outline: child, title: title) {
                    return match
                }
            }
        }

        return nil
    }
}
