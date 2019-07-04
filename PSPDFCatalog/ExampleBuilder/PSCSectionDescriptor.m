//
//  Copyright © 2012-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCSectionDescriptor.h"

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCSectionDescriptor

@implementation PSCSectionDescriptor {
    NSMutableArray<PSCContent *> *_contentDescriptors;
}

+ (instancetype)sectionWithTitle:(NSString *)title footer:(NSString *)footer {
    return [[self alloc] initWithTitle:title footer:footer];
}

- (instancetype)initWithTitle:(NSString *)title footer:(NSString *)footer {
    if ((self = [super init])) {
        _title = [title copy];
        _footer = [footer copy];
        _contentDescriptors = [NSMutableArray new];
        _isCollapsed = YES;
    }
    return self;
}

- (void)setContentDescriptors:(NSArray<PSCContent *> *)contentDescriptors {
    _contentDescriptors = [contentDescriptors mutableCopy];
}

- (void)addContent:(PSCContent *)contentDescriptor {
    [_contentDescriptors addObject:contentDescriptor];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p title:%@ footer:%@ content:%@>", self.class, (void *)self, self.title, self.footer, self.contentDescriptors];
}

@end
