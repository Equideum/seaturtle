//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import PSPDFKit

class SettingsExample: PSCExample {

    override init() {
        super.init()

        self.title = "Settings"
        self.contentDescription = "Use PSPDFSettingsViewController to customize key UX elements."
        self.type = "com.pspdfkit.catalog.default"
        self.category = .top
        self.priority = 20
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        PSPDFKit.sharedInstance[.debugModeKey] = true

        let document = PSCAssetLoader.document(withName: .quickStart)
        let configuration = PSPDFConfiguration { builder in
            builder.settingsOptions = .all
        }
        let controller = PSPDFViewController(document: document, configuration: configuration)

        controller.navigationItem.rightBarButtonItems = [controller.thumbnailsButtonItem, controller.settingsButtonItem]

        return controller
    }
}
