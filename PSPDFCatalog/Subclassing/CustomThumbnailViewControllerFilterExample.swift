//
//  Copyright © 2018-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import Foundation

extension PSPDFThumbnailViewFilter {
    static let inkAnnotations = PSPDFThumbnailViewFilter("Ink Annotations")
}

class CustomThumbnailViewController: PSPDFThumbnailViewController {
    override func pages(forFilter filter: PSPDFThumbnailViewFilter, groupingResultsBy groupSize: UInt, result resultHandler: @escaping (IndexSet) -> Void, completion: @escaping (Bool) -> Void) -> Progress? {
        // Only shows pages with ink annotations.
        if filter == .inkAnnotations {
            guard let pagesWithInkAnnotations = document?.allAnnotations(of: .ink).map({ $0.key.intValue }) else { return nil }

            var annotationIndexes: IndexSet = []
            pagesWithInkAnnotations.forEach { annotationIndexes.insert($0) }

            resultHandler(annotationIndexes)
            completion(true)
        }

        return super.pages(forFilter: filter, groupingResultsBy: groupSize, result: resultHandler, completion: completion)
    }
}

class CustomThumbnailViewControllerFilterExample: PSCExample {
    override init() {
        super.init()

        title = "Custom Thumbnail View Controller Filter"
        contentDescription = "Shows how to add a custom filter by sublassing PSPDFThumbnailViewController"
        category = .subclassing
        priority = 400
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        // Playground is convenient for testing
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let sourceURL = samplesURL.appendingPathComponent(PSCAssetName.quickStart.rawValue)
        let writeableURL = PSCCopyFileURLToDocumentFolderAndOverride(sourceURL, false)
        let document = PSPDFDocument(url: writeableURL)

        let configuration = PSPDFConfiguration { builder in
            // Register the override to use a custom search thumbnail view controller subclass.
            builder.overrideClass(PSPDFThumbnailViewController.self, with: CustomThumbnailViewController.self)
        }
        let controller = PSPDFViewController(document: document, configuration: configuration)
        controller.navigationItem.rightBarButtonItems = [controller.thumbnailsButtonItem]

        // Add the custom filter option.
        controller.thumbnailController.filterOptions = [.showAll, .bookmarks, .inkAnnotations]
        return controller
    }
}
