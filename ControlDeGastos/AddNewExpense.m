//
//  AddNewExpense.m
//  ControlDeGastos
//
//  Created by Christian Barragan on 15/08/16.
//  Copyright © 2016 Christian Barragan. All rights reserved.
//

#import "AddNewExpense.h"
#import "DBManager.h"

#define AMOUNT_BIT_MASK     (0x01)
#define DATE_BIT_MASK       (0x02)
#define DESCR_BIT_MASK      (0x04)
#define PAYMET_BIT_MASK     (0x08)
#define CATEG_BIT_MASK      (0x10)

#define INPUT_DATA_IS_VALID (AMOUNT_BIT_MASK|DATE_BIT_MASK|DESCR_BIT_MASK|PAYMET_BIT_MASK|CATEG_BIT_MASK)

@interface AddNewExpense ()

/* Object of Database Manage class. */
@property (nonatomic, strong) DBManager *dbManager;

/* Information pickers */
@property (nonatomic, strong) UIPickerView *pickerPayMethod;
@property (nonatomic, strong) UIPickerView *pickerCategory;
@property (nonatomic, strong) UIDatePicker *datePicker;

/* Arrays to hold the picker's information */
@property (nonatomic, strong) NSMutableArray *arrPickerPayMethod;
@property (nonatomic, strong) NSMutableArray *arrPickerCategory;

/* SQL formatted fields */
@property NSDecimalNumber   *sqlExpAmt; /* Expense amount. */
@property NSString          *sqlExpDes; /* Expense description. */
@property NSString          *sqlExpDat; /* Expense date. */
@property NSInteger          sqlExpPay; /* Expense pay method, in expense table this is a foreign key. */
@property NSInteger          sqlExpCat; /* Expense category, in expense table this is a foreign key. */



@property NSInteger lastPayMethodArrayIndex;
@property NSInteger lastCategoryArrayIndex;
@property NSString * lastAmountEntered;
@property char u8InputDataVality;

-(void)textFieldAmountEntered;
-(void)textFieldSetDefaultValue:(UITextField *)texField;
-(void)loadInfoToEdit;
-(void)closePayMethodPickerView;
-(void)closeCategoryPickerView;
-(void)loadPickerData;
-(void)restoreInputsToEdit;

@end

@implementation AddNewExpense

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* Add programatically a scroll view. */
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    scrollView.contentSize = CGSizeMake(320, 800);
    scrollView.showsHorizontalScrollIndicator = YES;
    [self.view addSubview:scrollView];
    /* Add the text fields to the scroll view. */
    [scrollView addSubview:self.txtAmount];
    [scrollView addSubview:self.txtDate];
    [scrollView addSubview:self.txtDescription];
    [scrollView addSubview:self.txtCategory];
    [scrollView addSubview:self.txtPayMethod];
    [scrollView addSubview:self.btnSaveInfo];
    
    /* Initialize the dbManager object. */
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"expense_db.sql"];
    
    [self loadPickerData];
    
    self.lastPayMethodArrayIndex = 0;
    self.lastCategoryArrayIndex = 0;
    self.lastAmountEntered = [[NSString alloc] init];
    
    /* Fixed test arrays. */
    //self.arrPickerPayMethod = [[NSArray alloc] initWithObjects:@"1",@"2",@"3", nil];
    //self.arrPickerCategory  = [[NSArray alloc] initWithObjects:@"4",@"5",@"6", nil];
    
}
/* ------------------------------------------------------------------------------------------------------------------ */

