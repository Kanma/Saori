#ifndef _MESHVIEWERSTATE_H_
#define _MESHVIEWERSTATE_H_

#include <Athena/GameStates/IGameState.h>


class MeshViewerState: public Athena::GameStates::IGameState
{
		//_____ Construction / Destruction __________
public:
	MeshViewerState();
	virtual ~MeshViewerState();


	//_____ Methods __________
public:
    bool loadMesh(const std::string& strFileName);
    
	
	//_____ Methods to be overriden by each state __________
public:
	virtual void enter();
	virtual void exit();
	virtual void pause();
	virtual void resume();

	virtual void process();


	//_____ Attributes __________
private:
	Athena::Entities::Scene*          m_pScene;
	Athena::Entities::Entity*         m_pEntity;
    Athena::Entities::Entity*         m_pCameraController;
    Athena::Entities::Transforms*     m_pCameraAxis;
    Athena::Graphics::Visual::Camera* m_pCamera;
    Ogre::Viewport*                   m_pViewport;
};

#endif
