//
//  CustomNavigationController.m
//  Eboticon1.2
//
//  Created by Troy Nunnally on 10/21/15.
//  Copyright © 2015 Incling. All rights reserved.
//

#import "CustomNavigationController.h"
#import "GifDetailViewController.h"

@interface CustomNavigationController ()

@end

@implementation CustomNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    if([[self.viewControllers lastObject] class] == [GifDetailViewController class]){
        
//        UINavigationItem *topItem = self.navigationBar.topItem;
//        //if this doesn't work you could try the leftBarButtons array to nil
//        topItem.hidesBackButton = YES;
//        return [super popViewControllerAnimated:NO];
        
        
        return [super popViewControllerAnimated:animated];
    }
    else {
        return [super popViewControllerAnimated:animated];
    }
}





/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
