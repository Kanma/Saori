#include <MeshViewerState.h>
#include <Athena/Engine.h>
#include <Athena/Tasks/TaskManager.h>
#include <Athena/GameStates/GameStateManager.h>
#include <Athena-Entities/Scene.h>
#include <Athena-Entities/Entity.h>
#include <Athena-Entities/Transforms.h>
#include <Athena-Graphics/Visual/Object.h>
#include <Ogre/OgreRoot.h>
#include <Ogre/OgreRenderWindow.h>
#include <Ogre/OgreSceneManager.h>
#include <Ogre/OgreResourceGroupManager.h>


using namespace Athena;
using namespace Athena::Entities;
using namespace Athena::Graphics;
using namespace Athena::Graphics::Visual;
using namespace Athena::Math;


static const char* __CONTEXT__ = "Mesh Viewer State";


/***************************** CONSTRUCTION / DESTRUCTION ******************************/

MeshViewerState::MeshViewerState()
: m_view(nil), m_pEntity(0)
{
}


MeshViewerState::~MeshViewerState()
{
}


/************************************** METHODS ****************************************/

bool MeshViewerState::loadMesh(const std::string& strFileName)
{
    if (m_pEntity)
    {
        m_view.scene->destroy(m_pEntity);
        m_pEntity = 0;
    }

    Ogre::ResourceGroupManager* pManager = Ogre::ResourceGroupManager::getSingletonPtr();

    if (pManager->resourceGroupExists("Content"))
        pManager->destroyResourceGroup("Content");

    size_t offset = strFileName.find_last_of("/");

    pManager->createResourceGroup("Content");
    pManager->addResourceLocation(strFileName.substr(0, offset), "FileSystem", "Content");
    pManager->initialiseResourceGroup("Content");


    m_pEntity = m_view.scene->create("Mesh");

    Visual::Object* pObject = new Visual::Object("Mesh", m_pEntity->getComponentsList());
    if (pObject->loadMesh(strFileName.substr(offset + 1)))
        [m_view frameAll];
}



/************************ METHODS TO BE OVERRIDEN BY EACH STATE ************************/

void MeshViewerState::enter()
{
    m_view = [[View3D alloc] initWithRenderWindow:Engine::getSingletonPtr()->getMainWindow()];
}


void MeshViewerState::exit()
{
    [m_view release];

    m_view    = nil;
    m_pEntity = 0;
}


void MeshViewerState::pause()
{
}


void MeshViewerState::resume()
{
}


void MeshViewerState::process()
{
    [m_view rotateBy:Degree(1.0f) around:Vector3::UNIT_Y];
}
