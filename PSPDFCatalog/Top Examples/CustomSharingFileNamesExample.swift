//
//  Copyright © 2016-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import Foundation

class CustomSharingFileNamesExample: PSCExample {

    // MARK: PSCExample

    override init() {
        super.init()

        title = "Customize the Sharing Experience"
        contentDescription = "Changes the file name on shared files and adds more sharing options."
        category = .top
        priority = 900
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let document = PSCAssetLoader.document(withName: .web)

        let sharingConfiguration = PSPDFDocumentSharingConfiguration.defaultConfiguration(forDestination: .activity).configurationUpdated {
            $0.annotationOptions = [.embed, .flatten, .remove]
            $0.pageSelectionOptions = [.current]
            $0.excludedActivityTypes = [.assignToContact, .postToWeibo, .postToFacebook, .postToTwitter]
        }

        let configuration = PSPDFConfiguration { builder in
            builder.sharingConfigurations = [sharingConfiguration]
        }

        let controller = PSPDFViewController(document: document, configuration: configuration)
        controller.delegate = self
        controller.navigationItem.rightBarButtonItems = [controller.activityButtonItem]
        return controller
    }
}

extension CustomSharingFileNamesExample: PSPDFViewControllerDelegate {
    func pdfViewController(_ pdfController: PSPDFViewController, didShow controller: UIViewController, options: [String: Any]? = nil, animated: Bool) {
        guard let controller = controller as? PSPDFDocumentSharingViewController else { return }
        controller.delegate = self
    }
}

extension CustomSharingFileNamesExample: PSPDFDocumentSharingViewControllerDelegate {
    func documentSharingViewController(_ shareController: PSPDFDocumentSharingViewController, filenameForGeneratedFileFor sharingDocument: PSPDFDocument, destination: PSPDFDocumentSharingDestination) -> String? {
        return "NewName"
    }
}
