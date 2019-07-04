//
//  Copyright © 2011-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#define PSCMagazineJSONURL @"https://pspdfkit.com/magazines.json"

@class PSCMagazine;

NS_ASSUME_NONNULL_BEGIN

@interface PSCMagazineFolder : NSObject

+ (PSCMagazineFolder *)folderWithTitle:(NSString *)title;

// Array of `PSPDFMagazine` objects.
@property (nonatomic, copy) NSArray<PSCMagazine *> *magazines;

// The folder title.
@property (nonatomic, readonly) NSString *title;

@property (nonatomic, getter=isSingleMagazine, readonly) BOOL singleMagazine;

// Override to change sorting.
- (void)sortMagazines;

@property (nonatomic, readonly, nullable) PSCMagazine *firstMagazine;
- (void)addMagazine:(PSCMagazine *)magazine;
- (void)removeMagazine:(PSCMagazine *)magazine;

// Compare.
- (BOOL)isEqualToMagazineFolder:(PSCMagazineFolder *)otherMagazineFolder;

@end

NS_ASSUME_NONNULL_END
