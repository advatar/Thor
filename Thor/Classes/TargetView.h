#import "GridView.h"

@interface TargetView : NSView

@property (nonatomic, strong) IBOutlet NSBox *infoBox, *deploymentsBox;
@property (nonatomic, strong) IBOutlet GridView *deploymentsGrid;
@property (nonatomic, strong) NSButton *editButton;

@end
