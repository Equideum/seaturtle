//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import Foundation
import PSPDFKit
import PSPDFKitUI

class MirrorablePDFViewController: PSPDFViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PSPDFKit.sharedInstance.screenController.pdfControllerToMirror = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        PSPDFKit.sharedInstance.screenController.pdfControllerToMirror = nil
    }
}

class ScreenMirroringExample: PSCExample {

    // MARK: PSCExample

    override init() {
        super.init()
        title = "Screen Mirroring Customization Example"
        contentDescription = "Shows how to add your own view controller for screen mirroring."
        category = .viewCustomization
        priority = 10
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {

        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let sourceURL = samplesURL.appendingPathComponent(PSCAssetName.quickStart.rawValue)
        let document = PSPDFDocument(url: sourceURL)

        let configuration = PSPDFConfiguration { builder in
            builder.pageTransition = .scrollPerSpread
        }
        let pdfController = MirrorablePDFViewController(document: document, configuration: configuration)

        // We do additional config in the delegate
        PSPDFKit.sharedInstance.screenController.delegate = self

        return pdfController
    }
}

extension ScreenMirroringExample: PSPDFScreenControllerDelegate {

    func createPDFViewController(forMirroring screenController: PSPDFScreenController) -> PSPDFViewController {

        let configuration = PSPDFConfiguration { builder in
            builder.pageMode = .automatic
            builder.thumbnailBarMode = .none
            builder.documentLabelEnabled = .NO
            builder.isPageLabelEnabled = false

            // Only per page scrolling is supported
            builder.pageTransition = .scrollPerSpread

            builder.galleryConfiguration = PSPDFGalleryConfiguration { (builder) in
                builder.allowPlayingMultipleInstances = true
                builder.usesExternalPlaybackWhileExternalScreenIsActive = false
            }
        }
        let pdfController = PSPDFViewController(document: screenController.pdfControllerToMirror?.document, configuration: configuration)
        return pdfController
    }

    func screenController(_ screenController: PSPDFScreenController, didStartMirroringFor screen: UIScreen) {
        guard let pdfController = screenController.mirrorController(for: screen),
        let window = pdfController.view.window else { return }

        // We change the root view controller to something else after mirroring started.
        let hostController = UIViewController()
        hostController.view.backgroundColor = UIColor.orange
        window.rootViewController = hostController

        // Re-add pdf controller and set up positioning
        hostController.addChild(pdfController)
        pdfController.view.translatesAutoresizingMaskIntoConstraints = false
        hostController.view.addSubview(pdfController.view)
        pdfController.didMove(toParent: hostController)

        NSLayoutConstraint.activate([
            // Thumbnail Container
            pdfController.view.topAnchor.constraint(equalTo: hostController.view.topAnchor, constant: 20),
            pdfController.view.bottomAnchor.constraint(equalTo: hostController.view.bottomAnchor, constant: -20),
            pdfController.view.leadingAnchor.constraint(equalTo: hostController.view.leadingAnchor, constant: 20),
            pdfController.view.trailingAnchor.constraint(equalTo: hostController.view.trailingAnchor, constant: -20),
            ])
    }
}
