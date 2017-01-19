//
//  UIScrollView+noteView.m
//  TableViewNoteViewDemo
//
//  Created by kirito_song on 16/9/1.
//  Copyright © 2016年 kirito_song. All rights reserved.
//

#import "UIScrollView+noteView.h"
#import <objc/runtime.h>


static char noteViewKey = 'a';

@implementation UIScrollView (noteView)

- (void)addNoteView {
    
    [self swizzleMethod:@selector(reloadData) withMethod:@selector(KTreloadData)];
    
    [self setNoteViewWithTableView:(UITableView *)self];
}


- (void)swizzleMethod:(SEL)origSelector withMethod:(SEL)newSelector
{
    Class class = [self class];
    
    Method originalMethod = class_getInstanceMethod(class, origSelector);
    Method swizzledMethod = class_getInstanceMethod(class, newSelector);
    
    BOOL didAddMethod = class_addMethod(class,
                                        origSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    NSLog(@"didAddMethod----%d",didAddMethod);
    if (didAddMethod) {
        class_replaceMethod(class,
                            newSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}




- (void)KTreloadData {
    [(UITableView *)self KTreloadData];
//    NSLog(@"1111");
    [self checkDataSource];
}


- (UIView *)noteView
{
    return objc_getAssociatedObject(self, &noteViewKey);
}

- (void)setNoteView:(UIView *)noteView
{
    objc_setAssociatedObject(self, &noteViewKey, noteView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (void)setNoteViewWithTableView:(UITableView *)tableview {
    self.noteView = [[UIView alloc]initWithFrame:tableview.frame];
    self.noteView.backgroundColor = [UIColor greenColor];
}

- (void)checkDataSource {
    NSLog(@"当前VC-----%@",((UITableView *)(self)).dataSource);
    id <UITableViewDataSource> dataSource = ((UITableView *)(self)).dataSource;
    NSInteger numberOfSections = [dataSource numberOfSectionsInTableView:((UITableView *)(self))];
    
    for (int i = 0; i < numberOfSections; i++) {
        if ( [dataSource tableView:((UITableView *)(self)) numberOfRowsInSection:numberOfSections] == 0) {
            [self addSubview:self.noteView];
            return;
        }
    }
    if (numberOfSections == 0) {
        [self addSubview:self.noteView];
        return;
    }
    [self.noteView removeFromSuperview];
}



@end
