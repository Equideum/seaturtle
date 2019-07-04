//
//  Copyright © 2012-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCExample.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PSCCatalogExampleLanguage) {
    PSCCatalogExampleLanguageSwift,
    PSCCatalogExampleLanguageObjectiveC
};

// Manages all examples (all subclasses of `PSCExample`).
@interface PSCExampleManager : NSObject

// Singleton
+ (PSCExampleManager *)defaultManager;

// Get all examples.
@property (nonatomic, copy, readonly) NSArray<PSCExample *> *allExamples;

// Returns the example based on the preferred language. If an example doesn't exist in the selected language then the example in the other language is returned.
- (NSArray<PSCExample *> *)examplesForPreferredLanguage:(PSCCatalogExampleLanguage)preferredLanguage;

@end

NS_ASSUME_NONNULL_END
