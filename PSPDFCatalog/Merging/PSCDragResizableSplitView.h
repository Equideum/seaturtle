//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import <UIKit/UIKit.h>

/// Encapsulates the layout and touch handling required for a left/right split view.
/// The border between both splits can be dragged up to a 30/70 ratio.
@interface PSCDragResizableSplitView : UIView

/// Installs the specified views as the left and right view of the receiver.
- (void)installLeftView:(UIView *)leftView rightView:(UIView *)rightView;

/// Instances of this class require Autolayout.
+ (BOOL)requiresConstraintBasedLayout;

@end
