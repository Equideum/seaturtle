//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCStickyHeaderViewController : PSPDFViewController
@end

@interface PSCStickyHeaderExample : PSCExample
@end
@implementation PSCStickyHeaderExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Sticky Thumbnail Header";
        self.contentDescription = @"Shows setup of the sticky and customized header in thumbnail mode";
        self.category = PSCExampleCategorySubclassing;
        self.priority = 10;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    return [[PSCStickyHeaderViewController alloc] initWithDocument:document];
}

@end

@implementation PSCStickyHeaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // First, enable the sticky header:
    UICollectionViewLayout *layout = self.thumbnailController.collectionViewLayout;
    if ([layout isKindOfClass:PSPDFThumbnailFlowLayout.class]) {
        ((PSPDFThumbnailFlowLayout *)layout).stickyHeaderEnabled = YES;
    }
}

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // By default, the header view does not have a visible background.
        // This looks good when it scrolls along with the page thumbnails, but it looks terrible if you use the sticky header.
        // Because we only want to customize the header in this example, leaving the other samples untouched, we use `+appearanceWhenContainedIn:`.
        // In a typical app you would probably just use `+appearance`.
        PSPDFCollectionReusableFilterView *headerAppearance = [PSPDFCollectionReusableFilterView appearanceWhenContainedInInstancesOfClasses:@[self]];

        // For this app, a dark translucent background looks good.
        headerAppearance.backgroundStyle = PSPDFCollectionReusableFilterViewStyleDarkBlur;
        // If that’s visually just “too much” for your app, you can tone it down by simply setting a background color instead:
        //    headerAppearance.backgroundColor = UIColor.darkTextColor;

        // The filterElement is centered inside the header, but we could apply an offset if we wanted to:
        //    headerAppearance.filterElementOffset = CGPointMake(0, 200);
        // Well that would obviously be silly!
        // If you comment the above line in, note that the filter does not extend beyound the header’s bounds.
        // In fact, there even is a minimum margin.

        // Let’s say we want that minimum margin to be 0 in X and two times the default in Y, so that the filterSegment shrinks noticably:
        UIEdgeInsets filterMargin = UIEdgeInsetsZero;
        filterMargin.bottom = filterMargin.top = 2 * PSPDFCollectionReusableFilterViewDefaultMargin;
        headerAppearance.minimumFilterMargin = filterMargin;

        // And of course, we can also style the segmented control:
        UISegmentedControl *filterAppearance = [UISegmentedControl appearanceWhenContainedInInstancesOfClasses:@[PSPDFCollectionReusableFilterView.class, self]];
        NSDictionary *customFontAttributes = @{ NSFontAttributeName: (UIFont *)[UIFont fontWithName:@"Avenir" size:12] };
        NSDictionary *customBoldFontAttributes = @{ NSFontAttributeName: (UIFont *)[UIFont fontWithName:@"Avenir-Black" size:12] };
        [filterAppearance setTitleTextAttributes:customFontAttributes forState:UIControlStateNormal];
        [filterAppearance setTitleTextAttributes:customBoldFontAttributes forState:UIControlStateSelected];

        // That’s it!
        // If you need further customizations for the header — like inserting additional views — you do have to subclass `PSPDFThumbnailViewController`.
        // Methods to override there are (in descending order of probabbility):
        // 1. `-collectionView:layout:referenceSizeForHeaderInSection:` if you want to adjust the header height
        // 2. `-collectionView:viewForSupplementaryElementOfKind:atIndexPath:` if you want to insert additional views or constraints into the header
    });
}

@end
