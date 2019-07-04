//
//  Copyright © 2016-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import <Foundation/Foundation.h>

@class PSCMagazine;

NS_ASSUME_NONNULL_BEGIN

@interface PSCImageGridViewLoader : NSObject <PSPDFPageCellImageLoading>

@property (nonatomic, nullable) PSCMagazine *magazine;

@end

NS_ASSUME_NONNULL_END
