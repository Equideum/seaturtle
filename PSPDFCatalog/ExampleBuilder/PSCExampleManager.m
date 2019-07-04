//
//  Copyright © 2012-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCExampleManager.h"
#import <objc/runtime.h>

@interface PSCExampleManager ()
@property (nonatomic, copy) NSArray *allExamples;
@end

@implementation PSCExampleManager

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Static

+ (PSCExampleManager *)defaultManager {
    static PSCExampleManager *_manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [self.class new];
    });
    return _manager;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle

- (instancetype)init {
    if ((self = [super init])) {
        _allExamples = [self loadAllExamples];
    }
    return self;
}

- (NSArray *)loadAllExamples {
    // Get all subclasses and instantiate them.
    NSArray *exampleSubclasses = PSCGetAllExampleSubclasses();
    NSMutableArray *examples = [NSMutableArray array];
    PSCExampleTargetDeviceMask currentDevice = PSCIsIPad() ? PSCExampleTargetDeviceMaskPad : PSCExampleTargetDeviceMaskPhone;
    for (Class exampleObj in exampleSubclasses) {
        PSCExample *example = [exampleObj new];
        if ((example.targetDevice & currentDevice) > 0) {
            [examples addObject:example];
        }
    }

    // Sort all examples depending on category.
    [examples sortUsingComparator:^NSComparisonResult(PSCExample *example1, PSCExample *example2) {
        // sort via category
        if (example1.category < example2.category)
            return (NSComparisonResult)NSOrderedAscending;
        else if (example1.category > example2.category)
            return (NSComparisonResult)NSOrderedDescending;
        // then priority
        else if (example1.priority < example2.priority)
            return (NSComparisonResult)NSOrderedAscending;
        else if (example1.priority > example2.priority)
            return (NSComparisonResult)NSOrderedDescending;
        // then title
        else
            return [example1.title compare:example2.title];
    }];

    // Sets the `isAnotherLanguageCounterPartExampleAvailable` flag of an example
    for (PSCExample *example in examples) {
        if (example.isCounterpartExampleAvailable) {
            continue;
        }

        // We are using the title as a unique identifier for an example showing a particular thing.
        // That is we are assuming that an example written in both Objective-C and Swift has the same title.
        // We need to make sure that even the new examples created in both languages do the follow the rule of having the same titles.
        NSArray<PSCExample *> *counterpartExamples = [examples filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K = %@", @"title", example.title]];

        if (counterpartExamples.count > 1) {
            example.isCounterpartExampleAvailable = YES;
            counterpartExamples.lastObject.isCounterpartExampleAvailable = YES;
        } else {
            example.isCounterpartExampleAvailable = NO;
        }
    }

    return examples;
}

- (NSArray<PSCExample *> *)examplesForPreferredLanguage:(PSCCatalogExampleLanguage)preferredLanguage {
    NSMutableArray<PSCExample *> *examples = [NSMutableArray array];

    for (PSCExample *example in self.allExamples) {
        PSCCatalogExampleLanguage exampleLanguage = example.isSwift ? PSCCatalogExampleLanguageSwift : PSCCatalogExampleLanguageObjectiveC;
        if (exampleLanguage == preferredLanguage || !example.isCounterpartExampleAvailable) {
            [examples addObject:example];
        }
    }
    return [NSArray arrayWithArray:examples];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Annotation Type runtime builder

// Do not use -[NSObject isSubclassOfClass:] in order to avoid calling +initialize on all classes.
NS_INLINE BOOL PSCIsSubclassOfClass(Class subclass, Class superclass) {
    for (Class class = class_getSuperclass(subclass); class != Nil; class = class_getSuperclass(class)) {
        if (class == superclass) return YES;
    }
    return NO;
}

static NSArray *PSCGetAllExampleSubclasses(void) {
    NSMutableArray *annotations = [NSMutableArray array];
    unsigned int count = 0;
    Class *classList = objc_copyClassList(&count);
    dispatch_queue_t queue = dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0);
    dispatch_apply(count, queue, ^(size_t idx) {
        __unsafe_unretained Class class = classList[idx];
        if (PSCIsSubclassOfClass(class, PSCExample.class)) {
            @synchronized(PSCExampleManager.class) {
                [annotations addObject:class];
            }
        }
    });
    free(classList);
    return annotations;
}

@end
