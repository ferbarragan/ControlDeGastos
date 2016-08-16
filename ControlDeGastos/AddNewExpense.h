//
//  AddNewExpense.h
//  ControlDeGastos
//
//  Created by Christian Barragan on 15/08/16.
//  Copyright © 2016 Christian Barragan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddNewExpenseDelegate

-(void)editingInfoWasFinished;

@end

@interface AddNewExpense : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtFirstname;

@property (weak, nonatomic) IBOutlet UITextField *txtLastname;

@property (weak, nonatomic) IBOutlet UITextField *txtAge;

@property (nonatomic, strong) id<AddNewExpenseDelegate> delegate;

@property (nonatomic) int recordIDToEdit;

- (IBAction)saveInfo:(id)sender;

@end