- (void) viewWillAppear:(BOOL)animated {
    
    /* Make self the delegate of the textfields. */
    self.txtAmount.delegate = self;
    self.txtDescription.delegate = self;
    self.txtPayMethod.delegate = self;
    self.txtCategory.delegate = self;
    
    
    /* Amount Text Field tool bar configuration. */
    UIToolbar *txtFieldAmountToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [txtFieldAmountToolBar setTintColor:[UIColor grayColor]];
    UIBarButtonItem *txtFieldAmountToolBarDoneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Listo" style:UIBarButtonItemStylePlain target:self action:@selector(textFieldAmountEntered)];
    UIBarButtonItem *txtFieldAmountToolBarSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [txtFieldAmountToolBar setItems:[NSArray arrayWithObjects:txtFieldAmountToolBarSpace, txtFieldAmountToolBarDoneBtn, nil]];
    [self.txtAmount setInputAccessoryView:txtFieldAmountToolBar];
    
    
    /* Pay method Picker configuration. */
    self.pickerPayMethod = [[UIPickerView alloc]init];
    self.pickerPayMethod.dataSource = self;
    self.pickerPayMethod.delegate = self;
    [self.pickerPayMethod setShowsSelectionIndicator:YES];
    [self.pickerPayMethod selectRow:0 inComponent:0 animated:NO];
    [self.txtPayMethod setInputView:self.pickerPayMethod];
    /* Tool bar for the Pay method Picker. */
    UIToolbar *pickerPayMethodToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [pickerPayMethodToolBar setTintColor:[UIColor grayColor]];
    UIBarButtonItem *pickerPayMethodToolBarDoneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Listo" style:UIBarButtonItemStylePlain target:self action:@selector(closePayMethodPickerView)];
    UIBarButtonItem *pickerPayMethodToolBarSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    //pickerPayMethodToolBar.items = @[pickerPayMethodToolBarDoneBtn];
    //[self.pickerPayMethod addSubview:pickerPayMethodToolBar];
    [pickerPayMethodToolBar setItems:[NSArray arrayWithObjects:pickerPayMethodToolBarSpace, pickerPayMethodToolBarDoneBtn, nil]];
    [self.txtPayMethod setInputAccessoryView:pickerPayMethodToolBar];
    [self.txtPayMethod addTarget:self action:@selector(textFieldSetDefaultValue:) forControlEvents:UIControlEventEditingDidBegin];
    
    
    /* Category Picker configuration. */
    self.pickerCategory = [[UIPickerView alloc]init];
    self.pickerCategory.dataSource = self;
    self.pickerCategory.delegate = self;
    [self.pickerCategory setShowsSelectionIndicator:YES];
    [self.pickerCategory selectRow:0 inComponent:0 animated:NO];
    [self.txtCategory setInputView:self.pickerCategory];
    /* Tool bar for the Category Picker. */
    UIToolbar *pickerCategoryToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [pickerCategoryToolBar setTintColor:[UIColor grayColor]];
    UIBarButtonItem *pickerCategoryToolBarDoneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Listo" style:UIBarButtonItemStylePlain target:self action:@selector(closeCategoryPickerView)];
    UIBarButtonItem *pickerCategoryToolBarSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    //pickerCategoryToolBar.items =  @[pickerCategoryToolBarDoneBtn];
    //[self.pickerCategory addSubview:pickerCategoryToolBar];
    [pickerCategoryToolBar setItems:[NSArray arrayWithObjects:pickerCategoryToolBarSpace, pickerCategoryToolBarDoneBtn, nil]];
    [self.txtCategory setInputAccessoryView:pickerCategoryToolBar];
    [self.txtCategory addTarget:self action:@selector(textFieldSetDefaultValue:) forControlEvents:UIControlEventEditingDidBegin];
    
    
    /* Date picket configuration */
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    [self.txtDate setInputView:self.datePicker];
    /* Tool bar for the Date Picker. */
    UIToolbar *datePickerToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [datePickerToolBar setTintColor:[UIColor grayColor]];
    UIBarButtonItem *datePickerToolBarDoneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Listo" style:UIBarButtonItemStyleDone target:self action:@selector(ShowSelectedDate)];
    UIBarButtonItem *datePickerToolBarSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [datePickerToolBar setItems:[NSArray arrayWithObjects:datePickerToolBarSpace,datePickerToolBarDoneBtn, nil]];
    [self.txtDate setInputAccessoryView:datePickerToolBar];
    
    /* Check if should load specific record for editing. */
    if (self.recordIDToEdit != -1) {
        /* Load the record with the specific ID from the database. */
        [self loadInfoToEdit];
    }
    else {
        /* A new record will be inserted. */
    }

}
/* ------------------------------------------------------------------------------------------------------------------ */

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    /* Dispose of any resources that can be recreated. */
}
/* ------------------------------------------------------------------------------------------------------------------ */

#pragma mark - TextField Methods.
/* ------------------------------------------------------------------------------------------------------------------ */
/* - TextField Methods ---------------------------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------------------------------------------------ */

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    //if (textField == self.txtAmount) {
    //    textField.placeholder = nil;
    //}
}

