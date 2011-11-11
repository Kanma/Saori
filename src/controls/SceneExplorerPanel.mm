#import <controls/SceneExplorerPanel.h>
#import <Apple/ImageAndTextCell.h>
#import <Athena-Entities/ScenesManager.h>
#import <Athena-Entities/Scene.h>
#import <Athena-Entities/Entity.h>
#import <Athena-Entities/Transforms.h>


using namespace Athena;
using namespace Athena::Entities;


//----------------------------------------------------------------------------------------

@interface ComponentsGroup: NSObject
{
@public
    NSString*       name;
    NSMutableArray* components;
}

@end


@implementation ComponentsGroup
@end

//----------------------------------------------------------------------------------------

@interface ComponentProxy: NSObject
{
@public
    Entities::Component* pComponent;
    NSImage*             image;
}

@end


@implementation ComponentProxy
@end

//----------------------------------------------------------------------------------------

@interface EntityProxy: NSObject
{
@public
    Entity*         pEntity;
    NSMutableArray* groups;
    NSMutableArray* children;
}

@end


@implementation EntityProxy
@end

//----------------------------------------------------------------------------------------

@interface SceneProxy: NSObject
{
@public
    Scene*          pScene;
    NSMutableArray* groups;
    NSMutableArray* children;
}

@end


@implementation SceneProxy
@end

//----------------------------------------------------------------------------------------


@interface SceneExplorerPanel ()

- (NSImage*) loadImage:(NSString*)name;
- (EntityProxy*) processEntity:(Entity*)pEntity;
- (void) processComponentsOfType:(tComponentType)type
                   usingIterator:(ComponentsList::tComponentsIterator)iter
                   withGroupName:(NSString*)groupName
                    andDestArray:(NSMutableArray*)dest;

@end


@implementation SceneExplorerPanel


/*************************************** METHODS ****************************************/

- (id) initWithFrame:(NSRect)frame
{
    if ([super initWithFrame:frame])
    {
        imgFolderOpen   = [self loadImage:@"Icon_Folder_Open"];
        imgFolderClosed = [self loadImage:@"Icon_Folder_Closed"];
        
        
        ScenesManager* pManager = ScenesManager::getSingletonPtr();
        if (pManager)
        {
            scenes = [[NSMutableArray alloc] initWithCapacity:pManager->getNbScenes()];

            ScenesManager::tScenesIterator scenesIter = pManager->getScenesIterator();
            while (scenesIter.hasMoreElements())
            {
                Scene* pScene = scenesIter.getNext();
                
                SceneProxy* scene = [[SceneProxy alloc] init];
                scene->pScene     = pScene;
                scene->groups     = [[NSMutableArray alloc] initWithCapacity:0];
                scene->children   = [[NSMutableArray alloc] initWithCapacity:1];

                Scene::tEntitiesIterator entitiesIter = pScene->getEntitiesIterator();
                while (entitiesIter.hasMoreElements())
                {
                    Entity* pEntity = entitiesIter.getNext();
                    [scene->children addObject:[self processEntity:pEntity]];
                }

                [scenes addObject:scene];
                [scene release];
            }
        }
        
        // 
        // 
        // [self updateResourceGroup:@"General" removable:NO];
        // 
        // [[NSNotificationCenter defaultCenter] addObserver:self
        //                                          selector:@selector(resourceGroupUpdated:)
        //                                              name:@"SaoriResourceGroupUpdated"
        //                                            object:nil ];
    }
    
    return self;
}


- (NSImage*) loadImage:(NSString*)name
{
    NSString* path = [[[NSBundle mainBundle] bundlePath] stringByAppendingFormat:@"/Contents/Resources/%@.png", name];
    NSImage* image = [[NSImage alloc] initWithContentsOfFile:path];
    [image setSize:NSMakeSize(16,16)];
    return image;
}


- (EntityProxy*) processEntity:(Entity*)pEntity
{
    EntityProxy* entity = [[EntityProxy alloc] init];
    entity->pEntity     = pEntity;
    entity->groups      = [[NSMutableArray alloc] initWithCapacity:0];
    entity->children    = [[NSMutableArray alloc] initWithCapacity:pEntity->getNbChildren()];

    // Transforms
    [self processComponentsOfType:COMP_TRANSFORMS
                    usingIterator:pEntity->getComponentsIterator()
                    withGroupName:@"Transforms"
                     andDestArray:entity->groups];

    // Visual
    [self processComponentsOfType:COMP_VISUAL
                    usingIterator:pEntity->getComponentsIterator()
                    withGroupName:@"Visual"
                     andDestArray:entity->groups];


    // Audio
    [self processComponentsOfType:COMP_AUDIO
                    usingIterator:pEntity->getComponentsIterator()
                    withGroupName:@"Audio"
                     andDestArray:entity->groups];
    
    // Physical
    [self processComponentsOfType:COMP_PHYSICAL
                    usingIterator:pEntity->getComponentsIterator()
                    withGroupName:@"Physical"
                     andDestArray:entity->groups];
    
    // Other
    [self processComponentsOfType:COMP_OTHER
                    usingIterator:pEntity->getComponentsIterator()
                    withGroupName:@"Other"
                     andDestArray:entity->groups];
    
    // Children
    Entity::ChildrenIterator childrenIter = pEntity->getChildrenIterator();
    while (childrenIter.hasMoreElements())
    {
        Entity* pChild = childrenIter.getNext();
        [entity->children addObject:[self processEntity:pChild]];
    }

    return [entity autorelease];
}


