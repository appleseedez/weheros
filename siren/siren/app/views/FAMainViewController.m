//
//  FAMainViewController.m
//  siren
//
//  Created by Zeus on 14-4-23.
//  Copyright (c) 2014年 weheros. All rights reserved.
//

#import "FAMainViewController.h"
#import "FACore.h"
@interface FAMainViewController ()
@property(nonatomic, strong) FACore *core;
@end
@implementation FAMainViewController
- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}
- (instancetype)init {
  self = [super init];
  if (self) {
    self.core = [FACore new];
  }
  return self;
}
- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
