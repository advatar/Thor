

@class GridView;

@protocol GridDataSource <NSObject>

- (NSUInteger)numberOfColumnsForGridView:(GridView *)gridView;
- (NSString *)gridView:(GridView *)gridView titleForColumn:(NSUInteger)columnIndex;

- (NSUInteger)numberOfRowsForGridView:(GridView *)gridView;
- (NSString *)gridView:(GridView *)gridView titleForRow:(NSUInteger)row column:(NSUInteger)columnIndex;

@end


@interface GridView : NSView

@property (nonatomic, unsafe_unretained) id<GridDataSource> dataSource;

- (void)reloadData;

@end