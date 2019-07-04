//
//  Copyright © 2011-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCGridViewController.h"
#import "PSCAvailability.h"
#import "PSCDebouncedLoadingIndicator.h"
#import "PSCImageGridViewCell.h"
#import "PSCKioskPDFViewController.h"
#import "PSCMagazine.h"
#import "PSCMagazineFolder.h"

static const NSTimeInterval PSCTransitionDuration = 0.3;

@interface PSCGridViewController () <UISearchBarDelegate, UINavigationControllerDelegate, UIViewControllerAnimatedTransitioning>
@property (nonatomic) BOOL immediatelyLoadCellImages; // UI tweak.
@property (nonatomic, copy) NSArray *filteredData;

@property (nonatomic) PSCMagazine *lastOpenedMagazine;
@property (nonatomic) UISearchBar *searchBar;
@property (nonatomic) UIActivityIndicatorView *activityView;
@property (nonatomic) UIImage *coverImage;
@property (nonatomic) UIImage *targetPageImage;
@property (nonatomic) NSUInteger cellIndex;
@property (nonatomic) UIImageView *magazineCoverView;
@property (nonatomic) UIImageView *magazineCurrentPageView;
@end

@implementation PSCGridViewController

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss:)];

        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(diskDataLoaded:) name:PSCStoreDiskLoadFinishedNotification object:nil];

        _cellIndex = NSNotFound;
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    _searchBar.delegate = nil;
    if (self.isViewLoaded) {
        self.collectionView.delegate = nil;
        self.collectionView.dataSource = nil;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (!self.magazineFolder) {
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }

    // Init the collection view
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];

    // We use the default configuration for good defaults.
    PSPDFConfiguration *configuration = [PSPDFConfiguration defaultConfiguration];
    flowLayout.minimumInteritemSpacing = configuration.thumbnailInteritemSpacing;
    flowLayout.minimumLineSpacing = configuration.thumbnailLineSpacing * 2; // Double this, because otherwise the text labels are too close to the thumbnails below.
    flowLayout.sectionInset = configuration.thumbnailMargin;

    self.view.backgroundColor = configuration.backgroundColor;

    [collectionView registerClass:PSCImageGridViewCell.class forCellWithReuseIdentifier:NSStringFromClass(PSCImageGridViewCell.class)];
    collectionView.delegate = self;
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    collectionView.backgroundColor = UIColor.clearColor;
    self.collectionView = collectionView;

    [self.view addSubview:collectionView];
    collectionView.frame = CGRectIntegral(self.view.bounds);
    collectionView.dataSource = self; // auto-reloads

    // Add the search bar.
    CGFloat searchBarWidth = 290.0;
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectIntegral(CGRectMake((self.collectionView.bounds.size.width - searchBarWidth) / 2, -44., searchBarWidth, 44.0))];
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    searchBar.tintColor = UIColor.blackColor;
    searchBar.backgroundColor = UIColor.clearColor;
    searchBar.alpha = 0.5;
    searchBar.delegate = self;
    searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.searchBar = searchBar;

    // Doesn't matter much if this fails, but the background doesn't look great within our grid.
    [PSCGetViewInsideView(searchBar, @"UISearchBarBack") removeFromSuperview];

    // Set the return key and keyboard appearance of the search bar.
    // Since we do live-filtering, the search bar should just dismiss the keyboard.
    for (UITextField *searchBarTextField in searchBar.subviews) {
        if ([searchBarTextField conformsToProtocol:@protocol(UITextInputTraits)]) {
            @try {
                searchBarTextField.enablesReturnKeyAutomatically = NO;
                searchBarTextField.keyboardAppearance = UIKeyboardAppearanceDark;
            } @catch (__unused NSException *e) {
            }
            break;
        }
    }

    const CGFloat topLayoutHeight = 55.0;
    self.collectionView.contentInset = UIEdgeInsetsMake(topLayoutHeight, 0, 0, 0);
    [self.collectionView addSubview:self.searchBar];

    // Custom transition support
    self.navigationController.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Only one delegate at a time (only one grid is displayed at a time)
    PSCStoreManager.sharedStoreManager.delegate = self;

    // Ensure everything is up to date (we could change magazines in other controllers)
    self.immediatelyLoadCellImages = YES;
    [self diskDataLoaded]; // also reloads the grid
    self.immediatelyLoadCellImages = NO;

    [self setProgressIndicatorVisible:PSCStoreManager.sharedStoreManager.isDiskDataLoaded animated:NO];

    // Reload view, request new images.
    [self updateGrid];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // Ensure we're not in editing mode.
    [self setEditing:NO animated:animated];

    // Only deregister if not attached to anything else.
    if (PSCStoreManager.sharedStoreManager.delegate == self) {
        PSCStoreManager.sharedStoreManager.delegate = nil;
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self.collectionView.collectionViewLayout invalidateLayout];
    } completion:NULL];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