/* Because the numeric Keypad has no "Done" button. We had to implement ours in a 
 * custom ToolBar. This action is triggered when that button is pressed.
 * This function will trigger the delegate method textFieldShouldEndEditing
 */
-(void)textFieldAmountEntered {
    
    [self.txtAmount resignFirstResponder];
}

/* This method is called when the in-Keyboard "Done" button is pressed. 
 * Currently only the Text Field txtDescription has an in-Keyboard Done button.
 */
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    BOOL retVal = NO;
    NSString *txtFieldContent = textField.text;
    
    if ([txtFieldContent isEqualToString:@""]) {
        /* ToDo: Remove warning: Warning: Attempt to present <UIAlertController: 0x1516a000>  on
         <AddNewExpense: 0x14596d30> which is already presenting <UIAlertController: 0x151a0000> */
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                 message:@"¡Este campo no puede estar vacío!"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        /* We add buttons to the alert controller by creating UIAlertActions: */
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil]; //You can use a block here to handle a press on this button
        [alertController addAction:actionOk];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        if (textField == self.txtDescription) {
            /* Store in the variable which will be used in the SQL query, the text
             * from the TextField.
             */
            self.sqlExpDes = txtFieldContent;
            self.u8InputDataVality |= DESCR_BIT_MASK;
            
            [textField resignFirstResponder];
        }
        retVal = YES;
    }
    return retVal;
}
/* ------------------------------------------------------------------------------------------------------------------ */

/* This method is called when the user touches outside of the keyboard zone. */
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    BOOL retVal = NO;
    NSString *txtFieldContent = textField.text;
    
    if ([txtFieldContent isEqualToString:@""]) {
        /* ToDo: Remove warning: Warning: Attempt to present <UIAlertController: 0x1516a000>  on
         <AddNewExpense: 0x14596d30> which is already presenting <UIAlertController: 0x151a0000> */
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                 message:@"¡Este campo no puede estar vacío!"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        /* We add buttons to the alert controller by creating UIAlertActions: */
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil]; //You can use a block here to handle a press on this button
        [alertController addAction:actionOk];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        if (textField == self.txtAmount) {
            /* Store in the variable which will be used in the SQL query, the amount in SQL supported format. */
            NSNumberFormatter *decimalFormatter = [[NSNumberFormatter alloc] init];
            [decimalFormatter setMinimumFractionDigits:2];
            [decimalFormatter setMaximumFractionDigits:2];
            [decimalFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
            self.sqlExpAmt = [NSDecimalNumber decimalNumberWithString:self.txtAmount.text];
            self.u8InputDataVality |= AMOUNT_BIT_MASK;
            
            /* Put the entered value in the TextField in currency format. */
            NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init] ;
            [currencyFormatter setLocale:[NSLocale currentLocale]];
            [currencyFormatter setMaximumFractionDigits:2];
            [currencyFormatter setMinimumFractionDigits:2];
            [currencyFormatter setAlwaysShowsDecimalSeparator:YES];
            [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            
            NSNumber *someAmount = [NSNumber numberWithDouble:[self.txtAmount.text doubleValue]];
            NSString *string = [currencyFormatter stringFromNumber:someAmount];
            
            self.txtAmount.text = string;
            self.lastAmountEntered = string;
        }
        retVal = YES;
    }
    return retVal;
}
/* ------------------------------------------------------------------------------------------------------------------ */

-(void) textFieldDidEndEditing:(UITextField *)textField {
    //if (textField == self.txtAmount) {
    //    textField.placeholder = @"Escribe la cantidad";
    //}
}
/* ------------------------------------------------------------------------------------------------------------------ */

-(void)textFieldSetDefaultValue:(UITextField *)texField {
    if (texField == self.txtPayMethod) {
        self.txtPayMethod.text = [self.arrPickerPayMethod objectAtIndex:self.lastPayMethodArrayIndex];
        self.sqlExpPay = self.lastPayMethodArrayIndex;
        self.u8InputDataVality |= PAYMET_BIT_MASK;
    }
    else if (texField == self.txtCategory) {
        self.txtCategory.text = [self.arrPickerCategory objectAtIndex:self.lastCategoryArrayIndex];
        self.sqlExpCat = self.lastCategoryArrayIndex;
        self.u8InputDataVality |= CATEG_BIT_MASK;
    }
    else {
        /* Do nothing... */
    }
}
/* ------------------------------------------------------------------------------------------------------------------ */

