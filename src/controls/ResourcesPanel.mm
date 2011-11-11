#import <controls/ResourcesPanel.h>
#import <Ogre/OgreResourceGroupManager.h>


@interface ResourceGroup: NSObject
{
@public
    NSString*       name;
    NSMutableArray* locations;
    BOOL            removable;
}

@end


@implementation ResourceGroup
@end



@interface ResourcesPanel ()

- (void) updateResourceGroup:(NSString*)name removable:(BOOL)removable;
- (ResourceGroup*) getResourceGroup:(NSString*)name;

@end



@implementation ResourcesPanel


/*************************************** METHODS ****************************************/

- (id) initWithFrame:(NSRect)frame
{
    if ([super initWithFrame:frame])
    {
        groups = [[NSMutableArray alloc] initWithCapacity:10];

        [self updateResourceGroup:@"General" removable:NO];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resourceGroupUpdated:)
                                                     name:@"SaoriResourceGroupUpdated"
                                                   object:nil ];
    }
    
    return self;
}


- (IBAction) addLocations:(id)sender
{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];

    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:YES];
    openDlg.allowsMultipleSelection = YES;

    if ([openDlg runModalForDirectory:nil file:nil] == NSOKButton)
    {
        Ogre::ResourceGroupManager* pManager = Ogre::ResourceGroupManager::getSingletonPtr();

        if (pManager->resourceGroupExists("User"))
            pManager->clearResourceGroup("User");
        else
            pManager->createResourceGroup("User");

        ResourceGroup* group = [self getResourceGroup:@"User"];
        if (group)
        {
            for (int i = 0; i < [group->locations count]; ++i)
            {
                NSString* item = [group->locations objectAtIndex:i];
                
                if (!pManager->resourceLocationExists([item UTF8String], "User"))
                {
                    if ([item hasSuffix:@".zip"])
                        pManager->addResourceLocation([item UTF8String], "Zip", "User");
                    else
                        pManager->addResourceLocation([item UTF8String], "FileSystem", "User");
                }
            }
        }
        
        NSArray* files = [openDlg filenames];
        for (int i = 0; i < [files count]; ++i)
        {
            NSString* fileName = [files objectAtIndex:i];

            if (!pManager->resourceLocationExists([fileName UTF8String], "User"))
            {
                if ([fileName hasSuffix:@".zip"])
                    pManager->addResourceLocation([fileName UTF8String], "Zip", "User");
                else
                    pManager->addResourceLocation([fileName UTF8String], "FileSystem", "User");
            }
        }
        
        try
        {
            pManager->initialiseResourceGroup("User");
        }
        catch (Ogre::Exception ex)
        {
            NSRunInformationalAlertPanel(@"ERROR",
                                         [NSString stringWithFormat:@"Failed to add the resource locations.\n\nDetails:\n%@",
                                                                    [NSString stringWithUTF8String:ex.getFullDescription().c_str()]],
                                         @"OK", nil, nil);
            
            pManager->clearResourceGroup("User");

            for (int i = 0; i < [files count]; ++i)
                pManager->removeResourceLocation([[files objectAtIndex:i] UTF8String], "User");

            pManager->initialiseResourceGroup("User");
        }

        [self updateResourceGroup:@"User" removable:YES];
    }
}


- (IBAction) removeSelectedLocations:(id)sender
{
    Ogre::ResourceGroupManager* pManager = Ogre::ResourceGroupManager::getSingletonPtr();
    if (!pManager)
        return;

    NSIndexSet* selection = [list selectedRowIndexes];
    NSMutableArray* cleared = [[NSMutableArray alloc] initWithCapacity:10];

    [selection enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL* stop) {
        id item = [list itemAtRow:idx];

	    if ([item isKindOfClass:[ResourceGroup class]])
	    {
		    ResourceGroup* group = (ResourceGroup*) item;

            if (pManager->resourceGroupExists([group->name UTF8String]))
                pManager->destroyResourceGroup([group->name UTF8String]);

            [self updateResourceGroup:group->name removable:YES];

            *stop = YES;
        }
        else
        {
            ResourceGroup* group = (ResourceGroup*) [list parentForItem:item];
            
            if (![cleared containsObject:group->name])
            {
                pManager->clearResourceGroup([group->name UTF8String]);
                [cleared addObject:group->name];
            }

            pManager->removeResourceLocation([item UTF8String], [group->name UTF8String]);
        }
    }];

    for (int i = 0; i < [cleared count]; ++i)
    {
        NSString* name = (NSString* )[cleared objectAtIndex:i];
        pManager->initialiseResourceGroup([name UTF8String]);
        [self updateResourceGroup:name removable:YES];
    }

    [cleared release];
}


- (void) resourceGroupUpdated:(NSNotification*)notification
{
    [self updateResourceGroup:[notification.userInfo objectForKey:@"groupName"] removable:NO];
}


- (void) updateResourceGroup:(NSString*)name removable:(BOOL)removable
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
            group->removable = removable;
            
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

- (void) outlineViewItemDidCollapse:(NSNotification*)notification
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


- (void) outlineViewItemDidExpand:(NSNotification*)notification
{
    [self outlineViewItemDidCollapse:notification];
}


- (void) outlineViewSelectionDidChange:(NSNotification*)notification
{
    [btnRemove setEnabled:([list numberOfSelectedRows] > 0)];
}


- (BOOL) outlineView:(NSOutlineView*)outlineView shouldSelectItem:(id)item
{
    if ([item isKindOfClass:[ResourceGroup class]])
        return ((ResourceGroup*) item)->removable;

    return ((ResourceGroup*) [list parentForItem:item])->removable;
}

@end