- (void)setMagazineFolder:(PSCMagazineFolder *_Nullable)magazineFolder {
    if (magazineFolder != _magazineFolder) {
        _magazineFolder = magazineFolder;
        self.title = magazineFolder.title;

        if (self.isViewLoaded) {
            [self.collectionView reloadData];
        }
    }
}

- (void)updateGrid {
    BOOL restoreKeyboard = NO;
    if (self.searchBar.isFirstResponder) {
        restoreKeyboard = YES;
    }

    // This, sadly steals our first responder.
    [self.collectionView reloadData];
    if (restoreKeyboard) {
        // Block the fade-in-animation.
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [self.searchBar becomeFirstResponder];
        [CATransaction commit];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Progress display

- (void)setProgressIndicatorVisible:(BOOL)visible animated:(BOOL)animated {
    if (visible) {
        if (!self.activityView) {
            UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [activityView sizeToFit];
            activityView.center = self.view.center;
            activityView.frame = CGRectIntegral(activityView.frame);
            activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            [activityView startAnimating];
            self.activityView = activityView;
        }
    }
    if (visible) {
        self.activityView.alpha = 0.0;
        [self.view addSubview:self.activityView];
    }
    [UIView animateWithDuration:animated ? 0.25 : 0.0 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
        self.activityView.alpha = visible ? 1.0 : 0.0;
    } completion:^(BOOL finished) {
        if (finished && !visible) {
            [self.activityView removeFromSuperview];
        }
    }];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

// Calculates where the document view will be on screen.
- (CGRect)magazinePageCoordinatesWithDoublePageCurl:(BOOL)doublePageCurl {
    CGRect newFrame = self.view.frame;

    // Animation needs to be different if we are in pageCurl mode.
    if (doublePageCurl) {
        newFrame.size.width /= 2;
        newFrame.origin.x += newFrame.size.width;
    }
    return newFrame;
}

// Calculates where the document view will be on screen.
- (CGRect)magazinePageCoordinatesWithPDFController:(PSCKioskPDFViewController *)pdfController {
    CGRect newFrame = self.view.frame;

    // Animation needs to be different if we are in pageCurl mode.
    const NSInteger pageIndex = pdfController.pageIndex;
    PSPDFDocumentViewLayout *layout = pdfController.documentViewController.layout;
    const NSInteger spreadIndex = [layout spreadIndexForPageAtIndex:pageIndex];
    const NSUInteger spreadWidth = [layout pageRangeForSpreadAtIndex:spreadIndex].length;
    if (spreadWidth > 1) {
        newFrame.size.width /= spreadWidth;
        if (pdfController.configuration.isFirstPageAlwaysSingle) {
            newFrame.origin.x = CGRectGetWidth(self.view.frame) - CGRectGetWidth(newFrame);
        } else {
            newFrame.origin.x += newFrame.size.width * (pageIndex % spreadWidth);
        }
    }
    return newFrame;
}

// Open magazine with a nice animation.
- (BOOL)openMagazine:(PSCMagazine *)magazine animated:(BOOL)animated cellIndex:(NSUInteger)cellIndex {
    if (!magazine) return NO;

    self.lastOpenedMagazine = magazine;
    self.cellIndex = cellIndex;

    [self.searchBar resignFirstResponder];

    PSPDFViewState *previousState = magazine.lastViewState;
    if (previousState.hasViewPort) {
        // Our custom transition from the cover page in the grid to the opened magazine would look extremely jerky if it jumped to a completely restored viewport.
        // Therefore we nuke that info.
        magazine.lastViewState = [[PSPDFViewState alloc] initWithPageIndex:previousState.pageIndex];
    }

    PSCKioskPDFViewController *pdfController = [[PSCKioskPDFViewController alloc] initWithDocument:magazine configuration:[PSPDFConfiguration configurationWithBuilder:^(PSPDFConfigurationBuilder *builder) {
        builder.bookmarkSortOrder = PSPDFBookmarkManagerSortOrderCustom;
    }]];

    PSPDFMutableRenderRequest *request = [[PSPDFMutableRenderRequest alloc] initWithDocument:magazine];
    request.imageSize = UIScreen.mainScreen.bounds.size;

    // prevent the user from tapping while we are rendering
    // This is not great but ensures to keep the sample here simple.
    [PSPDFSharedApplication() beginIgnoringInteractionEvents];

    NSMutableArray<PSPDFRenderTask *> *tasks = [NSMutableArray new];

    PSPDFRenderTask *coverTask = [[PSPDFRenderTask alloc] initWithRequest:request];
    coverTask.priority = PSPDFRenderQueuePriorityUserInteractive;
    [tasks addObject:coverTask];

    // Prepare the target page image, if it differs from the cover image
    PSPDFRenderTask *targetPageTask;
    if (animated && pdfController.pageIndex != 0) {
        request.pageIndex = pdfController.pageIndex;
        targetPageTask = [[PSPDFRenderTask alloc] initWithRequest:request];
        targetPageTask.priority = PSPDFRenderQueuePriorityUserInteractive;
        [tasks addObject:targetPageTask];
    }

    [PSPDFKit.sharedInstance.renderManager.renderQueue scheduleTasks:tasks];

    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:cellIndex inSection:0]];
    PSCDebouncedLoadingIndicator *loadingIndicator = [[PSCDebouncedLoadingIndicator alloc] initWithFrame:cell.contentView.bounds];
    [cell.contentView addSubview:loadingIndicator];

    [PSPDFRenderTask groupTasks:tasks completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.coverImage = coverTask.image;
            self.targetPageImage = targetPageTask.image;

            [self.navigationController pushViewController:pdfController animated:animated];

            [loadingIndicator removeFromSuperview];

            // image loading done, let the user tap again
            [PSPDFSharedApplication() endIgnoringInteractionEvents];
        });
    }];

    return YES;
}

