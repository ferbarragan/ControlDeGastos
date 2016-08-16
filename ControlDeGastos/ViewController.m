//
//  ViewController.m
//  ControlDeGastos
//
//  Created by Christian Barragan on 15/08/16.
//  Copyright © 2016 Christian Barragan. All rights reserved.
//

#import "ViewController.h"
#import "DBManager.h"

@interface ViewController ()

@property (nonatomic, strong) DBManager *dbManager;

@property (nonatomic, strong) NSArray *arrPeopleInfo;

@property (nonatomic) int recordIDToEdit;

-(void)loadData;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /* Do any additional setup after loading the view, typically from a nib. */
    
    /* Make self the delegate and datasource of the table view. */
    self.tblPeople.delegate = self;
    self.tblPeople.dataSource = self;
    
    /* Initialize the dbManager property. */
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"sampledb.sql"];
    
    /* Load the data */
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    /* Dispose of any resources that can be recreated. */
}

- (IBAction)addNewRecord:(id)sender {
    /* Before performing the segue, set the -1 value to the recordIDToEdit. That way we'll indicate that we want to add a new record and not to edit an existing one. */
    self.recordIDToEdit = -1;
    /* Perform the segue */
    [self performSegueWithIdentifier:@"idSegueEditInfo" sender:self];
}

-(void)loadData {
    /* Form the query. */
    NSString *query = @"select * from peopleInfo";
    
    /* Get the results. */
    if (self.arrPeopleInfo != nil) {
        self.arrPeopleInfo = nil;
    }
    self.arrPeopleInfo = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    /* Reload the table view. */
    [self.tblPeople reloadData];
}

#pragma - mark Table view methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrPeopleInfo.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    /* Dequeue the cell. */
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idCellRecord" forIndexPath:indexPath];
    
    NSInteger indexOfFirstname = [self.dbManager.arrColumnNames indexOfObject:@"firstname"];
    NSInteger indexOfLastname = [self.dbManager.arrColumnNames indexOfObject:@"lastname"];
    NSInteger indexOfAge = [self.dbManager.arrColumnNames indexOfObject:@"age"];
    
    /* Set the loaded data to the appropriate cell labels. */
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [[self.arrPeopleInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfFirstname], [[self.arrPeopleInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfLastname]];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Age: %@", [[self.arrPeopleInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfAge]];
    
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
    self.recordIDToEdit = [[[self.arrPeopleInfo objectAtIndex:indexPath.row] objectAtIndex:0] intValue];
    
    /* Perform the segue. */
    [self performSegueWithIdentifier:@"idSegueEditInfo" sender:self];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        /* Delete the selected record. */
        /* Find the record ID. */
        int recordIDToDelete = [[[self.arrPeopleInfo objectAtIndex:indexPath.row] objectAtIndex:0] intValue];
        
        /* Prepare the query. */
        NSString *query = [NSString stringWithFormat:@"delete from peopleInfo where peopleInfoID=%d", recordIDToDelete];
        
        /* Execute the query. */
        [self.dbManager executeQuery:query];
        
        /* Reload the table view. */
        [self loadData];
    }
}

@end
