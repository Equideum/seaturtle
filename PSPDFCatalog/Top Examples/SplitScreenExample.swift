//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'PSCSplitScreenExample.m' for the Objective-C version of this example.

class SplitScreenExample: PSCExample {

    override init() {
        super.init()

        title = "Split-screen interface"
        contentDescription = "Uses a split-screen interface with a floating toolbar."
        category = .top
        priority = 9
        wantsModalPresentation = true
        embedModalInNavigationController = false
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController? {
        return PSCSplitViewController()
    }
}
