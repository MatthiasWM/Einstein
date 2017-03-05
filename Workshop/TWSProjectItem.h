//
//  TWSProject.hpp
//  Einstein
//
//  Created by Matthias Melcher on 3/4/17.
//
//

#ifndef TWSProject_hpp
#define TWSProject_hpp

#include <vector>

class TWorkshop;
class TWSProjectItem;

typedef std::vector<TWSProjectItem*> TWSProjectItemList;


class TWSProjectItem
{
public:
	TWSProjectItem(TWorkshop*);
	virtual ~TWSProjectItem();
	TWSProjectItem *SetName(const char*);
	const char *GetName();
	virtual const char *GetIcon() { return "tree_file.png"; }
	virtual int GetNumChildren() { return 0; }
	virtual TWSProjectItem *GetChild(int i) { return 0L; }
	virtual bool CanHaveChildren() { return false; }
	void *outlineId, *outlineTextId, *editorId;
private:
	TWorkshop*	pWorkshop;
	char *pName;
};


class TWSProjectItemWithChildren : public TWSProjectItem
{
public:
	TWSProjectItemWithChildren(TWorkshop*);
	virtual ~TWSProjectItemWithChildren();
	virtual int GetNumChildren();
	virtual TWSProjectItem *GetChild(int i);
	virtual const char *GetIcon() { return "tree_folder.png"; }
	virtual bool CanHaveChildren() { return true; }
	void AddChild(TWSProjectItem* inChild);
protected:
	TWSProjectItemList pChildList;
};


class TWSProject : public TWSProjectItemWithChildren
{
public:
	TWSProject(TWorkshop*);
	~TWSProject();
	virtual const char *GetIcon() { return "tree_app.png"; }
protected:
};


class TWSPackage : public TWSProjectItem
{
public:
	TWSPackage(TWorkshop*);
	~TWSPackage();
	virtual const char *GetIcon() { return "tree_pkg.png"; }
protected:
};


class TWSNewtonScript : public TWSProjectItem
{
public:
	TWSNewtonScript(TWorkshop*);
	~TWSNewtonScript();
	virtual const char *GetIcon() { return "tree_nsc.png"; }
protected:
};


#endif /* TWSProject_hpp */
