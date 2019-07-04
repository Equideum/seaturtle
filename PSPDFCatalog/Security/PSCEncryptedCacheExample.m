//
//  Copyright © 2012-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'EncryptedCacheExample.swift' for the Swift version of this example.

#import "PSCAssetLoader.h"
#import "PSCExample.h"

// Crypto support
#import "RNDecryptor.h"
#import "RNEncryptor.h"

@interface PSCEncryptedCacheExample : PSCExample
@end

@implementation PSCEncryptedCacheExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Enable PSPDFCache encryption";
        self.contentDescription = @"Wrap cache access into an encryption layer.";
        self.category = PSCExampleCategorySecurity;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFCache *cache = PSPDFKit.sharedInstance.cache;

    // Clear existing cache
    [cache clearCache];

    // Set new cache directory so this example doesn't interfere with the other examples
    cache.diskCache.cacheDirectory = @"PSPDFKit_encrypted";

    // In a real use case, you want to protect the password better than hard-coding it here.
    NSString *password = @"unsafe-testpassword";

    // Set up cache encryption handlers.
    // Encrypting the images will be a 5-10% slowdown, nothing substantial.
    [cache.diskCache setEncryptionHelper:^NSData *_Nullable(PSPDFRenderRequest *request, NSData *data) {
        NSError *error;
        NSData *encryptedData = [RNEncryptor encryptData:data withSettings:kRNCryptorAES256Settings password:password error:&error];
        if (!encryptedData) {
            NSLog(@"Failed to encrypt: %@", error.localizedDescription);
        }
        return encryptedData;
    }];
    [cache.diskCache setDecryptionHelper:^NSData *_Nullable(PSPDFRenderRequest *request, NSData *encryptedData) {
        NSError *error;
        NSData *decryptedData = [RNDecryptor decryptData:encryptedData withPassword:password error:&error];
        if (!decryptedData) {
            NSLog(@"Failed to decrypt: %@", error.localizedDescription);
        }
        return decryptedData;
    }];

    // Open sample document
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    PSPDFViewController *controller = [[PSPDFViewController alloc] initWithDocument:document];
    return controller;
}

@end