- (void)diskDataLoaded:(NSNotification *)aNotification {
    // Reset cell index & cover image. Magazines have changed. We can no longer guarantee that these values are correct.
    self.cellIndex = NSNotFound;
    self.coverImage = nil;

    [self diskDataLoaded];
}

- (void)diskDataLoaded {
    // Update indicator
    [self setProgressIndicatorVisible:PSCStoreManager.sharedStoreManager.isDiskDataLoaded animated:YES];

    // Not finished yet? Return early.
    if (PSCStoreManager.sharedStoreManager.magazineFolders.count == 0) return;

    // If we're in plain mode, pre-set a folder.
    if (PSPDFStoreManagerPlain) self.magazineFolder = PSCStoreManager.sharedStoreManager.magazineFolders.lastObject;

    [self updateGrid];
}

- (BOOL)canEditCell:(PSCImageGridViewCell *)cell {
    BOOL editing = self.isEditing;
    if (editing) {
        if (cell.magazine) {
            editing = cell.magazine.isAvailable && cell.magazine.isDeletable;
        } else {
            NSArray *fixedMagazines = [self.magazineFolder.magazines filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isDeletable = NO || isAvailable = NO"]];
            editing = fixedMagazines.count == 0;
        }
    }
    return editing;
}

- (void)updateEditingAnimated:(BOOL)animated {
    for (PSCImageGridViewCell *cell in self.collectionView.visibleCells) {
        if ([cell isKindOfClass:PSCImageGridViewCell.class]) {
            BOOL editing = [self canEditCell:cell];
            if (editing) cell.showDeleteImage = editing;
            cell.deleteButton.alpha = editing ? 0.0 : 1.0;

            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                cell.deleteButton.alpha = editing ? 1.0 : 0.0;
            } completion:^(BOOL finished) {
                if (finished) {
                    cell.showDeleteImage = editing;
                }
            }];
        }
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self updateEditingAnimated:animated];
}

