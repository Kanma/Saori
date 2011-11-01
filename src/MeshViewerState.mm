#import <MeshViewerState.h>
#import <Context.h>
#import <Athena-Entities/Scene.h>
#import <Athena-Entities/Entity.h>
#import <Athena-Entities/Transforms.h>
#import <Athena-Graphics/Visual/Object.h>
#import <Ogre/OgreResourceGroupManager.h>


using namespace Athena;
using namespace Athena::Entities;
using namespace Athena::Graphics;
using namespace Athena::Graphics::Visual;
using namespace Athena::Math;


static const char* __CONTEXT__ = "Mesh Viewer State";


/***************************** CONSTRUCTION / DESTRUCTION ******************************/

MeshViewerState::MeshViewerState()
: m_pEntity(0)
{
}


MeshViewerState::~MeshViewerState()
{
}


/************************************** METHODS ****************************************/

bool MeshViewerState::loadMesh(const std::string& strFileName)
{
    Scene* pScene = [Context context].scene;

    if (m_pEntity)
    {
        pScene->destroy(m_pEntity);
        m_pEntity = 0;
    }

    Ogre::ResourceGroupManager* pManager = Ogre::ResourceGroupManager::getSingletonPtr();

    if (pManager->resourceGroupExists("Content"))
        pManager->destroyResourceGroup("Content");

    size_t offset = strFileName.find_last_of("/");

    pManager->createResourceGroup("Content");
    pManager->addResourceLocation(strFileName.substr(0, offset), "FileSystem", "Content");
    pManager->initialiseResourceGroup("Content");


    m_pEntity = pScene->create("Mesh");

    Visual::Object* pObject = new Visual::Object("Mesh", m_pEntity->getComponentsList());
    return pObject->loadMesh(strFileName.substr(offset + 1));
}



/************************ METHODS TO BE OVERRIDEN BY EACH STATE ************************/

void MeshViewerState::enter()
{
}


void MeshViewerState::exit()
{
    if (m_pEntity)
    {
        Scene* pScene = [Context context].scene;
        pScene->destroy(m_pEntity);
        m_pEntity = 0;
    }

    Ogre::ResourceGroupManager* pManager = Ogre::ResourceGroupManager::getSingletonPtr();

    if (pManager->resourceGroupExists("Content"))
        pManager->destroyResourceGroup("Content");
}


void MeshViewerState::pause()
{
}


void MeshViewerState::resume()
{
}


void MeshViewerState::process()
{
}
