//
//  Copyright © 2014-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import Foundation
import PSPDFKit

class LibraryExample {

    func indexDocuments() {
        guard let library = PSPDFKit.sharedInstance.library else { return }
        let filesURL = Bundle.main.bundleURL.appendingPathComponent("Samples")

        let dataSource = PSPDFLibraryFileSystemDataSource(library: library, documentsDirectoryURL: filesURL)
        library.dataSource = dataSource
        library.updateIndex()

        // Indexing is async, we could use notifications to track the state,
        // but for this example it's easy enought to just delay this for a second.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            library.documentUIDs(matching: "pdf", options: nil, completionHandler: { searchString, resultSet -> Void in
                print("For \(searchString) found \(resultSet)")
            }, previewTextHandler: nil)
        }
    }
}