- (void)setEditing:(BOOL)editing {
    super.editing = editing;
    [self updateEditingAnimated:NO];
}

- (PSCMagazine *)magazineAtIndexPath:(NSIndexPath *)indexPath {
    if (self.magazineFolder) {
        return _filteredData[indexPath.item];
    }

    PSCMagazineFolder *folder = _filteredData[indexPath.item];
    return folder.firstMagazine;
}

- (void)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.magazineFolder) {
        _filteredData = self.magazineFolder.magazines;
    } else {
        _filteredData = PSCStoreManager.sharedStoreManager.magazineFolders;
    }

    NSString *searchString = _searchBar.text;
    if (searchString.length) { // title CONTAINS[cd] '%@' ||
        _filteredData = [_filteredData filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"fileURL.path CONTAINS[cd] %@", searchString]];
    } else {
        _filteredData = [_filteredData copy];
    }

    return _filteredData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PSCImageGridViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(PSCImageGridViewCell.class) forIndexPath:indexPath];

    // connect the delete button
    if (cell.deleteButton.allTargets.count == 0) {
        [cell.deleteButton addTarget:self action:@selector(processDeleteAction:) forControlEvents:UIControlEventTouchUpInside];
    }

    cell.immediatelyLoadCellImages = self.immediatelyLoadCellImages;
    if (self.magazineFolder) {
        cell.magazine = _filteredData[indexPath.item];
    } else {
        cell.magazineFolder = _filteredData[indexPath.item];
    }
    cell.showDeleteImage = [self canEditCell:cell];

    return cell;
}

- (void)processDeleteAction:(UIButton *)button {
    [self processDeleteActionForCell:(PSCImageGridViewCell *)button.superview.superview];
}

- (void)processDeleteActionForCell:(PSCImageGridViewCell *)cell {
    PSCMagazine *magazine = cell.magazine;
    PSCMagazineFolder *folder = cell.magazineFolder;

    if (self.magazineFolder) {
        [PSCStoreManager.sharedStoreManager deleteMagazine:magazine];
    } else {
        [PSCStoreManager.sharedStoreManager deleteMagazineFolder:folder];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PSCMagazine *magazine = [self magazineAtIndexPath:indexPath];
    PSCMagazineFolder *folder = self.magazineFolder ?: _filteredData[indexPath.item];

    PSCLog(@"Magazine selected: %tu %@", indexPath.item, magazine);

    if (folder.magazines.count == 1 || self.magazineFolder) {
        [self openMagazine:magazine animated:YES cellIndex:indexPath.item];
    } else {
        PSCGridViewController *gridController = [[PSCGridViewController alloc] init];
        gridController.magazineFolder = folder;

        // A full-page-fade animation doesn't work very well on iPad. (under a ux aspect; technically it's fine)
        if (!PSCIsIPad()) {
            CATransition *transition = PSCFadeTransitionWithDuration(0.3);
            [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
            [self.navigationController pushViewController:gridController animated:NO];

        } else {
            [self.navigationController pushViewController:gridController animated:YES];
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)layout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    PSCMagazine *magazine = [self magazineAtIndexPath:indexPath];
    PSPDFPageInfo *info = magazine.available ? [magazine pageInfoForPageAtIndex:0] : nil;
    const CGSize ASeriesSize = CGSizeMake(1.0, sqrtf(2.0)); // The ratio of portrait A4 paper: a sensible default.
    const CGSize pageSize = info ? info.size : ASeriesSize;
    const CGSize containerSize = UIEdgeInsetsInsetRect(collectionView.bounds, layout.sectionInset).size;

    return [PSPDFThumbnailViewController automaticThumbnailSizeForPageWithSize:pageSize referencePageSize:ASeriesSize containerSize:containerSize interitemSpacing:layout.minimumInteritemSpacing];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // resign keyboard if we scroll down
    if (self.collectionView.contentOffset.y > 0) {
        [self.searchBar resignFirstResponder];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFStoreManagerDelegate

- (BOOL)isSearchModeActive {
    return self.searchBar.text.length > 0;
}

- (void)magazineStoreBeginUpdate {
}
- (void)magazineStoreEndUpdate {
}

- (void)magazineStoreFolderDeleted:(PSCMagazineFolder *)magazineFolder {
    // don't animate if we're in search mode
    if (self.isSearchModeActive) return;

    if (!self.magazineFolder) {
        NSUInteger cellIndex = [PSCStoreManager.sharedStoreManager.magazineFolders indexOfObject:magazineFolder];
        if (cellIndex != NSNotFound) {
            [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:cellIndex inSection:0]]];
        } else {
            PSCLog(@"index not found for %@", magazineFolder);
        }
    }
}

- (void)magazineStoreFolderAdded:(PSCMagazineFolder *)magazineFolder {
    // Don't animate if we're in search mode
    if (self.isSearchModeActive) return;

    if (!self.magazineFolder) {
        NSUInteger cellIndex = [PSCStoreManager.sharedStoreManager.magazineFolders indexOfObject:magazineFolder];
        if (cellIndex != NSNotFound) {
            [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:cellIndex inSection:0]]];
        } else {
            PSCLog(@"index not found for %@", magazineFolder);
        }
    }
}

- (void)magazineStoreFolderModified:(PSCMagazineFolder *)magazineFolder {
    // don't animate if we're in search mode
    if (self.isSearchModeActive) return;

    [self.collectionView reloadData];
}

- (void)openMagazine:(PSCMagazine *)magazine {
    NSUInteger cellIndex = [self.magazineFolder.magazines indexOfObject:magazine];
    if (cellIndex != NSNotFound) {
        [self openMagazine:magazine animated:YES cellIndex:cellIndex];
    } else {
        PSCLog(@"index not found for %@", magazine);
    }
}

- (void)magazineStoreMagazineDeleted:(PSCMagazine *)magazine {
    // don't animate if we're in search mode
    if (self.isSearchModeActive) return;

    if (self.magazineFolder) {
        NSUInteger cellIndex = [self.magazineFolder.magazines indexOfObject:magazine];
        if (cellIndex != NSNotFound) {
            [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:cellIndex inSection:0]]];
        } else {
            PSCLog(@"index not found for %@", magazine);
        }
    }
}

