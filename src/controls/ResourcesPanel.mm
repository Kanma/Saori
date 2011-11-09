#import <controls/ResourcesPanel.h>
#import <Ogre/OgreResourceGroupManager.h>


@interface ResourceGroup: NSObject
{
@public
    NSString*       name;
    NSMutableArray* locations;
}

@end


@implementation ResourceGroup
@end



@interface ResourcesPanel ()

- (void) updateResourceGroup:(NSString*)name;
- (ResourceGroup*) getResourceGroup:(NSString*)name;

@end



@implementation ResourcesPanel


/*************************************** METHODS ****************************************/

- (id) initWithFrame:(NSRect)frame
{
    if ([super initWithFrame:frame])
    {
        groups = [[NSMutableArray alloc] initWithCapacity:10];

        [self updateResourceGroup:@"General"];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resourceGroupUpdated:)
                                                     name:@"SaoriResourceGroupUpdated"
                                                   object:nil ];
    }
    
    return self;
}


- (void) resourceGroupUpdated:(NSNotification*)notification
{
    [self updateResourceGroup:[notification.userInfo objectForKey:@"groupName"]];
}


- (void) updateResourceGroup:(NSString*)name
{
    ResourceGroup* group = [self getResourceGroup:name];
    BOOL newGroup = NO;

    Ogre::ResourceGroupManager* pManager = Ogre::ResourceGroupManager::getSingletonPtr();
    if (pManager && pManager->resourceGroupExists([name UTF8String]))
    {
        if (!group)
        {
            group = [[ResourceGroup alloc] init];
            group->name = name;
            group->locations = nil;
            
            newGroup = YES;
            
            int index = 0;
            for (index = 0; index < [groups count]; ++index)
            {
                if ([name compare:((ResourceGroup*)[groups objectAtIndex:index])->name] != NSOrderedAscending)
                    break;
            }
            [groups insertObject:group atIndex:index];
        }
        
        [group->locations release];
        
        Ogre::StringVectorPtr resourcesList = pManager->listResourceLocations([name UTF8String]);
        group->locations = [[NSMutableArray alloc] initWithCapacity:resourcesList->size()];

        Ogre::VectorIterator<Ogre::StringVector> iter(resourcesList->begin(), resourcesList->end());
        while (iter.hasMoreElements())
        {
            Ogre::String location = iter.getNext();
            [group->locations addObject:[NSString stringWithUTF8String:location.c_str()]];
        }
    }
    else if (group)
    {
        [groups removeObject:group];
        [group release];
        group = nil;
    }

    if (group && !newGroup)
    {
        [list reloadItem:group reloadChildren:YES];
        [group release];
    }
    else
    {
        [list reloadItem:nil reloadChildren:YES];
    }
}


- (ResourceGroup*) getResourceGroup:(NSString*)name
{
    int index = [groups indexOfObjectPassingTest: ^(id obj, NSUInteger idx, BOOL *stop) {
        ResourceGroup* group = (ResourceGroup*) obj;
        BOOL result = [group->name isEqualToString:name];
        *stop = result;
        return result;
    }];

    if (index == NSNotFound)
        return nil;
    
    return [(ResourceGroup*) [groups objectAtIndex:index] retain];
}


/********************** IMPLEMENTATION OF NSOutlineViewDataSource ***********************/

- (id) outlineView:(NSOutlineView*)outlineView child:(NSInteger)index ofItem:(id)item
{
	if (item)
		return [((ResourceGroup*) item)->locations objectAtIndex:index];
	else
		return [groups objectAtIndex:index];
}


- (BOOL) outlineView:(NSOutlineView*)outlineView isItemExpandable:(id)item
{
    return ([item isKindOfClass:[ResourceGroup class]]);
}


- (NSInteger) outlineView:(NSOutlineView*)outlineView numberOfChildrenOfItem:(id)item
{
	if (item)
	{
		if ([item isKindOfClass:[ResourceGroup class]])
			return [((ResourceGroup*) item)->locations count];

		return 0;
    }

	return [groups count];
}


- (id) outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	if (item)
	{
		if ([item isKindOfClass:[ResourceGroup class]])
			return ((ResourceGroup*) item)->name;

		return item;
    }

	return @"Resource groups";
}


/*********************** IMPLEMENTATION OF NSOutlineViewDelegate ************************/

- (void) outlineViewItemDidCollapse: (NSNotification*)notification
{
    NSTableColumn* column = [[list tableColumns] objectAtIndex:0];

    float maxSize = 0.0f;
    for (int index = 0; index < [groups count]; ++index)
    {
        id item = [groups objectAtIndex:index];

        int row = [list rowForItem:item];

        NSCell* cell = [list preparedCellAtColumn:0 row:row];
        if (maxSize < [cell cellSize].width)
            maxSize = [cell cellSize].width;
        
        if ([list isItemExpanded:item])
        {
            ResourceGroup* group = (ResourceGroup*) item;
            
            for (int index2 = 0; index2 < [group->locations count]; ++index2)
            {
                id item2 = [group->locations objectAtIndex:index2];
        
                int row2 = [list rowForItem:item2];
                NSCell* cell2 = [list preparedCellAtColumn:0 row:row2];
                if (maxSize < [cell2 cellSize].width)
                    maxSize = [cell2 cellSize].width;
            }
        }
    }
    
    [column setMinWidth:maxSize + 100.0f];
    [column setWidth:maxSize + 100.0f];
}


- (void) outlineViewItemDidExpand: (NSNotification*)notification
{
    [self outlineViewItemDidCollapse:notification];
}

@end