#pragma mark - DatePicker Methods.
/* ------------------------------------------------------------------------------------------------------------------ */
/* - DatePicker Methods --------------------------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------------------------------------------------ */

-(void)ShowSelectedDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    /* First, store in the variable which will be used in the SQL query, the date in SQL supported format. */
    [formatter setDateFormat:@"yyyy-MM-dd"];
    self.sqlExpDat = [NSString stringWithFormat:@"%@",[formatter stringFromDate:self.datePicker.date]];
    self.u8InputDataVality |= DATE_BIT_MASK;
    /* Second, format the selected date into a 'more natural' format and put it in the text field. */
    [formatter setDateFormat:@"dd-MM-yyyy"];
    self.txtDate.text = [NSString stringWithFormat:@"%@",[formatter stringFromDate:self.datePicker.date]];
    [self.txtDate resignFirstResponder];
}
/* ------------------------------------------------------------------------------------------------------------------ */

#pragma mark - PickerView Methods.
/* ------------------------------------------------------------------------------------------------------------------ */
/* - PickerView Methods --------------------------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------------------------------------------------ */

-(void)closePayMethodPickerView {
    [self.txtPayMethod resignFirstResponder];
}
/* ------------------------------------------------------------------------------------------------------------------ */

-(void)closeCategoryPickerView {
    [self.txtCategory resignFirstResponder];
}
/* ------------------------------------------------------------------------------------------------------------------ */

-(void)loadPickerData{
    
    NSArray * arrPayMethodsFromDb;
    NSArray * arrCategoriesFromDb;
    int i;
    
    /* Form the query to fill the payMethod array. */
    NSString *query = @"select payMethod from payMethod";
    
    /* Initialize the global array. */
    if (self.arrPickerPayMethod != nil) {
        self.arrPickerPayMethod = nil;
    }
    
    /* Get the results from the database */
    arrPayMethodsFromDb = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    self.arrPickerPayMethod = [[NSMutableArray alloc] initWithCapacity:arrPayMethodsFromDb.count];
    for (i = 0; i < arrPayMethodsFromDb.count; i++) {
        [self.arrPickerPayMethod addObject:[[arrPayMethodsFromDb objectAtIndex:i] objectAtIndex:0]];
    }
    
    
    /* Form the query to fill the category array. */
    query = @"select catName from category";
    
    /* Initialize the array. */
    if (self.arrPickerCategory != nil) {
        self.arrPickerCategory = nil;
    }
    
    /* Get the results. */
    arrCategoriesFromDb = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    self.arrPickerCategory = [[NSMutableArray alloc] initWithCapacity:arrCategoriesFromDb.count];
    for (i = 0; i < arrCategoriesFromDb.count; i++) {
        [self.arrPickerCategory addObject:[[arrCategoriesFromDb objectAtIndex:i] objectAtIndex:0]];
    }
}
/* ------------------------------------------------------------------------------------------------------------------ */

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
/* ------------------------------------------------------------------------------------------------------------------ */

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == self.pickerPayMethod) {
        return [self.arrPickerPayMethod count];
    }
    else if (pickerView == self.pickerCategory) {
        return [self.arrPickerCategory count];
    }
    else {
        return 0;
    }
}
/* ------------------------------------------------------------------------------------------------------------------ */

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == self.pickerPayMethod) {
        return [self.arrPickerPayMethod objectAtIndex:row];
    }
    else if (pickerView == self.pickerCategory) {
        return [self.arrPickerCategory objectAtIndex:row];
    }
    else {
        return 0;
    }
    return @"";
}
/* ------------------------------------------------------------------------------------------------------------------ */

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == self.pickerPayMethod) {
        self.txtPayMethod.text = [self.arrPickerPayMethod objectAtIndex:row];
        self.sqlExpPay = row;
        self.u8InputDataVality |= PAYMET_BIT_MASK;
        self.lastPayMethodArrayIndex = row;
    }
    else if (pickerView == self.pickerCategory) {
        self.txtCategory.text = [self.arrPickerCategory objectAtIndex:row];
        self.sqlExpCat = row;
        self.u8InputDataVality |= CATEG_BIT_MASK;
        self.lastCategoryArrayIndex = row;
    }
    else {
        /* Nothing to do... */
    }
}

/* ------------------------------------------------------------------------------------------------------------------ */