- (void)magazineStoreMagazineAdded:(PSCMagazine *)magazine {
    // don't animate if we're in search mode
    if (self.isSearchModeActive) return;

    if (self.magazineFolder) {
        [self.collectionView reloadData];
    }
}

- (void)magazineStoreMagazineModified:(PSCMagazine *)magazine {
    // don't animate if we're in search mode
    if (self.isSearchModeActive) return;

    if (self.magazineFolder) {
        NSUInteger cellIndex = [self.magazineFolder.magazines indexOfObject:magazine];
        if (cellIndex != NSNotFound) {
            [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:cellIndex inSection:0]]];
        } else {
            PSCLog(@"index not found for %@", magazine);
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        searchBar.alpha = 1.0;
    } completion:NULL];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    UIScrollView *wrap = (UIScrollView *)searchBar.superview;
    searchBar.frame = CGRectMake(wrap.frame.origin.x, wrap.frame.origin.y, searchBar.frame.size.width, searchBar.frame.size.height);
    searchBar.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
    [wrap.superview addSubview:searchBar];
    [wrap removeFromSuperview];

    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        searchBar.alpha = 0.5;
    } completion:NULL];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    _filteredData = nil;

    [self updateGrid];
    self.collectionView.contentOffset = CGPointMake(0.0, -self.collectionView.contentInset.top);
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    // UISearchBar tries to scroll to visible even though it is already visible.
    // We wrap it into a dummy scroll view to prevent this logic.
    UIScrollView *wrap = [[UIScrollView alloc] initWithFrame:searchBar.frame];
    wrap.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
    [searchBar.superview addSubview:wrap];
    searchBar.frame = CGRectMake(0, 0, searchBar.frame.size.width, searchBar.frame.size.height);
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [wrap addSubview:searchBar];
    return YES;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    BOOL pushingMagazine = operation == UINavigationControllerOperationPush && fromVC == self && [toVC isKindOfClass:[PSCKioskPDFViewController class]];
    BOOL popMagazine = operation == UINavigationControllerOperationPop && toVC == self && [fromVC isKindOfClass:[PSCKioskPDFViewController class]];

    // Custom zoom animation
    if (pushingMagazine || popMagazine) return self;

    // Standard UINavigationController animation
    return nil;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return PSCTransitionDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    if (fromViewController == self) {
        // Fallback to a crossfade animation, if we can't get a usable cover image
        if (!self.coverImage || self.lastOpenedMagazine.isLocked) {
            [self animateCrossFadeTransition:transitionContext];
        } else {
            [self animateZoomInTransition:transitionContext];
        }
    } else {
        // Fallback to a crossfade animation, if we can't get a usable cover image
        // or if the index is left in an invalid state
        if (!self.coverImage || self.cellIndex >= self.magazineFolder.magazines.count) {
            [self animateCrossFadeTransition:transitionContext];
        } else {
            [self animateZoomOutTransition:transitionContext];
        }
    }
}

