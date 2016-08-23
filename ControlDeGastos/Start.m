//
//  Start.m
//  ControlDeGastos
//
//  Created by Christian Barragan on 20/08/16.
//  Copyright © 2016 Christian Barragan. All rights reserved.
//

#import "Start.h"
#import "BackgroundLayer.h"
#import "DTProgressView.h"

@interface Start ()

@property (weak, nonatomic) IBOutlet DTProgressView *progressView;

@property (nonatomic) int recordIDToEdit;

@end

@implementation Start

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}
/* ------------------------------------------------------------------------------------------------------------------ */

- (void)viewDidDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewDidDisappear:animated];
}
/* ------------------------------------------------------------------------------------------------------------------ */

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 50.0f)];
    /*
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[[UIColor blackColor] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
     */
    CAGradientLayer *bgLayer = [BackgroundLayer blueGradient];
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    
    /*
    
    [self setupProgressView];
    [self increaseProgress];
    
    [self.view addSubview:self.progressView];
    */
    
    /*
    UIButton *button;
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Show View" forState:UIControlStateNormal];
    button.frame = CGRectMake(80.0, 210.0, 160.0, 40.0);
    [self.view addSubview:button];
    
    CABasicAnimation *halfTurn;
    halfTurn = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    halfTurn.fromValue = [NSNumber numberWithFloat:0];
    halfTurn.toValue = [NSNumber numberWithFloat:((360*M_PI)/180)];
    halfTurn.duration = 0.5;
    halfTurn.repeatCount = HUGE_VALF;
    [[button layer] addAnimation:halfTurn forKey:@"180"];
     */
    
}
/* ------------------------------------------------------------------------------------------------------------------ */

-(void)setupProgressView
{
    self.progressView.strokeColor = [UIColor redColor];
    CGFloat side = self.progressView.bounds.size.width - 5;
    CGRect circleRect = CGRectMake(5, 5, side-5, side-5);
    UIBezierPath * circlePath = [UIBezierPath bezierPathWithOvalInRect:circleRect];
    self.progressView.path = circlePath;
    self.progressView.lineWidth = 2;
}
/* ------------------------------------------------------------------------------------------------------------------ */

-(void)increaseProgress
{
    if (self.progressView.progress == 1)
    {
        [self.progressView setProgress:0 animated:NO];
    }
    float random = (arc4random() % 10)/100.0;
    
    float progress = self.progressView.progress + random;

    [self.progressView setProgress:progress animated:YES];
    
    [self performSelector:@selector(increaseProgress) withObject:nil afterDelay:0.15];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/* ------------------------------------------------------------------------------------------------------------------ */

- (IBAction)addNewExpense:(id)sender {
    /* Before performing the segue, set the -1 value to the recordIDToEdit. That way we'll indicate that we want to add a new record and not to edit an existing one. */
    self.recordIDToEdit = -1;
    /* Perform the segue */
    [self performSegueWithIdentifier:@"addExpenseSegue" sender:self];
}

- (IBAction)viewExpenses:(id)sender {
    /* Perform the segue */
    [self performSegueWithIdentifier:@"viewExpenseSegue" sender:self];
}
/* ------------------------------------------------------------------------------------------------------------------ */

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"addExpenseSegue"]){
        /* Go to Add Expenses View. */
        AddNewExpense *addNewExpenseViewController = [segue destinationViewController];
        addNewExpenseViewController.delegate = self;
        addNewExpenseViewController.recordIDToEdit = self.recordIDToEdit;
    } else if ([segue.identifier isEqualToString:@"viewExpenseSegue"]) {
        /* Nothing special to do... */
    }
    
    
}
@end
