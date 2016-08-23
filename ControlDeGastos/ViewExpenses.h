//
//  ViewExpenses.h
//  ControlDeGastos
//
//  Created by Christian Barragan on 20/08/16.
//  Copyright © 2016 Christian Barragan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddNewExpense.h"

@interface ViewExpenses : UIViewController <UITableViewDelegate, UITableViewDataSource, AddNewExpenseDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblExpenses;

@end
