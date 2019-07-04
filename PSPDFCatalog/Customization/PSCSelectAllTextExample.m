//
//  Copyright © 2011-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCSelectAllTextExample : PSCExample <PSPDFViewControllerDelegate>
@end

@implementation PSCSelectAllTextExample

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Add \"Select All\" to text menu";
        self.category = PSCExampleCategoryViewCustomization;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document];
    pdfController.delegate = self;
    return pdfController;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFViewControllerDelegate

- (PSPDFMenuItem *)selectAllTextItemForPageView:(PSPDFPageView *)pageView {
    PSPDFMenuItem *selectAllMenu;

    // Make sure we haven't selected everything already.
    NSArray *allGlyphs = [pageView.presentationContext.document textParserForPageAtIndex:pageView.pageIndex].glyphs;
    if (pageView.selectionView.selectedGlyphs.count != allGlyphs.count) {
        selectAllMenu = [[PSPDFMenuItem alloc] initWithTitle:@"Select All" block:^{
            // We need to manually sort glyphs.
            pageView.selectionView.selectedGlyphs = [pageView.selectionView sortedGlyphs:allGlyphs];
            [pageView showMenuIfSelectedAnimated:YES];
        } identifier:@"Select All"];
    }
    return selectAllMenu;
}

- (NSArray<PSPDFMenuItem *> *)pdfViewController:(PSPDFViewController *)pdfController shouldShowMenuItems:(NSArray<PSPDFMenuItem *> *)menuItems atSuggestedTargetRect:(CGRect)rect forSelectedText:(NSString *)selectedText inRect:(CGRect)textRect onPageView:(PSPDFPageView *)pageView {
    NSMutableArray *mutableMenuItems = [NSMutableArray arrayWithArray:menuItems];
    PSPDFMenuItem *selectAllMenu = [self selectAllTextItemForPageView:pageView];
    if (selectAllMenu) {
        [mutableMenuItems insertObject:selectAllMenu atIndex:0];
    }

    return mutableMenuItems;
}

- (NSArray<PSPDFMenuItem *> *)pdfViewController:(PSPDFViewController *)pdfController shouldShowMenuItems:(NSArray<PSPDFMenuItem *> *)menuItems atSuggestedTargetRect:(CGRect)rect forAnnotations:(nullable NSArray<PSPDFAnnotation *> *)annotations inRect:(CGRect)annotationRect onPageView:(PSPDFPageView *)pageView {
    NSMutableArray *mutableMenuItems = [NSMutableArray arrayWithArray:menuItems];

    // Show only in new annotation menu
    if (annotations.count == 0) {
        PSPDFMenuItem *selectAllMenu = [self selectAllTextItemForPageView:pageView];
        if (selectAllMenu) {
            [mutableMenuItems insertObject:selectAllMenu atIndex:0];
        }
    }

    return mutableMenuItems;
}

@end
