//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import Foundation

private class CustomPageLabelFormatter: PSPDFPageLabelFormatter {
    override func string(from pageRange: NSRange) -> String {
        return "Custom Page Label: \(pageRange.location + 1)"
    }
}

class CustomPageLabelExample: PSCExample {
    override init() {
        super.init()

        title = "Custom Page Label Example"
        contentDescription = "Shows how to customize page labels."
        category = .viewCustomization
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let document = PSCAssetLoader.document(withName: .annualReport)
        let configuration = PSPDFConfiguration { builder in
            builder.pageMode = .single
        }
        let controller = PSPDFViewController(document: document, configuration: configuration)

        // Set the custom label formatter
        controller.userInterfaceView.pageLabel.labelFormatter = CustomPageLabelFormatter()
        return controller
    }
}
