#import "DeploymentController.h"
#import "NSObject+AssociateDisposable.h"
#import "RACSubscribable+ShowLoadingView.h"

@interface DeploymentController ()

@property (nonatomic, strong) FoundryService *service;

@end

static NSArray *instanceColumns = nil;

@implementation DeploymentController

@synthesize service, deployment, app, title, deploymentView, breadcrumbController, instanceStats;

+ (void)initialize {
    instanceColumns = @[@"ID", @"Host name", @"CPU", @"Memory", @"Disk", @"Uptime"];
}

- (id)initWithDeployment:(Deployment *)leDeployment {
    if (self = [super initWithNibName:@"DeploymentView" bundle:[NSBundle mainBundle]]) {
        self.title = leDeployment.appName;
        self.deployment = leDeployment;
        self.service = [[FoundryService alloc] initWithEndpoint:[FoundryEndpoint endpointWithTarget:deployment.target]];
    }
    return self;
}

- (void)awakeFromNib {
    NSError *error = nil;
    
    NSArray *subscribables = @[
        [service getStatsForAppWithName:deployment.appName],
        [service getAppWithName:deployment.appName]];
    
    RACSubscribable *call = [[RACSubscribable combineLatest:subscribables] showLoadingViewInView:self.view];
    
    self.associatedDisposable = [call subscribeNext:^ (id x) {
        RACTuple *tuple = (RACTuple *)x;
        self.instanceStats = tuple.first;
        self.app = tuple.second;
        [deploymentView.instancesGrid reloadData];
        deploymentView.needsLayout = YES;
    } error:^ (NSError *error) {
        [NSApp presentError:error];
    }];
}

- (id<BreadcrumbItem>)breadcrumbItem {
    return self;
}

- (NSUInteger)numberOfColumnsForGridView:(GridView *)gridView {
    return instanceColumns.count;
}

- (NSString *)gridView:(GridView *)gridView titleForColumn:(NSUInteger)columnIndex {
    return [instanceColumns objectAtIndex:columnIndex];
}

- (NSUInteger)numberOfRowsForGridView:(GridView *)gridView {
    return instanceStats.count;
}

- (NSString *)gridView:(GridView *)gridView titleForRow:(NSUInteger)row column:(NSUInteger)columnIndex {
    FoundryAppInstanceStats *stats = [instanceStats objectAtIndex:row];
    
    switch (columnIndex) {
        case 0:
            return stats.ID;
        case 1:
            return stats.host;
        case 2:
            return [NSString stringWithFormat:@"%f", stats.cpu];
        case 3:
            return [NSString stringWithFormat:@"%f", stats.memory];
        case 4:
            return [NSString stringWithFormat:@"%ld", stats.disk];
        case 5:
            return [NSString stringWithFormat:@"%f", stats.uptime];
    }
    
    BOOL columnIndexIsValid = NO;
    assert(columnIndexIsValid);
    return nil;
}

- (void)gridView:(GridView *)gridView didSelectRowAtIndex:(NSUInteger)row {
    NSLog(@"Clicked at index %lu", row);
}

- (IBAction)deleteClicked:(id)sender {
    self.associatedDisposable = [[service deleteAppWithName:deployment.appName] subscribeError:^(NSError *error) {
        [NSApp presentError:error];
    } completed:^{
        [[ThorBackend sharedContext] deleteObject:deployment];
        NSError *error;
        
        if (![[ThorBackend sharedContext] save:&error]) {
            [NSApp presentError:error];
            return;
        }
        
        [self.breadcrumbController popViewControllerAnimated:YES];
    }];
}

@end
