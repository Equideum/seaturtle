//
//  Copyright © 2012-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCCatalogViewController.h"
#import "PSCExampleManager.h"
#import "PSCSectionDescriptor.h"
#import "UIColor+PSCDefaults.h"
#import "PSPDFCatalog-Swift.h"
#import <QuickLook/QuickLook.h>
#import <objc/runtime.h>

@interface PSCCatalogViewController () <PSPDFDocumentDelegate, UISearchResultsUpdating, PSCExampleRunnerDelegate> {
    BOOL _shouldRestoreState;
    BOOL _shouldHideSearchBar;
    BOOL _clearCacheNeeded;
}
@property (nonatomic, copy) NSArray<PSCSectionDescriptor *> *content;
@property (nonatomic, copy) NSArray<PSCContent *> *searchContent;
@property (nonatomic) UISearchController *searchController;
@property (nonatomic) PSCCatalogExampleLanguage preferredExampleLanguage;
@end

static NSString *const PSCLastIndexPath = @"PSCLastIndexPath";
static NSString *const PSCCatalogExamplePreferenceLanguageKey = @"PSCCatalogExamplePreferenceLanguage";

@implementation PSCCatalogViewController

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle

- (instancetype)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
        self.title = @"PSPDFKit Catalog";
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Catalog" style:UIBarButtonItemStylePlain target:nil action:nil];

        // We need to call this before the view loads initially
        [self applyCatalogAppearanceUsingCustomTinting:YES];

        [self addKeyCommand:[UIKeyCommand keyCommandWithInput:@"f" modifierFlags:UIKeyModifierCommand action:@selector(beginSearch:) discoverabilityTitle:@"Search"]];
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Content Creation

- (void)createTableContent {
    NSMutableOrderedSet<PSCSectionDescriptor *> *sections = [NSMutableOrderedSet orderedSet];
    NSArray<PSCExample *> *examples = [PSCExampleManager.defaultManager examplesForPreferredLanguage:self.preferredExampleLanguage];

    // Add examples and map categories to sections.
    PSCExampleCategory currentCategory = -1;
    PSCSectionDescriptor *currentSection;
    for (PSCExample *example in examples) {
        if (currentCategory != example.category) {
            if (currentSection && currentSection.contentDescriptors.count > 1) {
                [sections addObject:currentSection];
            }

            currentCategory = example.category;
            currentSection = [PSCSectionDescriptor sectionWithTitle:PSCHeaderFromExampleCategory(currentCategory) footer:PSCFooterFromExampleCategory(currentCategory)];

            if (currentCategory == PSCExampleCategoryTop) {
                currentSection.headerView = self.topHeaderView;
                currentSection.isCollapsed = NO;
            } else {
                [currentSection addContent:[PSCContent sectionHeaderContentWithTitle:PSCHeaderFromExampleCategory(currentCategory) description:PSCFooterFromExampleCategory(currentCategory)]];
            }
        }

        PSCContent *exampleContent = [PSCContent contentWithTitle:example.title description:example.contentDescription];
        exampleContent.example = example;
        [currentSection addContent:exampleContent];
    }

    if (currentSection && currentSection.contentDescriptors.count > 1) {
        [sections addObject:currentSection];
    }

    self.content = sections.array;
}

- (void)setPreferredExampleLanguage:(PSCCatalogExampleLanguage)preferredExampleLanguage {
    [NSUserDefaults.standardUserDefaults setInteger:preferredExampleLanguage forKey:PSCCatalogExamplePreferenceLanguageKey];
    if (self.isViewLoaded) {
        [self createTableContent];
        [self.tableView reloadData];
    }
}

