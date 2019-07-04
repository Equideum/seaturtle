//
//  Copyright © 2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

class CustomSearchResultCellExample: PSCExample {

    override init() {
        super.init()

        title = "Custom Search Result Cell"
        contentDescription = "Shows how to customize the table view cell for PSPDFSearchViewController."
        category = .viewCustomization
        priority = 60
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let document = PSCAssetLoader.writableDocument(withName: .quickStart, overrideIfExists: false)

        let configuration = PSPDFConfiguration { builder in
            builder.overrideClass(PSPDFSearchViewController.self, with: CustomSearchViewController.self)
        }

        let controller = PSPDFViewController(document: document, configuration: configuration)
        return controller
    }
}

class CustomSearchResultTableViewCell: UITableViewCell, PSPDFSearchResultViewable {
    func configure(with searchResult: PSPDFSearchResult) {
        // Custiomize the cell.
        textLabel?.text = searchResult.previewText
        textLabel?.textColor = UIColor.green
        textLabel?.numberOfLines = 0
        textLabel?.adjustsFontForContentSizeCategory = true

        let document = searchResult.document
        let pageIndex = searchResult.pageIndex
        let size = CGSize(width: 32, height: 32)
        imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        imageView?.image = try! document?.imageForPage(at: pageIndex, size: size, clippedTo: CGRect.zero, annotations: nil, options: nil)
    }
}

class CustomSearchViewController: PSPDFSearchViewController {
    override class func resultCellClass() -> (PSPDFSearchResultViewable.Type) {
        return CustomSearchResultTableViewCell.self
    }
}
