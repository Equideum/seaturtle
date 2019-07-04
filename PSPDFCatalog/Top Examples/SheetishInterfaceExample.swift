//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'PSCSheetishInterfaceExample.m' for the Objective-C version of this example.

class SheetishInterfaceExample: PSCExample {

    override init() {
        super.init()

        title = "Sheet-ish interface"
        contentDescription = "Uses a vanilla PSPDFViewController presented in a popover presentation controller."
        category = .top
        priority = 10
        wantsModalPresentation = true
        customizations = { container in
            container.modalPresentationStyle = .popover
            container.popoverPresentationController?.permittedArrowDirections = .up
        }
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController? {
        let document = PSCAssetLoader.document(withName: .JKHF)
        let controller = PSPDFViewController(document: document)
        controller.preferredContentSize = CGSize(width: 640, height: 480)
        return controller
    }
}
