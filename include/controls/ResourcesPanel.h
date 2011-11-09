#import <Cocoa/Cocoa.h>

@interface ResourcesPanel: NSView <NSOutlineViewDataSource, NSOutlineViewDelegate>
{
@private
    IBOutlet NSOutlineView* list;
    IBOutlet NSButton*      btnAdd;
    IBOutlet NSButton*      btnRemove;

    NSMutableArray*         groups;
}

@end
