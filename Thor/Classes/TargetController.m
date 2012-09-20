#import "TargetController.h"
#import "TargetPropertiesController.h"
#import "SheetWindow.h"
#import "NSObject+AssociateDisposable.h"
#import "DeploymentController.h"
#import "AppCell.h"
#import "NoResultsListViewDataSource.h"
#import "RACSubscribable+ShowLoadingView.h"

@interface TargetController ()

@property (nonatomic, strong) NSArray *apps;
@property (nonatomic, strong) FoundryService *service;
@property (nonatomic, strong) TargetPropertiesController *targetPropertiesController;
@property (nonatomic, strong) NoResultsListViewDataSource *dataSource;

@end

@implementation TargetController

@synthesize target = _target, targetView, breadcrumbController, title, apps, service, targetPropertiesController, dataSource;

- (void)setTarget:(Target *)value {
    _target = value;
    self.service = [[FoundryService alloc] initWithEndpoint:[FoundryEndpoint endpointWithTarget:value]];
}

- (id<BreadcrumbItem>)breadcrumbItem {
    return self;
}

- (id)init {
    if (self = [super initWithNibName:@"TargetView" bundle:[NSBundle mainBundle]]) {
        self.title = @"Cloud";
    }
    return self;
}

- (void)awakeFromNib {
    self.dataSource = [[NoResultsListViewDataSource alloc] init];
    dataSource.dataSource = self;
    self.targetView.deploymentsList.dataSource = dataSource;
}

- (void)viewWillAppear {
    // force a re-layout so loading view is properly sized.
    // right now, this called right after the view is added
    // to the hierarchy but not yet laid out, so frames are all zero.
    // TODO force layout at breadcrumbcontroller level
    self.view.superview.needsLayout = YES;
    [self.view.superview layoutSubtreeIfNeeded];
    
    self.associatedDisposable = [[[service getApps] showLoadingViewInView:self.view] subscribeNext:^(id x) {
        self.apps = x;
        [targetView.deploymentsList reloadData];
        targetView.needsLayout = YES;
    } error:^(NSError *error) {
        [NSApp presentError:error];
    }];
}

- (NSUInteger)numberOfRowsForListView:(ListView *)listView {
    return apps.count;
}

- (NSView *)listView:(ListView *)listView cellForRow:(NSUInteger)row {
    AppCell *cell = [[AppCell alloc] initWithFrame:NSZeroRect];
    cell.app = apps[row];
    return cell;
}

- (void)listView:(ListView *)listView didSelectRowAtIndex:(NSUInteger)row {
    FoundryApp *app = apps[row];
    Deployment *deployment = [Deployment deploymentInsertedIntoManagedObjectContext:[ThorBackend sharedContext]];
    deployment.appName = app.name;
    deployment.target = self.target;
    
    DeploymentController *deploymentController = [[DeploymentController alloc] initWithDeployment:deployment];
    [self.breadcrumbController pushViewController:deploymentController animated:YES];
}

- (void)editClicked:(id)sender {
    self.targetPropertiesController = [[TargetPropertiesController alloc] init];
    self.targetPropertiesController.editing = YES;
    self.targetPropertiesController.target = self.target;
    
    NSWindow *window = [SheetWindow sheetWindowWithView:targetPropertiesController.view];
    [NSApp beginSheet:window modalForWindow:self.view.window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    self.targetPropertiesController = nil;
    [sheet orderOut:self];
}

- (void)deleteClicked:(id)sender {
    [[ThorBackend sharedContext] deleteObject:self.target];
    NSError *error;
    
    if (![[ThorBackend sharedContext] save:&error]) {
        [NSApp presentError:error];
        return;
    }
    
    [self.breadcrumbController popViewControllerAnimated:YES];
}

@end
