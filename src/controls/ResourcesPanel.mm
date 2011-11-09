#import <controls/ResourcesPanel.h>
#import <Ogre/OgreResourceGroupManager.h>


@implementation ResourcesPanel


/*************************************** METHODS ****************************************/

- (id) initWithFrame:(NSRect)frame
{
    if ([super initWithFrame:frame])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateResourceLocations:)
                                                     name:@"SaoriResourcesGroupChanged"
                                                   object:nil ];
    }
    
    return self;
}


- (void) updateResourceLocations:(NSNotification*)notification
{
    if (locations)
    {
        [locations release];
        locations = nil;
    }

    Ogre::ResourceGroupManager* pManager = Ogre::ResourceGroupManager::getSingletonPtr();
    if (pManager && pManager->resourceGroupExists("Content"))
    {
        Ogre::StringVectorPtr list = pManager->listResourceLocations("Content");
        locations = [[NSMutableArray alloc] initWithCapacity:list->size()];
        
        Ogre::VectorIterator<Ogre::StringVector> iter(list->begin(), list->end());
        while (iter.hasMoreElements())
        {
            Ogre::String location = iter.getNext();
            [locations addObject:[NSString stringWithUTF8String:location.c_str()]];
        }
    }

    if (notification)
        [browser reloadColumn:0];
}


/************************* IMPLEMENTATION OF NSBrowserDelegate **************************/

- (NSInteger) browser:(NSBrowser*)sender numberOfRowsInColumn:(NSInteger)column
{
    if (!locations)
        [self updateResourceLocations:nil];

    if (!locations)
        return 0;

    return [locations count];
}


- (void) browser:(NSBrowser*)sender willDisplayCell:(id)cell atRow:(NSInteger)row column:(NSInteger)column
{
    NSBrowserCell* c = (NSBrowserCell*) cell;
    
    [c setStringValue:(NSString*) [locations objectAtIndex:row]];
    [c setLeaf:YES];
}

@end
