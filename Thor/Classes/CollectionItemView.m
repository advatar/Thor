#import "CollectionItemView.h"
#import "NSString+ShadowedTextDrawing.h"

@implementation CollectionItemViewButton

@synthesize label;

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingMiddle;
    paragraphStyle.alignment = NSCenterTextAlignment;
    
    NSFont *labelFont = [NSFont boldSystemFontOfSize:12];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                labelFont, NSFontAttributeName,
                                [NSColor whiteColor], NSForegroundColorAttributeName,
                                paragraphStyle, NSParagraphStyleAttributeName,
                                nil];

    CGFloat fontLineHeight = labelFont.leading + labelFont.ascender - labelFont.descender;
    NSRect labelRect = NSMakeRect(0, self.bounds.size.height - fontLineHeight - 2, self.bounds.size.width, fontLineHeight);
    
    [label drawShadowedInRect:labelRect withAttributes:attributes];
}

@end

@implementation CollectionItemView

@synthesize button;

@end
