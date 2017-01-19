//
//  ViewController.m
//  TableViewNoteViewDemo
//
//  Created by kirito_song on 16/9/1.
//  Copyright © 2016年 kirito_song. All rights reserved.
//

#import "ViewController.h"
#import "UITableView+Empty.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic) UITableView * tableView;

@property (nonatomic) NSInteger numberOfSections;

@property (nonatomic) UIView * noteView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.numberOfSections = 0;
    // Do any additional setup after loading the view, typically from a nib.
    self.tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    //默认
    [self addNoteView];
    //自定义
//    [self addCustomNoteView];
    
    [self.tableView reloadData];
}

- (void)addNoteView {
    [self.tableView addNoteViewWithpicName:@"bg_no_grab" noteText:@"我们的需求是btn刷新、硬要下拉刷新看类别里" refreshBtnImg:@"detail_btn_filladdress.png"];
}

- (void)addCustomNoteView {
    UILabel * customNoteView = [[UILabel alloc]initWithFrame:CGRectMake(100, 100, 200, 100)];
    customNoteView.numberOfLines = 0;
    customNoteView.text = @"I am the Custom NoteView I am the Custom NoteView I am the Custom NoteView I am the Custom NoteView I am the Custom NoteView I am the Custom NoteView I am the Custom NoteView I am the Custom NoteView ";
    self.tableView.noteView = customNoteView;
}




- (IBAction)btn1Click:(id)sender {
    self.numberOfSections ++;
    [self.tableView reloadData];
}

- (IBAction)btn2Click:(id)sender {
    self.numberOfSections --;
    if (self.numberOfSections < 0 ) {
        self.numberOfSections = 0;
    }
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((section%2)==0)?1:2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [UITableViewCell new];
    cell.backgroundColor = ((indexPath.row%2)==0)?[UIColor orangeColor]:[UIColor greenColor];;
    return cell;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
