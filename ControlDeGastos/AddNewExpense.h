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

@interface AddNewExpense : UIViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>


#pragma mark - User interface components
@property (weak, nonatomic) IBOutlet UITextField *txtAmount;
@property (weak, nonatomic) IBOutlet UITextField *txtDate;
@property (weak, nonatomic) IBOutlet UITextField *txtDescription;
@property (weak, nonatomic) IBOutlet UITextField *txtPayMethod;
@property (weak, nonatomic) IBOutlet UITextField *txtCategory;


@property (nonatomic, strong) id<AddNewExpenseDelegate> delegate;


#pragma mark - Global variables
@property (nonatomic) int recordIDToEdit;


#pragma mark - Action methods
- (IBAction)saveInfo:(id)sender;



@end
