//
//  UITableView+NoteView.h
//  TableViewNoteViewDemo
//
//  Created by kirito_song on 17/1/18.
//  Copyright © 2017年 kirito_song. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (NoteView)
//支持自定义noteView
@property (nonatomic) UIView * noteView;


//refreshBtnImg为nil则不展示Btn
- (void)addNoteViewWithpicName:(NSString *)picName noteText:(NSString *)noteText refreshBtnImg:(NSString *)btnImg;

@end
