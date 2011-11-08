#import <controls/ResourcesPanel.h>


@implementation ResourcesPanel

/************************* IMPLEMENTATION OF NSBrowserDelegate **************************/

- (NSInteger) browser:(NSBrowser*)sender numberOfRowsInColumn:(NSInteger)column
{
    return 10;
}


- (void) browser:(NSBrowser*)sender willDisplayCell:(id)cell atRow:(NSInteger)row column:(NSInteger)column
{
    NSBrowserCell* c = (NSBrowserCell*) cell;
    
    [c setStringValue:@"test"];
    [c setLeaf:YES];
}

@end
