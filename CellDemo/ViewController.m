//
//  ViewController.m
//  CellDemo
//
//  Created by lanou on 15/12/29.
//  Copyright © 2015年  All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *tableView;
/**
 *  数据源数组
 */
@property (nonatomic,strong) NSMutableArray *dataArray;
/**
 *  存储选择要删除数据数组
 */
@property (nonatomic,strong) NSMutableArray *deleteArray;
/**
 *  全选按钮
 */
@property (nonatomic,strong) UIButton *selectAllBtn;
/**
 *  选择按钮
 */
@property (nonatomic,strong) UIButton *selectedBtn;
/**
 *  辅助视图(上面放的是删除按钮)
 */
@property (nonatomic,strong) UIView *baseView;
@end

static NSString *CELLID = @"Cell";
@implementation ViewController
/**
 * 数据源数组 假数据
 *
 */
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        self.dataArray = [NSMutableArray array];
        for (int i = 0; i< 50; i++) {
            NSString *string = [NSString stringWithFormat:@"string%d",arc4random()%100];
            [_dataArray addObject:string];
        }
    }
    return _dataArray;
}
/**
 * 存储要删除的数据的数组
 *
 */
- (NSMutableArray *)deleteArray
{
    if (!_deleteArray) {
        _deleteArray = [NSMutableArray array];
    }
    return _deleteArray;
}
/**
 *  懒加载UITableView
 */
- (UITableView *)tableView
{
    if (!_tableView) {
        self.tableView = [[UITableView alloc]initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CELLID];
    }
    return _tableView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    [self getButton];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.baseView];
}
/**
 *  创建选择 全选 删除按钮
 */
- (void)getButton
{
#pragma mark 选择按钮
    UIButton *selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    selectedBtn.frame = CGRectMake(0, 0, 60, 30);
    selectedBtn.backgroundColor = [UIColor blueColor];
    [selectedBtn setTitle:@"选择" forState:UIControlStateNormal];
    [selectedBtn addTarget:self action:@selector(selectedAction:) forControlEvents:UIControlEventTouchUpInside];
    self.selectedBtn = selectedBtn;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:selectedBtn];
    
#pragma mark 全选按钮
    UIButton *selectAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    selectAllBtn.frame = CGRectMake(0, 0, 100, 30);
    selectAllBtn.backgroundColor = [UIColor blueColor];
    [selectAllBtn setTitle:@"全选" forState:UIControlStateNormal];
    [selectAllBtn addTarget:self action:@selector(selectAllAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:selectAllBtn];
    selectAllBtn.hidden = YES;//全选按钮默认是隐藏的,只有选择了编辑才会显示
    self.selectAllBtn = selectAllBtn;
    
    
#pragma mark 删除按钮
    UIView *baseView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60)];
    baseView.backgroundColor = [UIColor redColor];
    baseView.hidden = YES;//删除按钮默认是隐藏的,只有选择了编辑才会显示
    self.baseView = baseView;
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteBtn.frame = CGRectMake(0, 0, self.view.frame.size.width, 60);
    deleteBtn.backgroundColor = [UIColor redColor];
    [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    [baseView addSubview:deleteBtn];

}

#pragma mark 按钮方法
//选择按钮方法
- (void)selectedAction:(UIButton *)btn
{
    //允许支持同时多选多行
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.tableView.editing = !self.tableView.editing;//点击按钮可以切换tableView的编辑状态
    
    if (!self.selectAllBtn.hidden) {//全选按钮不是选择状态就把删除按钮隐藏掉
        _baseView.hidden =YES;
    }
    
    if (self.dataArray.count) {//如果全部删除了 按钮就不再处理事件
        if (self.tableView.editing) {//编辑时 显示全选按钮 并更改按钮文字
            _selectAllBtn.hidden = NO;
            _baseView.hidden = NO;
            [btn setTitle:@"完成" forState:UIControlStateNormal];
        }else
        {
            _selectAllBtn.hidden = YES;
            [btn setTitle:@"选择" forState:UIControlStateNormal];
        }
    }else{
        [btn setTitle:@"选择" forState:UIControlStateNormal];
    }
    
}

//全选按钮方法 遍历全部的数据源 将数据源数组所有数据添加到删除数组中
- (void)selectAllAction:(UIButton *)btn
{
    if ([btn.titleLabel.text isEqualToString:@"全选"]) {
        [btn setTitle:@"取消选择" forState:UIControlStateNormal];
        for (int i = 0; i<self.dataArray.count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];//0组下的每一个索引
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];//选中cell并有动画效果 一下子到底部
            [self.deleteArray addObjectsFromArray:self.dataArray];//把数据源数组添加到删除数组中
        }
    }else if ([btn.titleLabel.text isEqualToString:@"取消选择"]){//点击取消选择的时候将选择状态全部取消 并将删除数组清空
        [btn setTitle:@"全选" forState:UIControlStateNormal];
        for (int i = 0; i<self.deleteArray.count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        [self.deleteArray removeAllObjects];
    }
}
//删除按钮方法
- (void)deleteAction:(UIButton *)btn
{
    if (self.tableView.editing) {//判断是否是编辑状态 是才删除
        [self.dataArray removeObjectsInArray:self.deleteArray];//将数据源数组中包含有删除数组中的数据删除掉
        
        [self.deleteArray removeAllObjects];//将删除数组清空
        self.selectAllBtn.hidden = YES;
        
        
        [self.selectAllBtn setTitle:@"全选" forState:UIControlStateNormal];
        [self.tableView reloadData];//刷新表格
        self.baseView.hidden = YES;
        self.tableView.editing = NO;
        [self.selectedBtn setTitle:@"选择" forState:UIControlStateNormal];
    }else{
        return;
    }

}

#pragma  mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

//是否允许编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//编辑样式(删除)
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

//选中Cell时将选中行在数据源中的数据添加到删除数组中(在编辑状态下)
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView.editing) {
        [self.deleteArray addObject:[self.dataArray objectAtIndex:indexPath.row]];
    }
    
}

//取消选中时 将存放在删除数组中的数据删除(在编辑状态下)
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView.editing) {
        [self.deleteArray removeObject:[self.dataArray objectAtIndex:indexPath.row]];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELLID forIndexPath:indexPath];
    
    cell.textLabel.text = self.dataArray[indexPath.row];
    
    return cell;
}

#pragma mark 侧滑出现更多按钮 按钮可以加很多个 在按钮的block回调里面处理事件就好了
-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        //1.更新数据
        [_dataArray removeObjectAtIndex:indexPath.row];
        //2.更新UI
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    
    UITableViewRowAction *topRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"置顶" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        //1.更新数据
        [_dataArray exchangeObjectAtIndex:indexPath.row withObjectAtIndex:0];
        //2.刷新UI
        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForItem:0 inSection:indexPath.section];
        [tableView moveRowAtIndexPath:indexPath toIndexPath:firstIndexPath];
        [self.tableView reloadData];//加上这个好点
    }];
    //还可以给按钮自定义颜色(放图片也是可以的,是不是很方便?)
    topRowAction.backgroundColor = [UIColor blueColor];
    
    return @[deleteRowAction,topRowAction];//显示在cell上面的顺序是根据数组的先后顺序的
}
@end