- (void)animateZoomInTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *containerView = transitionContext.containerView;
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    // Pushing to a magazine
    PSCKioskPDFViewController *pdfController = (PSCKioskPDFViewController *)toViewController;

    NSIndexPath *ip = [NSIndexPath indexPathForItem:self.cellIndex inSection:0];
    PSCImageGridViewCell *cell = (PSCImageGridViewCell *)[self.collectionView cellForItemAtIndexPath:ip];
    CGRect cellCoords = [cell.imageView convertRect:cell.imageView.bounds toView:containerView];

    CGRect newFrame = [self magazinePageCoordinatesWithPDFController:pdfController];

    // Prepare the cover image view, match it's position to the position of the (now hidden) cell.
    UIImageView *coverImageView = self.magazineCoverView;
    coverImageView.image = self.coverImage;
    coverImageView.frame = cellCoords;
    [containerView addSubview:coverImageView];

    // If we have a different page, fade to that page.
    UIImageView *targetPageImageView;
    if (self.targetPageImage) {
        targetPageImageView = self.magazineCurrentPageView;
        targetPageImageView.image = self.targetPageImage;
        targetPageImageView.frame = coverImageView.bounds;
        targetPageImageView.alpha = 0.0;
        [coverImageView addSubview:targetPageImageView];
    }

    cell.hidden = YES;

    [UIView animateWithDuration:PSCTransitionDuration * 2.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.0 options:0 animations:^{
        self.collectionView.transform = CGAffineTransformMakeScale(0.97, 0.97);
        self.collectionView.alpha = 0.0;
        coverImageView.frame = newFrame;
        targetPageImageView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [containerView addSubview:toViewController.view];
        toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];

        toViewController.view.alpha = 0.0;
        [UIView animateWithDuration:0.25 animations:^{
            toViewController.view.alpha = 1.0;
        } completion:^(BOOL innerFinished) {
            [coverImageView removeFromSuperview];
            self.collectionView.transform = CGAffineTransformIdentity;
            self.collectionView.alpha = 1.0;
            self.targetPageImage = nil;
            cell.hidden = NO;

            [transitionContext completeTransition:YES];
        }];
    }];
}

