//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'PSCPlaygroundExample.m' for the Objective-C version of this example.

class CustomTabbedBarTitleExample: PSCExample {

    override init() {
        super.init()

        title = "Customize tab title for PSPDFTabbedViewController"
        contentDescription = "Shows how to customize the tab titles for PSPDFTabbedViewController."
        category = .viewCustomization
        priority = 70
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let tabbedController = CustomTitleTabbedViewController()
        tabbedController.documents = [PSCAssetLoader.document(withName: .quickStart)!, PSCAssetLoader.document(withName: .annualReport)!]
        return tabbedController
    }
}

class CustomTitleTabbedViewController: PSPDFTabbedViewController {
    override func titleForDocument(at idx: UInt) -> String {
        return String(format: "Custom Title for Document %lu", idx + 1)
    }
}