- (PSCCatalogExampleLanguage)preferredExampleLanguage {
    return (PSCCatalogExampleLanguage)[NSUserDefaults.standardUserDefaults integerForKey:PSCCatalogExamplePreferenceLanguageKey];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self createTableContent];
    [self addDebugButtons];

    __auto_type configureTableViewForSearch = ^(UITableView *tableView) {
        BOOL isRootTableView = tableView == self.tableView;
        tableView.delegate = self;
        tableView.dataSource = self;
        // We're not using headers for the search table view
        tableView.estimatedSectionHeaderHeight = isRootTableView ? 30 : 0;

        tableView.cellLayoutMarginsFollowReadableWidth = YES;
    };

    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;

    UITableView *tableView = self.tableView;
    configureTableViewForSearch(tableView);
    // Make sure that we can preserve the selection in state restoration
    tableView.restorationIdentifier = @"Samples Table";

    // Present the search display controller on this view controller
    self.definesPresentationContext = YES;

    UITableViewController *resultsController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    configureTableViewForSearch(resultsController.tableView);

    UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:resultsController];
    searchController.searchResultsUpdater = self;
    self.searchController = searchController;

    // Enables workarounds for rdar://352525 and rdar://32630657.
    [searchController pspdf_installWorkaroundsOn:self];
    self.navigationItem.searchController = searchController;

    _shouldRestoreState = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    UITableView *tableView = self.tableView;
    NSIndexPath *tableViewIndexPath = tableView.indexPathForSelectedRow;
    if (tableViewIndexPath != nil) {
        [tableView deselectRowAtIndexPath:tableViewIndexPath animated:YES];
    }

    [self.navigationController setToolbarHidden:YES animated:animated];

    // Restore appearance back to defaults, in case an example change it
    [self applyCatalogAppearanceUsingCustomTinting:YES];

    // clear cache (for night mode)
    if (_clearCacheNeeded) {
        _clearCacheNeeded = NO;
        [PSPDFKit.sharedInstance.cache clearCache];
    }

    if (_shouldHideSearchBar) {
        tableView.contentOffset = CGPointMake(0, self.searchController.searchBar.frame.size.height - tableView.contentInset.top);
        _shouldHideSearchBar = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // Restore last selected sample if appropriate with support for reset from settings:
    static NSString *const PSCResetKey = @"psc_reset";

    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    if ([defaults boolForKey:PSCResetKey] || [NSProcessInfo.processInfo.arguments containsObject:@"-psc_reset YES"]) { // the launch argument SHOULD override the user defaults, however it does not when launched through an XCUIApplication launch.
        [defaults removeObjectForKey:PSCResetKey];
        [defaults synchronize];
        _shouldRestoreState = NO;
    }
    if (!_shouldRestoreState) {
        [self saveAppStateIfPossible];
    } else {
        _shouldRestoreState = NO;
        NSData *pathData = [defaults objectForKey:PSCLastIndexPath];
        if (!pathData) return;
        NSIndexPath *path = [NSKeyedUnarchiver unarchiveObjectWithData:pathData];
        UITableView *table = self.tableView;
        [table selectRowAtIndexPath:path animated:animated scrollPosition:UITableViewScrollPositionNone];

        @try {
            [self tableView:self.tableView didSelectRowAtIndexPath:path];
        } @catch (NSException *exception) {
            NSLog(@"Failed to restore last example: %@", exception);
        }
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Key Commands

- (IBAction)beginSearch:(id)sender {
    [self.searchController.searchBar becomeFirstResponder];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

- (BOOL)isValidIndexPath:(NSIndexPath *)indexPath forContent:(NSArray<PSCSectionDescriptor *> *)content {
    BOOL isValid = NO;
    if (indexPath) {
        NSInteger numberOfSections = content.count;
        NSInteger numberOfRowsInSection = 0;
        if (indexPath.section < numberOfSections) {
            numberOfRowsInSection = content[indexPath.section].contentDescriptors.count;
            if (indexPath.row < numberOfRowsInSection) {
                isValid = YES;
            }
        }
    }
    return isValid;
}

- (nullable PSCContent *)contentDescriptorForIndexPath:(nonnull NSIndexPath *)indexPath tableView:(nullable UITableView *)tableView {
    // Get correct content descriptor
    PSCContent *contentDescriptor;
    if (!tableView || tableView == self.tableView) {
        NSAssert([self isValidIndexPath:indexPath forContent:self.content], @"Index path must be valid");
        contentDescriptor = (self.content[indexPath.section]).contentDescriptors[indexPath.row];
    } else {
        NSAssert(indexPath.row >= 0 && (NSUInteger)indexPath.row < self.searchContent.count, @"Index path must be valid");
        contentDescriptor = self.searchContent[indexPath.row];
    }
    return contentDescriptor;
}

- (nullable PSCExample *)exampleForIndexPath:(nonnull NSIndexPath *)indexPath tableView:(nullable UITableView *)tableView {
    PSCContent *contentDescriptor = [self contentDescriptorForIndexPath:indexPath tableView:tableView];
    return contentDescriptor.example;
}

- (void)applyCatalogAppearanceUsingCustomTinting:(BOOL)customTint {
    UIColor *brandColor = customTint ? UIColor.pspdfColor : nil;
    UIColor *complementaryColor = customTint ? UIColor.whiteColor : nil;
    // Global (the window reference should be set by the application delegate early in the app lifecycle)
    self.keyWindow.tintColor = brandColor;
    // Navigation bar and tool bar customization. We're limiting appearance customization to instances that are
    // inside PSPDFNavigationController, so we don't affect the appearance of certain system controllers.
    // PSPDFKit will keep the default appearance for bars inside popovers.
    // To change that override -[PSPDFViewController presentationManager:applyStyleToViewController:].
    UINavigationBar *navBar = [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[PSPDFNavigationController.class]];
    UIToolbar *toolbar = [UIToolbar appearanceWhenContainedInInstancesOfClasses:@[PSPDFNavigationController.class]];
    navBar.barTintColor = brandColor;
    navBar.tintColor = complementaryColor;
    // PSPDFViewController will still forward this setting to it's presented view controllers if you set it manually using
    // self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    UIBarStyle barStyle = customTint ? UIBarStyleBlack : UIBarStyleDefault;
    navBar.barStyle = barStyle;
    toolbar.barStyle = barStyle;
    toolbar.barTintColor = brandColor;
    toolbar.tintColor = complementaryColor;
    // By default the system would show a white cursor.
    [UITextField appearance].tintColor = brandColor;
    [UITextView appearance].tintColor = brandColor;
    // We need to style the section index, otherwise we can end up with white text on a white-ish background.
    [UITableView appearance].sectionIndexColor = brandColor;
    [UITableView appearance].sectionIndexBackgroundColor = UIColor.clearColor;
    // The accessory view leaves on the keyboard window, so it doesn't auto inherit the window tint color
    [PSPDFFreeTextAccessoryView appearance].tintColor = brandColor;
    // Catalog search bar customization
    UISearchBar *searchBar = self.searchController.searchBar;
    searchBar.tintColor = complementaryColor;
    UIColor *searchColor = [UIColor.whiteColor colorWithAlphaComponent:0.4];
    UIImage *img = customTint ? [UIImage pspdf_imageWithColor:searchColor size:CGSizeMake(36.0, 36.0) cornerRadius:10.0] : nil;
    [searchBar setSearchFieldBackgroundImage:img forState:UIControlStateNormal];
    [searchBar setSearchTextPositionAdjustment:(customTint ? UIOffsetMake(8.0, 1.0) : UIOffsetZero)];

    if (customTint) {
        self.tableView.backgroundColor = [UIColor colorWithRed:0.74 green:0.83 blue:0.86 alpha:1.];
    } else {
        self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Views

- (UIView *)topHeaderView {
    UITableViewHeaderFooterView *headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:nil];
    UIView *contentView = headerView.contentView;
    const CGFloat topBottomMargin = 16;

    UIImage *image = [[UIImage imageNamed:@"pspdfkit-logo"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *logo = [[UIImageView alloc] initWithImage:image];
    [contentView addSubview:logo];
    logo.tintColor = [UIColor.blackColor colorWithAlphaComponent:0.7];
    logo.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *top = [logo.topAnchor constraintEqualToAnchor:contentView.topAnchor constant:topBottomMargin];
    // Ensures the layout is not ambiguous while UITableView height calculation is still in flux.
    top.priority = UILayoutPriorityRequired - 1;
    top.active = YES;
    [logo.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor constant:-topBottomMargin-4].active = YES;
    [logo.leadingAnchor constraintEqualToAnchor:contentView.readableContentGuide.leadingAnchor].active = YES;
    [logo setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

    NSArray<NSString *> *titles = @[@"Swift", @"ObjC"];
    UISegmentedControl *filter = [[UISegmentedControl alloc] initWithItems:titles];
    [contentView addSubview:filter];
    filter.translatesAutoresizingMaskIntoConstraints = NO;
    [filter.centerYAnchor constraintEqualToAnchor:logo.centerYAnchor].active = YES;
    [filter.trailingAnchor constraintEqualToAnchor:contentView.readableContentGuide.trailingAnchor].active = YES;
    filter.selectedSegmentIndex = self.preferredExampleLanguage;
    [filter addTarget:self action:@selector(preferredExampleLanguageChanged:) forControlEvents:UIControlEventValueChanged];
    [filter setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

    UILabel *version = [[UILabel alloc] init];
    [contentView addSubview:version];
    version.textColor = logo.tintColor;
    version.attributedText = self.versionString;
    version.numberOfLines = 2;
    version.translatesAutoresizingMaskIntoConstraints = NO;
    [version.leadingAnchor constraintEqualToAnchor:logo.trailingAnchor constant:8].active = YES;
    [version.centerYAnchor constraintEqualToAnchor:logo.centerYAnchor].active = YES;
    [version.trailingAnchor constraintEqualToAnchor:filter.leadingAnchor constant:-4].active = YES;

    return headerView;
}

- (NSAttributedString *)versionString {
    NSString *version = PSPDFKit.versionString;
    NSMutableAttributedString *attibuted = [[NSMutableAttributedString alloc] initWithString:version attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];
    NSRange kitRange = [version rangeOfString:@"PSPDFKit"];
    if (kitRange.location != NSNotFound) {
        [attibuted addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:kitRange];
    }
    return attibuted;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Actions

- (void)preferredExampleLanguageChanged:(UISegmentedControl *)sender {
    [self setPreferredExampleLanguage:sender.selectedSegmentIndex];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return tableView == self.tableView ? self.content.count : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tableView == self.tableView ? (self.content[section]).isCollapsed ? 1 : (self.content[section]).contentDescriptors.count : self.searchContent.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return tableView == self.tableView ? (self.content[section]).headerView : nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const PSCCellIdentifier = @"PSCatalogCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PSCCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:PSCCellIdentifier];
    }

    PSCContent *contentDescriptor = [self contentDescriptorForIndexPath:indexPath tableView:tableView];
    cell.textLabel.text = contentDescriptor.title;
    cell.detailTextLabel.text = contentDescriptor.contentDescription;
    cell.detailTextLabel.textColor = UIColor.darkGrayColor;
    cell.accessoryView = [self accessoryViewForTableView:tableView cellForRowAtIndexPath:indexPath];

    return cell;
}

- (UIView *)accessoryViewForTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIImageView *badgeView = [[UIImageView alloc] init];
    UIImage *arrowImage = [PSPDFKit imageNamed:@"arrow-right-landscape"];
    UIImageView *arrowView = [[UIImageView alloc] initWithImage:arrowImage];
    arrowView.contentMode = UIViewContentModeCenter;
    arrowView.alpha = 0.3;

    if (indexPath.section > 0 && indexPath.row == 0) {
        // Make arrow point down/up when the cell is the "header cell" of the section.
        if (self.content[indexPath.section].isCollapsed) {
            arrowView.transform = CGAffineTransformMakeRotation((CGFloat)M_PI_2);
        } else {
            arrowView.transform = CGAffineTransformMakeRotation((CGFloat)-M_PI_2);
        }
    } else {
        // Set the appropriate badge for example cells and add a standard disclosure.
        PSCContent *contentDescriptor = [self contentDescriptorForIndexPath:indexPath tableView:tableView];
        BOOL isSwift = contentDescriptor.example.isSwift;
        badgeView.image = [UIImage imageNamed:isSwift ? @"swift-badge" : @"objc-badge"];
        arrowView.image = arrowImage.imageFlippedForRightToLeftLayoutDirection;
    }

    UIStackView *accessoryView = [[UIStackView alloc] initWithArrangedSubviews:@[badgeView, arrowView]];
    accessoryView.spacing = 8;
    accessoryView.axis = UILayoutConstraintAxisHorizontal;
    CGSize size = [accessoryView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    accessoryView.bounds = (CGRect) {.size = size};
    return accessoryView;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PSCContent *contentDescriptor = [self contentDescriptorForIndexPath:indexPath tableView:tableView];

    __block NSIndexPath *unfilteredIndexPath;
    if (tableView == self.tableView) {
        // Expand/collapse section
        if (indexPath.section > 0 && indexPath.row == 0) {
            PSCSectionDescriptor *section = self.content[indexPath.section];
            section.isCollapsed = !section.isCollapsed;
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            return;
        }

        unfilteredIndexPath = indexPath;
    } else {
        // Find original index path so we can persist.
        [self.content enumerateObjectsUsingBlock:^(PSCSectionDescriptor *section, NSUInteger sectionIndex, BOOL *stop) {
            [section.contentDescriptors enumerateObjectsUsingBlock:^(PSCContent *content, NSUInteger contentIndex, BOOL *stop2) {
                if (content == contentDescriptor) {
                    unfilteredIndexPath = [NSIndexPath indexPathForRow:contentIndex inSection:sectionIndex];
                    *stop = YES;
                    *stop2 = YES;
                }
            }];
        }];
    }
    [self saveAppStateIfPossible];

    PSCExample *example = contentDescriptor.example;

    UIViewController *controller = [example invokeWithDelegate:self];
    if (!controller) {
        // No controller returned, maybe the example just presented an alert controller.
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    if (example.wantsModalPresentation) {
        UINavigationController *navController;
        if ([controller isKindOfClass:UINavigationController.class]) {
            navController = (id)controller;
        } else {
            if (example.embedModalInNavigationController) {
                navController = [[PSPDFNavigationController alloc] initWithRootViewController:controller];
            }
            if (example.customizations) {
                example.customizations(navController);
            }

            navController.popoverPresentationController.sourceView = [tableView cellForRowAtIndexPath:indexPath] ?: tableView;
        }
        navController.navigationBar.prefersLargeTitles = example.prefersLargeTitles;
        [self presentViewController:navController ?: controller animated:YES completion:nil];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        if ([controller isKindOfClass:[UINavigationController class]]) {
            controller = ((UINavigationController *)controller).topViewController;
        }
        self.navigationController.navigationBar.prefersLargeTitles = example.prefersLargeTitles;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFDocumentDelegate

- (void)pdfDocumentDidSave:(PSPDFDocument *)document {
    PSCLog(@"\n\nSaving of %@ successful.", document);
}

- (void)pdfDocument:(PSPDFDocument *)document saveDidFailWithError:(NSError *)error {
    PSCLog(@"\n\n Warning: Saving of %@ failed: %@", document, error);
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UISearchResultsUpdating and content filtering

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    UISearchBar *searchBar = searchController.searchBar;
    [self filterContentForSearchText:searchBar.text scope:searchBar.scopeButtonTitles[searchBar.selectedScopeButtonIndex]];
}

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope {
    NSMutableArray *filteredContent = [NSMutableArray array];

    if (searchText.length > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.title CONTAINS[cd] %@ AND self.isSectionHeader = NO", searchText];
        for (PSCSectionDescriptor *section in self.content) {
            [filteredContent addObjectsFromArray:[section.contentDescriptors filteredArrayUsingPredicate:predicate]];
        }
    }
    self.searchContent = filteredContent;

    [((UITableViewController *)self.searchController.searchResultsController).tableView reloadData];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Debug Helper

- (void)addDebugButtons {
#ifdef PSPDF_USE_SOURCE
    UIBarButtonItem *memoryButton = [[UIBarButtonItem alloc] initWithTitle:@"Memory" style:UIBarButtonItemStylePlain target:self action:@selector(debugCreateLowMemoryWarning)];
    self.navigationItem.leftBarButtonItem = memoryButton;

    UIBarButtonItem *cacheButton = [[UIBarButtonItem alloc] initWithTitle:@"Cache" style:UIBarButtonItemStylePlain target:self action:@selector(debugClearCache)];
    self.navigationItem.rightBarButtonItem = cacheButton;
#endif
}

// Only for debugging - this will get you rejected on the App Store!
- (void)debugCreateLowMemoryWarning {
    PSC_SILENCE_CALL_TO_UNKNOWN_SELECTOR([UIApplication.sharedApplication performSelector:NSSelectorFromString([NSString stringWithFormat:@"_%@Warning", @"performMemory"])];)

        // Clear any reference of items that would retain controllers/pages.
        [UIMenuController.sharedMenuController setMenuItems:nil];
}

- (void)debugClearCache {
    [PSPDFKit.sharedInstance.renderManager.renderQueue cancelAllTasks];
    [PSPDFKit.sharedInstance.cache clearCache];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCExampleRunner

- (nullable UIViewController *)currentViewController {
    return self;
}

- (void)saveAppStateIfPossible {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    NSIndexPath *currentSamplePath = self.tableView.indexPathForSelectedRow;
    if (currentSamplePath) {
        [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:currentSamplePath] forKey:PSCLastIndexPath];
    } else {
        [defaults removeObjectForKey:PSCLastIndexPath];
    }
    [defaults synchronize];
}

@end