- (void)animateZoomOutTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *containerView = transitionContext.containerView;
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    PSCKioskPDFViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    NSParameterAssert([fromViewController isKindOfClass:PSCKioskPDFViewController.class]);

    UIImageView *coverImageView = self.magazineCoverView;

    // Modify the view hierarchy first, otherwise the cell frame might not be as expected
    [containerView addSubview:toViewController.view];
    toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
    [fromViewController.view removeFromSuperview];
    [containerView addSubview:coverImageView];

    NSIndexPath *ip = [NSIndexPath indexPathForItem:self.cellIndex inSection:0];
    [self.collectionView scrollToItemAtIndexPath:ip atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    [self.collectionView layoutSubviews]; // ensure cells are laid out

    // Convert the coordinates into view coordinate system.
    // We can't remember those, because the device might have been rotated.
    PSCImageGridViewCell *cell = (PSCImageGridViewCell *)[self.collectionView cellForItemAtIndexPath:ip];
    CGRect cellCoords = [cell.imageView convertRect:cell.imageView.bounds toView:containerView];

    coverImageView.frame = [self magazinePageCoordinatesWithPDFController:fromViewController];

    // Update image for a nicer animation (get the correct page)
    PSCMagazine *lastOpenedMagazine = self.lastOpenedMagazine;
    UIImage *updatedImage;
    if (lastOpenedMagazine) {
        PSPDFMutableRenderRequest *request = [[PSPDFMutableRenderRequest alloc] initWithDocument:lastOpenedMagazine];
        request.pageIndex = lastOpenedMagazine.lastViewState.pageIndex;
        request.imageSize = UIScreen.mainScreen.bounds.size;

        updatedImage = [PSPDFKit.sharedInstance.cache imageForRequest:request imageSizeMatching:PSPDFCacheImageSizeMatchingAllowSmaller];
    }

    UIImageView *sourcePageImageView;
    if (updatedImage) {
        sourcePageImageView = self.magazineCurrentPageView;
        sourcePageImageView.image = updatedImage;
        sourcePageImageView.frame = coverImageView.bounds;
        [coverImageView addSubview:sourcePageImageView];
    } else if (_magazineCurrentPageView) {
        // Use the cover image only
        [_magazineCurrentPageView removeFromSuperview];
    }

    self.collectionView.transform = CGAffineTransformMakeScale(0.97, 0.97);
    cell.hidden = YES;

    [UIView animateWithDuration:PSCTransitionDuration * 2.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.0 options:0 animations:^{
        self.collectionView.transform = CGAffineTransformIdentity;
        coverImageView.frame = cellCoords;
        sourcePageImageView.alpha = 0.0;
        self.collectionView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [coverImageView removeFromSuperview];
        self.magazineCoverView = nil;
        self.magazineCurrentPageView = nil;
        self.cellIndex = NSNotFound;
        cell.hidden = NO;

        [transitionContext completeTransition:YES];
    }];
}

- (void)animateCrossFadeTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *containerView = transitionContext.containerView;
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    [containerView addSubview:toViewController.view];
    toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
    toViewController.view.alpha = 0.0;

    [UIView animateWithDuration:PSCTransitionDuration animations:^{
        toViewController.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

- (UIImageView *)magazineCoverView {
    if (!_magazineCoverView) {
        _magazineCoverView = [[UIImageView alloc] init];
        _magazineCoverView.contentMode = UIViewContentModeScaleAspectFit;
        _magazineCoverView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _magazineCoverView;
}

- (UIImageView *)magazineCurrentPageView {
    if (!_magazineCurrentPageView) {
        _magazineCurrentPageView = [[UIImageView alloc] init];
        _magazineCurrentPageView.contentMode = UIViewContentModeScaleAspectFit;
        _magazineCurrentPageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return _magazineCurrentPageView;
}

@end

// Fixes the missing action method crash on updating when the keyboard is visible.
#import <objc/runtime.h>

__attribute__((constructor)) static void PSPDFFixCollectionViewUpdateItemWhenKeyboardIsDisplayed(void) {
    @autoreleasepool {
        if (![UICollectionViewUpdateItem instancesRespondToSelector:@selector(action)]) {
            IMP updateIMP = imp_implementationWithBlock(^(id _self){
            });
            Method method = class_getInstanceMethod([UICollectionViewUpdateItem class], @selector(action));
            const char *encoding = method_getTypeEncoding(method);
            if (!class_addMethod(UICollectionViewUpdateItem.class, @selector(action), updateIMP, encoding)) {
                NSLog(@"Failed to add action: workaround");
            }
        }
    }
}

// Fixes a missing selector crash for [UISearchBar _isInUpdateAnimation:]
__attribute__((constructor)) static void PSPDFFixCollectionViewSearchBarDisplayed(void) {
    @autoreleasepool {
        SEL isInUpdate = NSSelectorFromString([NSString stringWithFormat:@"%@is%@Update%@", @"_", @"In", @"Animation"]);
        if (![UISearchBar instancesRespondToSelector:isInUpdate]) {
            IMP updateIMP = imp_implementationWithBlock(^(id _self) {
                return NO;
            });
            Method method = class_getInstanceMethod(UISearchBar.class, isInUpdate);
            const char *encoding = method_getTypeEncoding(method);
            if (!class_addMethod(UISearchBar.class, isInUpdate, updateIMP, encoding)) {
                NSLog(@"Failed to add [is In Update Animation:] workaround");
            }
        }
    }
}
