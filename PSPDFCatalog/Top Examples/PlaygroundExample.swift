//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'PSCPlaygroundExample.m' for the Objective-C version of this example.

class PlaygroundExample: PSCExample {

    override init() {
        super.init()

        title = "PSPDFViewController Playground"
        contentDescription = "Start here"
        type = "com.pspdfkit.catalog.playground.swift"
        category = .top
        priority = 1
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        // Playground is convenient for testing
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let sourceURL = samplesURL.appendingPathComponent(PSCAssetName.quickStart.rawValue)
        let writeableURL = PSCCopyFileURLToDocumentFolderAndOverride(sourceURL, false)
        let document = PSPDFDocument(url: writeableURL)

        let configuration = PSPDFConfiguration { builder in
            // Use the configuration to set main PSPDFKit options.
            builder.pageTransition = .scrollPerSpread
        }

        let controller = PSCKioskPDFViewController(document: document, configuration: configuration)
        return controller
    }
}
