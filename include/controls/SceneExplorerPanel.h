#import <Cocoa/Cocoa.h>
#import <controls/Panel.h>


@interface SceneExplorerPanel: Panel <NSOutlineViewDataSource, NSOutlineViewDelegate>
{
@private
    IBOutlet NSOutlineView* list;

    NSMutableArray*         scenes;
    NSImage*                imgFolderOpen;
    NSImage*                imgFolderClosed;
}

@end
