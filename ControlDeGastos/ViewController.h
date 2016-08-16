//
//  ViewController.h
//  ControlDeGastos
//
//  Created by Christian Barragan on 15/08/16.
//  Copyright © 2016 Christian Barragan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddNewExpense.h"

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, AddNewExpenseDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblPeople;

-(IBAction)addNewRecord:(id)sender;

@end