- (void) processComponentsOfType:(tComponentType)type
                   usingIterator:(ComponentsList::tComponentsIterator)iter
                   withGroupName:(NSString*)groupName
                    andDestArray:(NSMutableArray*)dest
{
    ComponentsGroup* group = nil;
    while (iter.hasMoreElements())
    {
        Entities::Component* pComponent = iter.getNext();
        
        if (pComponent->getID().type == type)
        {
            if (!group)
            {
                group = [[ComponentsGroup alloc] init];
                group->name = groupName;
                group->components = [[NSMutableArray alloc] initWithCapacity:0];
            }
            
            ComponentProxy* component = [[ComponentProxy alloc] init];
            component->pComponent = pComponent;
            component->image = nil;
            
            [group->components addObject:component];
            [component release];
        }
    }

    if (group)
    {
        if ([group->components count] > 0)
            [dest addObject:group];

        [group release];
    }
}


/******************************* IMPLEMENTATION OF Panel ********************************/

- (void) setup
{
    NSTableColumn* column = [[list tableColumns] objectAtIndex:0];
    ImageAndTextCell* cell = [[[ImageAndTextCell alloc] init] autorelease];
    [column setDataCell:cell];
}


/********************** IMPLEMENTATION OF NSOutlineViewDataSource ***********************/

- (id) outlineView:(NSOutlineView*)outlineView child:(NSInteger)index ofItem:(id)item
{
	if (!item)
    	return [scenes objectAtIndex:index];

	if ([item isKindOfClass:[SceneProxy class]])
	{
        SceneProxy* scene = (SceneProxy*) item;
        
        int nb_groups = [scene->groups count];
        
        if (index < nb_groups)
            return [scene->groups objectAtIndex:index];
        else
            return [scene->children objectAtIndex:index-nb_groups];
    }

	if ([item isKindOfClass:[EntityProxy class]])
	{
        EntityProxy* entity = (EntityProxy*) item;
        
        int nb_groups = [entity->groups count];
        
        if (index < nb_groups)
            return [entity->groups objectAtIndex:index];
        else
            return [entity->children objectAtIndex:index-nb_groups];
    }

	if ([item isKindOfClass:[ComponentsGroup class]])
	{
        ComponentsGroup* group = (ComponentsGroup*) item;
        return [group->components objectAtIndex:index];
    }

    return nil;
}


- (BOOL) outlineView:(NSOutlineView*)outlineView isItemExpandable:(id)item
{
    return ([item isKindOfClass:[SceneProxy class]] ||
            [item isKindOfClass:[EntityProxy class]] ||
            [item isKindOfClass:[ComponentsGroup class]]);
}


- (NSInteger) outlineView:(NSOutlineView*)outlineView numberOfChildrenOfItem:(id)item
{
	if (!item)
    	return [scenes count];

	if ([item isKindOfClass:[SceneProxy class]])
	{
        SceneProxy* scene = (SceneProxy*) item;
		return [scene->groups count] + [scene->children count];
    }

	if ([item isKindOfClass:[EntityProxy class]])
	{
        EntityProxy* entity = (EntityProxy*) item;
		return [entity->groups count] + [entity->children count];
    }

	if ([item isKindOfClass:[ComponentsGroup class]])
	{
        ComponentsGroup* group = (ComponentsGroup*) item;
        return [group->components count];
    }

	return 0;
}


- (id) outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	if (!item)
    	return @"Scenes";

	if ([item isKindOfClass:[SceneProxy class]])
	{
        SceneProxy* scene = (SceneProxy*) item;
		return [NSString stringWithUTF8String:scene->pScene->getName().c_str()];
    }

	if ([item isKindOfClass:[EntityProxy class]])
	{
        EntityProxy* entity = (EntityProxy*) item;
		return [NSString stringWithUTF8String:entity->pEntity->getName().c_str()];
    }

	if ([item isKindOfClass:[ComponentsGroup class]])
        return ((ComponentsGroup*) item)->name;

	if ([item isKindOfClass:[ComponentProxy class]])
	{
        ComponentProxy* component = (ComponentProxy*) item;
		return [NSString stringWithUTF8String:component->pComponent->getName().c_str()];
    }

	return item;
}


/*********************** IMPLEMENTATION OF NSOutlineViewDelegate ************************/

- (void) outlineView:(NSOutlineView*)outlineView willDisplayCell:(id)cell
      forTableColumn:(NSTableColumn*)tableColumn item:(id)item
{
    [(ImageAndTextCell*) cell setImage:imgFolderOpen];
}

@end
