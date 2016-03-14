//
// Copyright (C) Posten Norge AS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <UIKit/UIKit.h>

@interface UITableView (Reorder)

@property (nonatomic) BOOL isDeletingRow;
@property (nonatomic) BOOL allowsLongPressToReorder;
@property (nonatomic) BOOL allowsLongPressToReorderDuringEditing;

// Add this method to your tableview datasource method to correct the number of
// rows in a section during an active move like this:
//	- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section {
//		NSInteger rowCount = [self.tableData[section] count];
//		rowCount = [tableView adjustedValueForReorderingOfRowCount: rowCount forSection: section];
//		return rowCount;
//	}
- (NSInteger) adjustedValueForReorderingOfRowCount: (NSInteger) rowCount forSection: (NSInteger) section;

// Use this method to translate the index path during an active move
- (NSIndexPath *) dataSourceIndexPathFromVisibleIndexPath: (NSIndexPath *) indexPath;

// Use this method to determine whether the 'empty' place-holder cell should be returned.
- (BOOL) shouldSubstitutePlaceHolderForCellBeingMovedAtIndexPath: (NSIndexPath *) indexPath;

// If you want to connect your own gesture recognizer
// just set its target as the tableView and its action as:
- (void) rowReorderGesture: (UIGestureRecognizer *) gesture;

@end



@protocol UITableViewDataSourceReorderExtension <NSObject>
@optional
// This method, if added to the tableView data source object, can return a
// view that is dragged up and down the screen for reordering. Note: This view
// must have the same height as the cell that is being moved.
- (UIView *) tableView: (UITableView *) tableView snapShotViewOfCellAtIndexPath: (NSIndexPath *) indexPath;
@end



@protocol UITableViewDelegateReorderExtension <NSObject>
@optional
- (void) tableView: (UITableView *) tableView beganMovingRowAtPoint: (CGPoint) point;
- (void) tableView: (UITableView *) tableView changedPositionOfRowAtPoint: (CGPoint) point;
- (void) tableView: (UITableView *) tableView endedMovingRowAtPoint: (CGPoint) point;
- (void) tableView: (UITableView *) tableView beganMovingRowAtPoint: (CGPoint) point withSnapShotViewOfDraggingRow: (UIView*) snapShotView;
- (void) tableView: (UITableView *) tableView willMoveRowAtIndexPath: (NSIndexPath *) indexPath;
- (void) tableView: (UITableView *) tableView willMovePlaceHolderFromIndexPath: (NSIndexPath *) fromIndexPath toIndexPath: (NSIndexPath *) toIndexPath;
- (void) tableView: (UITableView *) tableView didMovePlaceHolderFromIndexPath: (NSIndexPath *) fromIndexPath toIndexPath: (NSIndexPath *) toIndexPath;
- (BOOL) cancelLongPressMoveResetsToOriginalState;
@end