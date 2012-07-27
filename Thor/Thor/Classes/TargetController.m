#import "TargetController.h"
#import "CollectionView.h"

@interface TargetView : NSView

@property (nonatomic, strong) NSBox *infoBox, *deploymentsBox;
@property (nonatomic, strong) NSTextField *displayNameLabel, *displayNameValueLabel;
@property (nonatomic, strong) GridView *deploymentsGrid;

@end

@implementation TargetView

@synthesize infoBox, deploymentsBox, displayNameLabel, displayNameValueLabel, deploymentsGrid;

- (id)initWithTarget:(Target *)target {
    if (self = [super initWithFrame:NSMakeRect(0, 0, 100, 100)]) {
        //self.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.infoBox = [[NSBox alloc] initWithFrame:NSZeroRect];
        infoBox.title = @"Cloud settings";
        infoBox.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:infoBox];
        
        self.displayNameLabel = [Label label];
        displayNameLabel.stringValue = @"Name";
        [infoBox.contentView addSubview:displayNameLabel];
        
        self.displayNameValueLabel = [Label label];
        displayNameValueLabel.stringValue = target.displayName;
        [infoBox.contentView addSubview:displayNameValueLabel];
        
        self.deploymentsBox = [[NSBox alloc] initWithFrame:NSZeroRect];
        deploymentsBox.title = @"App Deployments";
        deploymentsBox.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:deploymentsBox];
        
        self.deploymentsGrid = [[GridView alloc] initWithFrame:NSZeroRect];
        
        [deploymentsBox.contentView addSubview:deploymentsGrid];
    }
    return self;
}

- (void)setFrame:(NSRect)frameRect {
    NSLog(@"target view frame %@", NSStringFromRect(frameRect));
    [super setFrame:frameRect];
}

- (void)updateConstraints {
    NSDictionary *views = NSDictionaryOfVariableBindings(infoBox, deploymentsBox, displayNameLabel, displayNameValueLabel, deploymentsGrid);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[infoBox]-|" options:NSLayoutFormatAlignAllLeading metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[deploymentsBox]-|" options:NSLayoutFormatAlignAllLeading metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[infoBox(==150)]-[deploymentsBox]" options:NSLayoutFormatAlignAllLeading metrics:nil views:views]];
    
    [infoBox addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[displayNameLabel]-[displayNameValueLabel]-|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:views]];
    [infoBox addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[displayNameLabel]" options:NSLayoutFormatAlignAllBaseline metrics:nil views:views]];
//    
//    [deploymentsBox setContentHuggingPriority:NSLayoutPriorityDefaultLow - 1 forOrientation:NSLayoutConstraintOrientationVertical];
//    [deploymentsBox setContentHuggingPriority:NSLayoutPriorityDefaultLow - 1 forOrientation:NSLayoutConstraintOrientationHorizontal];
    
    [deploymentsBox addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[deploymentsGrid]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
    [deploymentsBox addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[deploymentsGrid]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    
    [displayNameValueLabel setContentHuggingPriority:NSLayoutPriorityDefaultLow - 1 forOrientation:NSLayoutConstraintOrientationHorizontal];
    
    [super updateConstraints];
}

@end

@interface TargetController ()

@property (nonatomic, strong) Target *target;
@property (nonatomic, strong) TargetView *targetView;
@property (nonatomic, strong) NSArray *deployments;

@end

static NSArray *deploymentColumns = nil;

@implementation TargetController

+ (void)initialize {
    deploymentColumns = [NSArray arrayWithObjects:@"Name", @"CPU", @"Memory", @"Disk", nil];
}

@synthesize target, targetView, breadcrumbController, title, deployments;

- (id<BreadcrumbItem>)breadcrumbItem {
    return self;
}

- (id)initWithTarget:(Target *)leTarget {
    //if (self = [super initWithNibName:@"TargetView" bundle:[NSBundle mainBundle]]) {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.target = leTarget;
        self.title = leTarget.displayName;
    }
    return self;
}

- (void)loadView {
    self.deployments = [[FixtureVMCService new] getDeploymentsForTarget:target];
    
    self.targetView = [[TargetView alloc] initWithTarget:target];
    self.targetView.deploymentsGrid.dataSource = self;
    [targetView.deploymentsGrid reloadData];
    
    self.view = targetView;
}

- (NSUInteger)numberOfColumnsForGridView:(GridView *)gridView {
    return deploymentColumns.count;
}

- (NSString *)gridView:(GridView *)gridView titleForColumn:(NSUInteger)columnIndex {
    return [deploymentColumns objectAtIndex:columnIndex];
}

- (NSUInteger)numberOfRowsForGridView:(GridView *)gridView {
    return deployments.count;
}

- (NSString *)gridView:(GridView *)gridView titleForRow:(NSUInteger)row column:(NSUInteger)columnIndex {
    VMCDeployment *deployment = [deployments objectAtIndex:row];
    
    switch (columnIndex) {
        case 0:
            return deployment.name;
        case 1:
            return deployment.cpu;
        case 2:
            return deployment.memory;
        case 3:
            return deployment.disk;
    }
    
    BOOL columnIndexIsValid = NO;
    assert(columnIndexIsValid);
    return nil;
}

@end