#pragma mark - Database Methods.
/* ------------------------------------------------------------------------------------------------------------------ */
/* - Database Methods ------------------------------------------------------------------------------------------------ */
/* ------------------------------------------------------------------------------------------------------------------ */

- (IBAction)saveInfo:(id)sender {
    
    /* First check if all the TextFields are filled. */
    if (INPUT_DATA_IS_VALID == self.u8InputDataVality)
    {
        /* Prepare the query string. */
        /* If the recordIDToEdit property has value other than -1, then create an update query, otherwie create an insert query */
        NSString *query ;
        
        if (self.recordIDToEdit == -1){
            query = [NSString stringWithFormat:@"insert into expense values(null, '%@', '%@', '%@',  %d, %d)", self.sqlExpAmt, self.sqlExpDes, self.sqlExpDat, self.sqlExpPay, self.sqlExpCat];
        }
        else {
            query = [NSString stringWithFormat:@"update expense set amount='%@', description='%@', date='%@', payMethod_id=%d, category_id=%d where id=%d", self.sqlExpAmt, self.sqlExpDes, self.sqlExpDat, self.sqlExpPay, self.sqlExpCat, self.recordIDToEdit];
        }

        /* Execute the query. */
        [self.dbManager executeQuery:query];
        
        /* If the query was successfully executed then pop the view controller. */
        if (self.dbManager.affectedRows != 0) {
            NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
            
            /* Inform the delegate that the editing was finished. */
            //[self.delegate editingInfoWasFinished];
            
            /* ToDo: Remove warning: Warning: Attempt to present <UIAlertController: 0x1516a000>  on
             <AddNewExpense: 0x14596d30> which is already presenting <UIAlertController: 0x151a0000> */
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Aviso"
                                                                                     message:@"¡Gasto registrado exitosamente!"
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            /* We add buttons to the alert controller by creating UIAlertActions: */
            UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok"
                                                               style:UIAlertActionStyleDefault
                                                             handler:nil]; //You can use a block here to handle a press on this button
            [alertController addAction:actionOk];
            [self presentViewController:alertController animated:YES completion:nil];
            
            [self restoreInputsToEdit];
            
            /* Pop the view controller. */
            //[self.navigationController popViewControllerAnimated:YES];
            
        }
        else{
            NSLog(@"Could not execute the query.");
        }
    }
    else
    {
        /* ToDo: Remove warning: Warning: Attempt to present <UIAlertController: 0x1516a000>  on
         <AddNewExpense: 0x14596d30> which is already presenting <UIAlertController: 0x151a0000> */
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                 message:@"¡No puede haber campos vacíos!"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        /* We add buttons to the alert controller by creating UIAlertActions: */
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil]; //You can use a block here to handle a press on this button
        [alertController addAction:actionOk];
        [self presentViewController:alertController animated:YES completion:nil];
        
        /* Pop the view controller. */
        [self.navigationController popViewControllerAnimated:YES];
    }
}
/* ------------------------------------------------------------------------------------------------------------------ */

-(void)loadInfoToEdit{
    /* Create the query. */
    NSString *query = [NSString stringWithFormat:@"select * from expense where id=%d", self.recordIDToEdit];
    
    /* Load the relevant data. */
    NSArray *results = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    /* Set the loaded data to the textfields */
    self.txtAmount.text         = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"amount"]];
    self.txtDate.text           = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"date"]];
    self.txtDescription.text    = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"description"]];
    self.txtPayMethod.text      = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"payMethod_id"]];
    self.txtCategory.text       = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"category_id"]];
    
    self.u8InputDataVality = INPUT_DATA_IS_VALID; /* Force this, because we can say that the input data was filled by the query. */
}
/* ------------------------------------------------------------------------------------------------------------------ */

-(void) restoreInputsToEdit {
    
    /* Restore the global variables for further usage. */
    self.u8InputDataVality = 0;
    self.sqlExpAmt = nil;
    self.sqlExpDat = nil;
    self.sqlExpDes = nil;
    self.sqlExpPay = 0;
    self.sqlExpCat = 0;
    
    /* Restore the TextFields. */
    self.txtAmount.text         = nil;
    self.txtDate.text           = nil;
    self.txtDescription.text    = nil;
    self.txtPayMethod.text      = nil;
    self.txtCategory.text       = nil;

}
/* ------------------------------------------------------------------------------------------------------------------ */

@end
