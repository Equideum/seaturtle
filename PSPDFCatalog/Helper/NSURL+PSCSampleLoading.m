//
//  Copyright © 2014-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "NSURL+PSCSampleLoading.h"

@implementation NSURL (PSCSampleLoading)

+ (NSURL *)psc_sampleURLWithName:(NSString *)name {
    NSParameterAssert(name);
    NSURL *samplesURL = [NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:@"Samples"];
    return (NSURL *)[samplesURL URLByAppendingPathComponent:name];
}

@end
