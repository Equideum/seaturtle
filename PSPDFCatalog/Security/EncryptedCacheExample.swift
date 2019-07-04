//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'PSCEncryptedCacheExample.m' for the Objective-C version of this example.

import Foundation

class EncryptedCacheExample: PSCExample {

    override init() {
        super.init()
        title = "Enable PSPDFCache encryption"
        contentDescription = "Wrap cache access into an encryption layer."
        category = .security
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let cache = PSPDFKit.sharedInstance.cache
        // Clear existing cache
        cache.clear()

        // Set new cache directory so this example doesn't interfere with the other examples
        cache.diskCache.cacheDirectory = "PSPDFKit_encrypted"

        // In a real use case, you want to protect the password better than hard-coding it here.
        let password: String = "unsafe-testpassword"

        // Set up cache encryption handlers.
        // Encrypting the images will be a 5-10% slowdown, nothing substantial.
        var encryptedData: Data!
        cache.diskCache.encryptionHelper = {(_ request: PSPDFRenderRequest, _ data: Data) -> Data in
            do {
                encryptedData = try RNEncryptor.encryptData(data, with: kRNCryptorAES256Settings, password: password)
            } catch {
                print("Failed to encrypt: \(error.localizedDescription)")
            }
            return encryptedData
        }

        var decryptedData: Data!
        cache.diskCache.decryptionHelper = {(_ request: PSPDFRenderRequest, _ encryptedData: Data) -> Data in
            do {
                decryptedData = try RNDecryptor.decryptData(encryptedData, withPassword: password)
            } catch {
                print("Failed to decrypt: \(error.localizedDescription)")
            }
            return decryptedData
        }

        // Open sample document
        let document = PSCAssetLoader.document(withName: .JKHF)
        return PSPDFViewController(document: document)
    }
}
