#import <Cocoa/Cocoa.h>
#import <controls/Panel.h>


@interface ResourcesPanel: Panel <NSOutlineViewDataSource, NSOutlineViewDelegate>
{
@private
    IBOutlet NSOutlineView* list;
    IBOutlet NSButton*      btnAdd;
    IBOutlet NSButton*      btnRemove;

    NSMutableArray*         groups;
}

- (IBAction) addLocations:(id)sender;
- (IBAction) removeSelectedLocations:(id)sender;

@end
