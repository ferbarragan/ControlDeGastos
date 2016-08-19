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

/* Object of Database Manage class. */
@property (nonatomic, strong) DBManager *dbManager;

/* Information pickers */
@property (nonatomic, strong) UIPickerView *pickerPayMethod;
@property (nonatomic, strong) UIPickerView *pickerCategory;
@property (nonatomic, strong) UIDatePicker *datePicker;

/* Arrays to hold the picker's information */
@property (nonatomic, strong) NSMutableArray *arrPickerPayMethod;
@property (nonatomic, strong) NSMutableArray *arrPickerCategory;

/*SQL formatted fields */
@property NSDecimalNumber *expAmount;   /* Expense amount. */
@property NSString *expDescr;           /* Expense description. */
@property int expPayM;                  /* Expense pay method, in expense table this is a foreign key. */
@property int expCateg;                 /* Expense category, in expense table this is a foreign key. */
@property int lastPayMethodArrayIndex;
@property int lastCategoryArrayIndex;

-(void)textFieldSetDefaultValue:(UITextField *)texField;
-(void)loadInfoToEdit;
-(void)closePayMethodPickerView;
-(void)closeCategoryPickerView;
-(void)loadPickerData;

@end

@implementation AddNewExpense

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* Initialize the dbManager object. */
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"expense_db.sql"];
    
    [self loadPickerData];
    
    self.lastPayMethodArrayIndex = 0;
    self.lastCategoryArrayIndex = 0;
    
    /* Fixed test arrays. */
    //self.arrPickerPayMethod = [[NSArray alloc] initWithObjects:@"1",@"2",@"3", nil];
    //self.arrPickerCategory  = [[NSArray alloc] initWithObjects:@"4",@"5",@"6", nil];
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    /* Make self the delegate of the textfields. */
    self.txtAmount.delegate = self;
    self.txtDescription.delegate = self;
    self.txtPayMethod.delegate = self;
    self.txtCategory.delegate = self;
    
    /* Check if should load specific record for editing. */
    if (self.recordIDToEdit != -1)
    {
        /* Load the record with the specific ID from the database. */
        [self loadInfoToEdit];
    }
    else {
        /* A new record will be inserted. */
    }
    
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
    UIBarButtonItem *datePickerToolBarDoneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Listo" style:UIBarButtonItemStylePlain target:self action:@selector(ShowSelectedDate)];
    UIBarButtonItem *datePickerToolBarSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [datePickerToolBar setItems:[NSArray arrayWithObjects:datePickerToolBarSpace,datePickerToolBarDoneBtn, nil]];
    [self.txtDate setInputAccessoryView:datePickerToolBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    /* Dispose of any resources that can be recreated. */
}

#pragma mark - TextField Methods.
/* ------------------------------------------------------------------------------------------------------------------ */
/* - TextField Methods ---------------------------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------------------------------------------------ */

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if(textField == self.txtAmount)
    {
        NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init] ;
        [currencyFormatter setLocale:[NSLocale currentLocale]];
        [currencyFormatter setMaximumFractionDigits:2];
        [currencyFormatter setMinimumFractionDigits:2];
        [currencyFormatter setAlwaysShowsDecimalSeparator:YES];
        [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        
        NSNumber *someAmount = [NSNumber numberWithDouble:[self.txtAmount.text doubleValue]];
        NSString *string = [currencyFormatter stringFromNumber:someAmount];
        
        self.txtAmount.text = string;
    }
    
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldSetDefaultValue:(UITextField *)texField {
    if (texField == self.txtPayMethod) {
        self.txtPayMethod.text = [self.arrPickerPayMethod objectAtIndex:self.lastPayMethodArrayIndex];
    }
    else if (texField == self.txtCategory) {
        self.txtCategory.text = [self.arrPickerCategory objectAtIndex:self.lastCategoryArrayIndex];
    }
    else {
        /* Do nothing... */
    }
}

#pragma mark - DatePicker Methods.
/* ------------------------------------------------------------------------------------------------------------------ */
/* - DatePicker Methods --------------------------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------------------------------------------------ */

-(void)ShowSelectedDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy"];
    self.txtDate.text = [NSString stringWithFormat:@"%@",[formatter stringFromDate:self.datePicker.date]];
    [self.txtDate resignFirstResponder];
}


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
        self.lastPayMethodArrayIndex = row;
    }
    else if (pickerView == self.pickerCategory) {
        self.txtCategory.text = [self.arrPickerCategory objectAtIndex:row];
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
    
    /* Before we prepare the query, we must format the input values into an aproppiate type. */
    self.expAmount = 0;
    self.expDescr = @"";
    self.expPayM = 0;
    self.expCateg = 0;
    
    
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
/* ------------------------------------------------------------------------------------------------------------------ */

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
/* ------------------------------------------------------------------------------------------------------------------ */

@end
