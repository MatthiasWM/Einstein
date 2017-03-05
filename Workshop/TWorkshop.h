//
//  TWorkshop.h
//  Einstein
//
//  Created by Matthias Melcher on 2/27/17.
//
//

#ifndef TWorkshop_h
#define TWorkshop_h


class TEmulator;
class TWSProject;
class TWSProjectItem;


class TWorkshop
{
public:
	TWorkshop(TEmulator *emulator);
	virtual ~TWorkshop();
	void CompileAndRun();
	void NewProject(const char *name);
	TWSProject *GetProject() { return pProject; }
	TWSProjectItem *FindItemById(void *inId);
protected:
	virtual void UpdateProjectOutline();
	TEmulator*	pEmulator;
	TWSProject* pProject;
};


#endif /* TWorkshop_h */
