//
//  Copyright © 2018-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import Foundation

class CustomBookmarkProviderExample: PSCExample {
    override init() {
        super.init()

        title = "Custom Bookmark Provider"
        contentDescription = "Shows how to use a custom bookmark provider using a plist file"
        category = .subclassing
        priority = 250
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let sourceURL = samplesURL.appendingPathComponent(PSCAssetName.JKHF.rawValue)
        let writeableURL = PSCCopyFileURLToDocumentFolderAndOverride(sourceURL, false)
        let document = PSPDFDocument(url: writeableURL)
        document.bookmarkManager?.provider = [BookmarkParser()]

        let configuration = PSPDFConfiguration { builder in
            builder.bookmarkSortOrder = .custom
        }
        let controller = PSPDFViewController(document: document, configuration: configuration)
        controller.navigationItem.setRightBarButtonItems([controller.thumbnailsButtonItem, controller.outlineButtonItem, controller.searchButtonItem, controller.bookmarkButtonItem], for: .document, animated: false)
        return controller
    }
}

class BookmarkParser: NSObject, PSPDFBookmarkProvider {
    struct CustomBookmark: Codable {
        let identifier: String
        let pageIndex: PageIndex
        let name: String
        let sortKey: Int

        private enum CodingKeys: String, CodingKey {
            case identifier
            case pageIndex
            case name
            case sortKey
        }

        init(bookmark: PSPDFBookmark) {
            self.identifier = bookmark.identifier
            self.pageIndex = bookmark.pageIndex
            self.name = bookmark.name?.replacingOccurrences(of: "\"", with: "'") ?? String()
            if let sortKey = bookmark.sortKey {
                self.sortKey = sortKey.intValue
            } else {
                self.sortKey = 0
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(identifier, forKey: .identifier)
            try container.encode(pageIndex, forKey: .pageIndex)
            try container.encode(name, forKey: .name)
            try container.encode(sortKey, forKey: .sortKey)
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            identifier = try values.decode(String.self, forKey: .identifier)
            pageIndex = try values.decode(PageIndex.self, forKey: .pageIndex)
            name = try values.decode(String.self, forKey: .name)
            sortKey = try values.decode(Int.self, forKey: .sortKey)
        }
    }

    var bookmarks: [PSPDFBookmark] {
        return self.bookmarkData
    }

    var bookmarkData: [PSPDFBookmark]

    override init() {
        self.bookmarkData = BookmarkParser.bookmarkDataFromFile()
        super.init()
    }

    func add(_ bookmark: PSPDFBookmark) -> Bool {
        print("Add Bookmark: \(bookmark)")
        let index = bookmarkData.firstIndex(of: bookmark)
        if index == nil || index == NSNotFound {
            bookmarkData.append(bookmark)
        } else {
            bookmarkData[index!] = bookmark
        }
        return true
    }

    func remove(_ bookmark: PSPDFBookmark) -> Bool {
        print("Remove Bookmark: \(bookmark)")
        if bookmarkData.contains(bookmark) {
            while let elementIndex = bookmarkData.firstIndex(of: bookmark) {
                bookmarkData.remove(at: elementIndex)
            }
            return true
        } else {
            return false
        }
    }

    func save() {
        print("Save bookmarks.")
        let customBookmarks = bookmarkData.map({ return CustomBookmark(bookmark: $0) })
        let jsonData = try? PropertyListEncoder().encode(customBookmarks)
        try? jsonData?.write(to: BookmarkParser.bookmarkURL()!, options: Data.WritingOptions.atomic)
    }

    // MARK: Helpers

    class func bookmarkURL() -> URL? {
        let applicationSupport = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = applicationSupport?.appendingPathComponent("customBookmarksProvider").appendingPathExtension("plist")
        return fileURL
    }

    class func bookmarkDataFromFile() -> [PSPDFBookmark] {
        var bookmarkData = [PSPDFBookmark]()

        guard let jsonData = try? Data(contentsOf: BookmarkParser.bookmarkURL()!) else {
            return bookmarkData
        }

        let customBookmark: [CustomBookmark] = try! PropertyListDecoder().decode(Array.self, from: jsonData)
        bookmarkData = customBookmark.map({
            let identifier = $0.identifier
            let pageIndex = $0.pageIndex
            let name = $0.name
            let sortKey = NSNumber(value: $0.sortKey)
            let action = PSPDFGoToAction(pageIndex: PageIndex(pageIndex))
            return PSPDFBookmark(identifier: identifier, action: action, name: name, sortKey: sortKey)
        })

        return bookmarkData
    }
}
