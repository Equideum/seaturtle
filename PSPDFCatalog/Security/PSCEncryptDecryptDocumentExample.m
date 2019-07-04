//
//  PSCEncryptDecryptDocumentExample.m
//  PSPDFCatalog
//
// Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'EncryptDecryptDocumentExample.swift' for the Swift version of this example.

#import "PSCAssetLoader.h"
#import "PSCExample.h"
#import "PSCFileHelper.h"

@interface PSCEncryptDecryptDocumentExample : PSCExample
@end

@implementation PSCEncryptDecryptDocumentExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Encrypt and decrypt a PDF";
        self.contentDescription = @"Example how to encrypt and decrypt PDF.";
        self.category = PSCExampleCategorySecurity;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    NSURL *samplesURL = [NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:@"Samples"];
    NSURL *originalURL = [samplesURL URLByAppendingPathComponent:PSCAssetNameJKHF];

    PSPDFCryptor *cryptor = [[PSPDFCryptor alloc] init];
    NSData *key = [cryptor keyFromPassphrase:@"passphrase" salt:@"salt"];

    // Encrypt the original PDF
    NSURL *encryptedURL = PSCTempFileURLWithPathExtension(@"encrypted", @"pdf");
    NSError *encryptError;
    if (![cryptor encryptFromURL:originalURL toURL:encryptedURL key:key error:&encryptError]) {
        NSLog(@"Encryption failed with error: %@", encryptError.localizedDescription);
        return nil;
    }

    // Decrypt the encrypted PDF
    NSURL *decryptedURL = PSCTempFileURLWithPathExtension(@"PSPDFCryptorTests", @"pdf");
    NSError *decryptError;
    if (![cryptor decryptFromURL:encryptedURL toURL:decryptedURL key:key error:&decryptError]) {
        NSLog(@"Decrypton failed with error: %@", decryptError.localizedDescription);
        return nil;
    }

    // Open the decrypted PDF
    PSPDFDocument *document = [[PSPDFDocument alloc] initWithURL:decryptedURL];
    PSPDFViewController *controller = [[PSPDFViewController alloc] initWithDocument:document];
    return controller;
}

@end
