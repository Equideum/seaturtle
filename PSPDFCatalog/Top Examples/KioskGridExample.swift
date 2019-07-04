//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'PSCKioskGridExample.m' for the Objective-C version of this example.

class KioskGridExample: PSCExample {

    override init() {
        super.init()

        title = "Kiosk Grid"
        contentDescription = "Displays all documents in the Samples directory."
        type = "com.pspdfkit.catalog.kiosk.swift"
        category = .top
        priority = 3
        wantsModalPresentation = true // Both PSCGridViewController and PSCAppDelegate want to be the delegate of the navigation controller, so use separate navigation controllers.
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController? {
        return PSCGridViewController()
    }
}
