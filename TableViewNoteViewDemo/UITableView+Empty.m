//
//  UITableView+NoteView.m
//  TableViewNoteViewDemo
//
//  Created by kirito_song on 17/1/18.
//  Copyright © 2017年 kirito_song. All rights reserved.
//

#import "UITableView+Empty.h"

#import <objc/runtime.h>


static char noteViewKey = 'a';

//CategoryNoteView私有声明置于类别之前。让其在类别中正常调用
@interface CategoryNoteView : UIView

@property (nonatomic) UIButton *refreshBtn;

- (instancetype)newNoteViewInView:(UIView *)view;

- (void)addNoteViewWithpicName:(NSString *)picName noteText:(NSString *)noteText refreshBtnImg:(NSString *)btnImg;

@end


#pragma mark - 工作category
@implementation UITableView (Empty)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[UITableView new] swizzleMethod:@selector(reloadData) withMethod:@selector(KTreloadData)];
    });
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
    if (didAddMethod) {
        class_replaceMethod(class,
                            newSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (UIView *)noteView
{
    return objc_getAssociatedObject(self, &noteViewKey);
}

- (void)setNoteView:(UIView *)noteView
{
    objc_setAssociatedObject(self, &noteViewKey, noteView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (void)addNoteViewWithpicName:(NSString *)picName noteText:(NSString *)noteText refreshBtnImg:(NSString *)btnImg{
    
    CategoryNoteView *noteView = [[CategoryNoteView alloc] newNoteViewInView:self];
    [noteView addNoteViewWithpicName:picName noteText:noteText refreshBtnImg:btnImg];
    if (noteView.refreshBtn) {
        [noteView.refreshBtn addTarget:self action:@selector(noteViewBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    //self.noteView可能有两种。另一种为使用者自定义传入
    self.noteView = noteView;
}

- (void)noteViewBtnClick {
    [self.noteView removeFromSuperview];
//    demo代码里没有mj刷新~
//    if (self.mj_header) {
//        [self.mj_header beginRefreshing];
//    }
}

- (void)KTreloadData {
    [self KTreloadData];
    //这里。如果没有使用类别操作tableView。则不进行新代码注入。
    if (self.noteView) {
        [self checkDataSource];
    }
}

//工作代码~就这么几行
- (void)checkDataSource {
    //需求是没有数据则不允许下拉刷新。如果不要阻隔下拉动作。则把self.noteView置于self上、或者将self.noteView的层级调至self之下即可
    id <UITableViewDataSource> dataSource = self.dataSource;
    NSInteger numberOfSections = [dataSource numberOfSectionsInTableView:self];
    
    for (int i = 0; i < numberOfSections; i++) {
        if ( [dataSource tableView:self numberOfRowsInSection:numberOfSections] == 0) {
//            [self addSubview:self.noteView];
            [self.superview addSubview:self.noteView];
            return;
        }
    }
    if (numberOfSections == 0) {
//        [self addSubview:self.noteView];
        [self.superview addSubview:self.noteView];
        return;
    }
    [self.noteView removeFromSuperview];
}

@end



#pragma mark - NoteView
@interface CategoryNoteView()

@property (nonatomic)UIImageView *bgImgView;
@property (nonatomic)UILabel *noteLabel;
@end

@implementation CategoryNoteView

- (instancetype)newNoteViewInView:(UIView *)view {
    CGRect frame = view.bounds;
    return [self initWithFrame:frame];
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    
    [self addSubview:self.bgImgView];
    [self addSubview:self.noteLabel];
}


- (void)addNoteViewWithpicName:(NSString *)picName noteText:(NSString *)noteText refreshBtnImg:(NSString *)btnImg {
    
    self.bgImgView.image = [UIImage imageNamed:picName];
    self.noteLabel.text = noteText;
    
    if (btnImg) {
        [self addSubview:self.refreshBtn];
        [self.refreshBtn setBackgroundImage:[UIImage imageNamed:btnImg] forState:UIControlStateNormal];
        self.refreshBtn.frame = CGRectMake(0, 0, self.refreshBtn.currentBackgroundImage.size.width, self.refreshBtn.currentBackgroundImage.size.height);
    }
    
//    [self layoutCustomViews];
}

//masony~也没有
//- (void)layoutCustomViews {
//
//    UIView *  refreshBtnLayoutView = (self.noteLabel.text.length > 0)?self.noteLabel:self.bgImgView;
//    //防止一些奇怪的方式二次调用addNoteViewWithpicName导致二次约束/虽然还没出现
//    //so----mas_updateConstraints
//    [self.bgImgView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self);
//        make.centerY.mas_equalTo(self).offset(- 20 - self.bgImgView.image.size.height/2);
//        make.width.mas_equalTo(self.bgImgView.image.size.width);
//        make.height.mas_equalTo(self.bgImgView.image.size.height);
//    }];
//
//    [self.noteLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self);
//        make.top.mas_equalTo(self.bgImgView.mas_bottom).offset(20);
//    }];
//
//    if (self.refreshBtn) {
//        [self.refreshBtn mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.centerX.equalTo(self);
//            make.top.mas_equalTo(refreshBtnLayoutView.mas_bottom).offset(20);
//        }];
//    }
//}


//demo懒得导masony~用frame凑合凑合
- (void)layoutSubviews {

    self.bgImgView.frame = CGRectMake(self.frame.size.width/2 - self.bgImgView.image.size.width/2, (self.frame.size.height - 64)/2.0 - 20 - self.bgImgView.image.size.height/2, self.bgImgView.image.size.width, self.bgImgView.image.size.height);

    self.noteLabel.frame = CGRectMake(0, CGRectGetMaxY(self.bgImgView.frame) + 20, self.frame.size.width, 20);

    if (self.refreshBtn) {

        if (self.noteLabel.text.length > 0) {
            self.refreshBtn.center = CGPointMake(self.frame.size.width/2.0, CGRectGetMaxY(self.noteLabel.frame) + 25 + self.refreshBtn.currentBackgroundImage.size.height / 2.0);
        }else {
            //无提示文字时、将btn上移
            self.refreshBtn.center = CGPointMake(self.frame.size.width/2.0, CGRectGetMaxY(self.bgImgView.frame) + 25 + self.refreshBtn.currentBackgroundImage.size.height / 2.0);
        }
    }
}

- (UIImageView *)bgImgView {
    if (!_bgImgView) {
        _bgImgView = [UIImageView new];
    }
    return _bgImgView;
}

- (UILabel *)noteLabel {
    if (!_noteLabel) {
        _noteLabel = [[UILabel alloc] init];
        _noteLabel.textAlignment = NSTextAlignmentCenter;
        _noteLabel.font = [UIFont systemFontOfSize:13.0];
//        _noteLabel.textColor = [UIColor hexChangeFloat:@"a3a3a3"];
    }
    return _noteLabel;
}

- (UIButton *)refreshBtn {
    if (!_refreshBtn) {
        _refreshBtn = [[UIButton alloc] init];
//        _refreshBtn.eventInterval = 3.0;
    }
    return _refreshBtn;
}

@end
