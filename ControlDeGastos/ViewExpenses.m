//
//  ViewExpenses.m
//  ControlDeGastos
//
//  Created by Christian Barragan on 20/08/16.
//  Copyright © 2016 Christian Barragan. All rights reserved.
//

#import "ViewExpenses.h"
#import "DBManager.h"


@interface ViewExpenses ()


@property (nonatomic, strong) DBManager *dbManager;

@property (nonatomic, strong) NSArray *arrExpenseInfo;

@property (nonatomic) int recordIDToEdit;

-(void)loadData;


@end

@implementation ViewExpenses

- (void)viewDidLoad {
    [super viewDidLoad];
    /* Do any additional setup after loading the view, typically from a nib. */
    
    /* Make self the delegate and datasource of the table view. */
    self.tblExpenses.delegate = self;
    self.tblExpenses.dataSource = self;
    
    /* Initialize the dbManager property. */
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"expense_db.sql"];
    
    /* Load the data */
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadData {
    /* Form the query. */
    NSString *query = @"select * from expense";
    
    /* Initialize the array. */
    if (self.arrExpenseInfo != nil) {
        self.arrExpenseInfo = nil;
    }
    /* Get the results. */
    self.arrExpenseInfo = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    /* Reload the table view. */
    [self.tblExpenses reloadData];
}

#pragma - mark Table view methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrExpenseInfo.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    /* Dequeue the cell. */
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idCellRecord" forIndexPath:indexPath];
    
    NSInteger indexOfAmount = [self.dbManager.arrColumnNames indexOfObject:@"amount"];
    NSInteger indexOfDescription = [self.dbManager.arrColumnNames indexOfObject:@"description"];
    NSInteger indexOfDate = [self.dbManager.arrColumnNames indexOfObject:@"date"];
    
    /* Set the loaded data to the appropriate cell labels. */
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [[self.arrExpenseInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfAmount]];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, Fecha: %@", [[self.arrExpenseInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfDescription], [[self.arrExpenseInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfDate]];
    
    return cell;
}

-(void)editingInfoWasFinished{
    /* Reload the data. */
    [self loadData];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    AddNewExpense *editInfoViewController = [segue destinationViewController];
    editInfoViewController.delegate = self;
    editInfoViewController.recordIDToEdit = self.recordIDToEdit;
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    /* Get the record ID of the selected name and set it to the recordIDToEdit property. */
    self.recordIDToEdit = [[[self.arrExpenseInfo objectAtIndex:indexPath.row] objectAtIndex:0] intValue];
    
    /* Perform the segue. */
    [self performSegueWithIdentifier:@"editExpenseSegue" sender:self];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        /* Delete the selected record. */
        /* Find the record ID. */
        int recordIDToDelete = [[[self.arrExpenseInfo objectAtIndex:indexPath.row] objectAtIndex:0] intValue];
        
        /* Prepare the query. */
        NSString *query = [NSString stringWithFormat:@"delete from expense where id=%d", recordIDToDelete];
        
        /* Execute the query. */
        [self.dbManager executeQuery:query];
        
        /* Reload the table view. */
        [self loadData];
    }
}

@end
