#import "TargetPropertiesView.h"

@interface TargetPropertiesController : NSViewController

@property (nonatomic, strong) IBOutlet Target *target;
@property (nonatomic, strong) IBOutlet TargetPropertiesView *targetPropertiesView;

- (IBAction)buttonClicked:(NSButton *)button;

@end
