//
//  AddNewExpense.m
//  ControlDeGastos
//
//  Created by Christian Barragan on 15/08/16.
//  Copyright © 2016 Christian Barragan. All rights reserved.
//

#import "AddNewExpense.h"
#import "DBManager.h"

@interface AddNewExpense ()

@property (nonatomic, strong) DBManager *dbManager;

@property (nonatomic, strong) NSArray *arrPickerPayMethod;
@property (nonatomic, strong) NSArray *arrPickerCategory;
@property (nonatomic, strong) UIPickerView *pickerPayMethod;
@property (nonatomic, strong) UIPickerView *pickerCategory;
@property (nonatomic, strong) UIDatePicker *datePicker;


-(void)loadInfoToEdit;

@end

@implementation AddNewExpense

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* Make self the delegate of the textfields. */
    self.txtAmount.delegate = self;
    self.txtDescription.delegate = self;
    
    /* Initialize the dbManager object. */
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"expense_db.sql"];
    
    /* Check if should load specific record for editing. */
    if (self.recordIDToEdit != -1)
    {
        /* Load the record with the specific ID from the database. */
        [self loadInfoToEdit];
    }
    else {
        /* A new record will be inserted. */
    }
    
    self.arrPickerPayMethod = [[NSArray alloc] initWithObjects:@"1", @"2", @"3", nil];
    self.arrPickerCategory = [[NSArray alloc] initWithObjects:@"4", @"5", @"6", nil];
    
    self.pickerPayMethod = [[UIPickerView alloc]init];
    self.pickerPayMethod.dataSource = self;
    self.pickerPayMethod.delegate = self;
    [self.pickerPayMethod setShowsSelectionIndicator:YES];
    [self.pickerPayMethod selectRow:0 inComponent:0 animated:NO];
    [self.txtPayMethod setInputView:self.pickerPayMethod];
    
    UIToolbar *pickerPayMethodToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [pickerPayMethodToolBar setTintColor:[UIColor grayColor]];
    UIBarButtonItem *pickerPayMethodToolBarDoneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Listo" style:UIBarButtonItemStylePlain target:self action:@selector(ClosePickerToolBar)];
    pickerPayMethodToolBar.items = @[pickerPayMethodToolBarDoneBtn];
    [self.pickerPayMethod addSubview:pickerPayMethodToolBar];
    
    /*
    UIBarButtonItem *pickerPayMethodToolBarSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [pickerPayMethodToolBar setItems:[NSArray arrayWithObjects:pickerPayMethodToolBarSpace,pickerPayMethodToolBarDoneBtn, nil]];
    [self.txtPayMethod setInputAccessoryView:pickerPayMethodToolBar];
    */
    
    self.pickerCategory = [[UIPickerView alloc]init];
    self.pickerCategory.dataSource = self;
    self.pickerCategory.delegate = self;
    [self.pickerCategory setShowsSelectionIndicator:YES];
    [self.pickerCategory selectRow:0 inComponent:0 animated:NO];
    [self.txtCategory setInputView:self.pickerCategory];
    
    UIToolbar *pickerCategoryToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [pickerCategoryToolBar setTintColor:[UIColor grayColor]];
    UIBarButtonItem *pickerCategoryToolBarDoneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Listo" style:UIBarButtonItemStylePlain target:self action:@selector(ClosePickerToolBar)];
    UIBarButtonItem *pickerCategoryToolBarSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [pickerCategoryToolBar setItems:[NSArray arrayWithObjects:pickerCategoryToolBarSpace,pickerCategoryToolBarDoneBtn, nil]];
    [self.txtCategory setInputAccessoryView:pickerCategoryToolBar];
    
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    [self.txtDate setInputView:self.datePicker];
    
    UIToolbar *datePickerToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [datePickerToolBar setTintColor:[UIColor grayColor]];
    UIBarButtonItem *datePickerToolBarDoneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Listo" style:UIBarButtonItemStylePlain target:self action:@selector(ShowSelectedDate)];
    UIBarButtonItem *datePickerToolBarSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [datePickerToolBar setItems:[NSArray arrayWithObjects:datePickerToolBarSpace,datePickerToolBarDoneBtn, nil]];
    [self.txtDate setInputAccessoryView:datePickerToolBar];
    
    
}

-(void)ClosePickerToolBar:(id)sender
{
    [self.txtDate resignFirstResponder];
}

-(void)ShowSelectedDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/mm/yyyy"];
    self.txtDate.text = [NSString stringWithFormat:@"%@",[formatter stringFromDate:self.datePicker.date]];
    [self.txtDate resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    /* Dispose of any resources that can be recreated. */
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - DatePicker Methods.



#pragma mark - PickerView Methods.
/* ------------------------------------------------------------------------------------------------------------------ */
/* - PickerView Methods --------------------------------------------------------------------------------------------- */
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
    }
    else if (pickerView == self.pickerCategory) {
        self.txtCategory.text = [self.arrPickerCategory objectAtIndex:row];
    }
    else {
        /* Nothing to do... */
    }
}
/* ------------------------------------------------------------------------------------------------------------------ */

#pragma mark - Database Methods.
/* ------------------------------------------------------------------------------------------------------------------ */
/* - Datbase Methods ------------------------------------------------------------------------------------------------ */
/* ------------------------------------------------------------------------------------------------------------------ */

- (IBAction)saveInfo:(id)sender {
    /* Prepare the query string. */
    /* If the recordIDToEdit property has value other than -1, then create an update query, otherwie create an insert query */
    NSString *query ;
    if (self.recordIDToEdit == -1){
        query = [NSString stringWithFormat:@"insert into expense values(null, '%@', '%@', '%@',  %d, %d)", self.txtAmount.text, self.txtDescription.text, self.txtDate.text, [self.txtPayMethod.text intValue], [self.txtCategory.text intValue]];
    }
    else {
        query = [NSString stringWithFormat:@"update expense set amount='%@', description='%@', payMethod_id=%d, category_id=%d where id=%d", self.txtAmount.text, self.txtDescription.text, self.txtPayMethod.text.intValue, self.txtCategory.text.intValue, self.recordIDToEdit];
    }
    
    /* Execute the query. */
    [self.dbManager executeQuery:query];
    
    /* If the query was successfully executed then pop the view controller. */
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
        
        /* Inform the delegate that the editing was finished. */
        [self.delegate editingInfoWasFinished];
        
        /* Pop the view controller. */
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        NSLog(@"Could not execute the query.");
    }
}

-(void)loadInfoToEdit{
    /* Create the query. */
    NSString *query = [NSString stringWithFormat:@"select * from peopleInfo where peopleInfoID=%d", self.recordIDToEdit];
    
    /* Load the relevant data. */
    NSArray *results = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    /* Set the loaded data to the textfields */
    self.txtAmount.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"firstname"]];
    self.txtDescription.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"lastname"]];
    //self.txtAge.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"age"]];
}

@end
