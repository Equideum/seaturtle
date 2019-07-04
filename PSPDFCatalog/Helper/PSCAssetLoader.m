//
//  Copyright © 2012-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCFileHelper.h"

NSString *const PSCAssetNameQuickStart = @"PSPDFKit 8 QuickStart Guide.pdf";
NSString *const PSCAssetNameAbout = @"About PSPDFKit.pdf";
NSString *const PSCAssetNameWeb = @"PSPDF Web.pdf";
NSString *const PSCAssetNameCaseStudyBox = @"Case Study Box.pdf";
NSString *const PSCAssetNameJKHF = @"JKHF - Annual Report.pdf";
NSString *const PSCAssetNameAnnualReport = @"Annual Report.pdf";

@implementation PSCAssetLoader

+ (NSURL *)assetURLWithName:(PSCAssetName)name {
    NSURL *samplesURL = [NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:@"Samples"];
    return [samplesURL URLByAppendingPathComponent:name];
}

+ (nullable PSPDFDocument *)documentWithName:(PSCAssetName)name {
    NSURL *URL = [self assetURLWithName:name];
    PSPDFDocument *document = [[PSPDFDocument alloc] initWithURL:URL];
    return document;
}

+ (nullable PSPDFDocument *)writableDocumentWithName:(PSCAssetName)name overrideIfExists:(BOOL)overrideIfExists {
    NSURL *URL = [self assetURLWithName:name];
    NSURL *writableURL = PSCCopyFileURLToDocumentFolderAndOverride(URL, overrideIfExists);
    PSPDFDocument *document = [[PSPDFDocument alloc] initWithURL:writableURL];
    document.annotationSaveMode = PSPDFAnnotationSaveModeEmbedded;
    return document;
}

+ (PSPDFDocument *)temporaryDocumentWithString:(PSCAssetName)string {
    NSMutableData *pdfData = [NSMutableData new];
    UIGraphicsBeginPDFContextToData(pdfData, CGRectMake(0.0, 0.0, 210.0 * 3, 297.0 * 3), @{});
    UIGraphicsBeginPDFPage();
    [string drawAtPoint:CGPointMake(20.0, 20.0) withAttributes:nil];
    UIGraphicsEndPDFContext();
    PSPDFDocument *document = [[PSPDFDocument alloc] initWithDataProviders:@[[[PSPDFDataContainerProvider alloc] initWithData:pdfData]]];
    document.title = string;
    return document;
}

@end
