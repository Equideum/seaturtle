//
//  UpdateConfigurationWhenRotatingExample.swift
//  PSPDFCatalog
//
//  Copyright © 2018-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import Foundation

class UpdateConfigurationWhenRotatingExample: PSCExample {

    private weak var pdfController: PSPDFViewController?

    override init() {
        super.init()

        title = "Changing Configuration when Rotating Device"
        contentDescription = "Illustrates how to update the configuration when rotating the device"
        category = .controllerCustomization
        priority = 50
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController? {
        let document = PSCAssetLoader.document(withName: .annualReport)!

        let configuration = PSPDFConfiguration { builder in
            builder.isFirstPageAlwaysSingle = false
            builder.pageMode = .single
        }

        let pdfController = PSPDFViewController(document: document, configuration: configuration)
        pdfController.setUpdateSettingsForBoundsChange { [weak self] _ in
            self?.updateConfigurationOnRotation()
        }
        self.pdfController = pdfController
        return pdfController
    }

    func updateConfigurationOnRotation() {
        let pdfController = self.pdfController

        pdfController?.updateConfiguration { (builder) in
            if pdfController?.configuration.pageMode == .single {
                builder.pageMode = .double
                builder.pageTransition = .scrollPerSpread
            } else if pdfController?.configuration.pageMode == .double {
                builder.pageMode = .single
                builder.pageTransition = .scrollContinuous
            }
        }
    }
}
