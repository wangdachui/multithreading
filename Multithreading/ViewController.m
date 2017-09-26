//
//  ViewController.m
//  Multithreading
//
//  Created by 王涛 on 2017/9/14.
//  Copyright © 2017年 王涛. All rights reserved.
//

#import "ViewController.h"
#import "GCDVC.h"
#import "NSOperationVC.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray *datasourceArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.datasourceArray = @[@"GCD",@"NSOperation",@"Swift"];
   
}


#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.datasourceArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = self.datasourceArray[indexPath.section];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [self.navigationController pushViewController:[GCDVC new] animated:YES];
    } else if (indexPath.section == 1) {
        [self.navigationController pushViewController:[NSOperationVC new] animated:YES];
    } else if (indexPath.section == 2) {
        
    }
}

@end
