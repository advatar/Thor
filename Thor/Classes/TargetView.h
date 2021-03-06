#import "ListView.h"

@interface TargetView : NSView

@property (nonatomic, strong) IBOutlet NSScrollView *scrollView;
@property (nonatomic, strong) IBOutlet NSBox *settingsBox, *deploymentsBox;
@property (nonatomic, strong) IBOutlet ListView *deploymentsList;
@property (nonatomic, strong) IBOutlet NSView *settingsView;

@end
