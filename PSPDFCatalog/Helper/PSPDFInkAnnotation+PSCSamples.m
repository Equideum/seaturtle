//
//  Copyright © 2013-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSPDFInkAnnotation+PSCSamples.h"

@implementation PSPDFInkAnnotation (PSCSamples)

+ (instancetype)psc_sampleInkAnnotationInRect:(CGRect)rect {
    PSPDFInkAnnotation *ink = [PSPDFInkAnnotation new];
    NSArray *lines = @[
        // first line
        @[@(CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect))), @(CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect))), @(CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect)))],
        // second line
        @[@(CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect))), @(CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect))), @(CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect)))],
    ];
    ink.lineWidth = 5;
    ink.lines = lines;
    return ink;
}

@end
