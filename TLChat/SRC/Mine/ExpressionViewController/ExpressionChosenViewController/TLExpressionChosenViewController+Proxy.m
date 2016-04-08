//
//  TLExpressionChosenViewController+Proxy.m
//  TLChat
//
//  Created by 李伯坤 on 16/4/8.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import "TLExpressionChosenViewController+Proxy.h"
#import <MJRefresh.h>

@implementation TLExpressionChosenViewController (Proxy)

- (void)loadDataWithLoadingView:(BOOL)showLoadingView
{
    if (showLoadingView) {
        [SVProgressHUD show];
    }
    kPageIndex = 1;
    __weak typeof(self) weakSelf = self;
    [self.proxy requestExpressionChosenListByPageIndex:kPageIndex success:^(id data) {
        [SVProgressHUD dismiss];
        kPageIndex ++;
        weakSelf.data = data;
        [weakSelf.tableView reloadData];
    } failure:^(NSString *error) {
        [SVProgressHUD dismiss];
    }];
}

- (void)loadMoreData
{
    __weak typeof(self) weakSelf = self;
    [self.proxy requestExpressionChosenListByPageIndex:kPageIndex success:^(NSMutableArray *data) {
        [SVProgressHUD dismiss];
        if (data.count == 0) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        else {
            [self.tableView.mj_footer endRefreshing];
            kPageIndex ++;
            [weakSelf.data addObjectsFromArray:data];
            [weakSelf.tableView reloadData];
        }
    } failure:^(NSString *error) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
        [SVProgressHUD dismiss];
    }];
}

@end