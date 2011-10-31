#ifndef _MESHVIEWERSTATE_H_
#define _MESHVIEWERSTATE_H_

#include <Athena/GameStates/IGameState.h>
#import "controls/View3D.h"


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
    View3D*                     m_view;
	Athena::Entities::Entity*   m_pEntity;
};

#endif
