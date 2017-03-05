//
//  TCocoaWorkshopController.mm
//  Einstein
//
//  Created by Matthias Melcher on 2/27/2017.
//

#import "TCocoaWorkshopController.h"
//#import "Monitor/TMacMonitor.h"
#import "TCocoaUserDefaults.h"
#import "TMacWorkshop.h"
//#import "TMonitorCore.h"

#include "Workshop/TWSProjectItem.h"


@interface TCocoaWorkshopController ()
//- (void)update;
@end

@implementation TCocoaWorkshopController

//- (void)addHistoryLine:(NSString *)line type:(int)type
//{
//	[view addHistoryLine:line type:type];
//}


- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	[[self window] setDelegate:nil];	// so windowWillClose doesn't get called
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)awakeFromNib
{
	[[self window] setDelegate:self];

//	[view setController:self];
//
//	[self update];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:NSApplicationWillTerminateNotification object:nil];
}


//- (void)executeCommand:(NSString*)command
//{
//	[self addHistoryLine:[NSString stringWithFormat:@"> %@", command] type:MONITOR_LOG_USER_INPUT];
//
//	monitor->ExecuteCommand([command UTF8String]);
//	[self performSelector:@selector(update) withObject:nil afterDelay:0.0];
//
//	if ( [command isEqualToString:@"run"] )
//	{
//		[stopStartButton setTitle:@"Stop"];
//	}
//	else if ( [command isEqualToString:@"stop"] )
//	{
//		[stopStartButton setTitle:@"Run"];
//	}
//}


- (void)setWorkshop:(TMacWorkshop*)inWorkshop
{
	workshop = inWorkshop;
	//workshop->SetController(self);
}


- (void)showWindow:(id)sender
{
	[super showWindow:sender];

	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kOpenWorkshopAtLaunch];
	[[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)newProject:(id)sender
{
	workshop->NewProject("HelloWorld");
}


- (void)compileAndRun:(id)sender
{
	printf("0x%016lx\n", (uintptr_t)workshop);
	workshop->CompileAndRun();
}


//- (IBAction)stepInto:(id)sender
//{
//	monitor->ExecuteCommand("step");
//	[self performSelector:@selector(update) withObject:nil afterDelay:0.0];
//}


//- (IBAction)stepOver:(id)sender
//{
//	monitor->ExecuteCommand("trace");
//	[self performSelector:@selector(update) withObject:nil afterDelay:0.0];
//}

//- (void)stopStart:(id)sender
//{
//	if ( monitor )
//	{
//		if ( monitor->IsHalted() )
//		{
//			monitor->ExecuteCommand("run");
//		}
//		else
//		{
//			monitor->ExecuteCommand("stop");
//		}
//
//		[self performSelector:@selector(update) withObject:nil afterDelay:0.0];
//	}
//	else
//	{
//		[self performSelector:@selector(update) withObject:nil afterDelay:0.0];
//	}
//}


//- (void)update
//{
//	if ( monitor )
//	{
//		[view updateWithMonitor:monitor];
//
//		if ( monitor->IsHalted() )
//		{
//			[stepIntoButton setEnabled:YES];
//			[stepOverButton setEnabled:YES];
//			[stopStartButton setTitle:@"Run"];
//		}
//		else
//		{
//			[stepIntoButton setEnabled:NO];
//			[stepOverButton setEnabled:NO];
//			[stopStartButton setTitle:@"Stop"];
//		}
//
//		[stopStartButton setEnabled:YES];
//	}
//	else
//	{
//		[stepIntoButton setEnabled:NO];
//		[stepOverButton setEnabled:NO];
//		[stopStartButton setEnabled:NO];
//		[stopStartButton setTitle:@"Run"];
//	}
//}


- (void)windowWillClose:(NSNotification *)notification
{
//	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:kOpenWorkshopAtLaunch];
	[[NSUserDefaults standardUserDefaults] synchronize];
}



// Method returns count of children for given tree node item
- (NSInteger)outlineView:(NSOutlineView *)outlineView
  numberOfChildrenOfItem:(id)item
{
	if (!workshop) return 0;
	if (item) {
		TWSProjectItem *it = (TWSProjectItem*)[item pointerValue];
		return it->GetNumChildren();
	} else {
		if (workshop->GetProject()) {
			return 1;
		} else {
			return 0;
		}
	}
}


// Method returns flag, whether we can expand given tree node item or not
// (here is the simple rule, we can expand only nodes having one and more children)
- (BOOL)outlineView:(NSOutlineView *)outlineView
   isItemExpandable:(id)item
{
	if (!workshop) return 0;
	if (item) {
		TWSProjectItem *it = (TWSProjectItem*)[item pointerValue];
		return it->CanHaveChildren();
	} else {
		return YES;
	}
}


// Method returns value to be shown for given column of the tree node item
- (id)outlineView:(NSOutlineView *)outlineView
  objectValueForTableColumn:(NSTableColumn *)tableColumn
					 byItem:(id)item
{
	if (!workshop) return 0;
	if (!item) return 0;
	TWSProjectItem *it = (TWSProjectItem*)[item pointerValue];

	if (it->outlineTextId) {
		id value = (__bridge id)it->outlineTextId; // TODO: yes, this is a memory leak.
		return value;
	} else {
		NSImage* icon = [NSImage imageNamed:[NSString stringWithUTF8String:it->GetIcon()]];
		NSString* title = [NSString stringWithUTF8String:it->GetName()];
		id value = nil;

		if (icon) { // 17x17
			NSTextAttachment* attachment = [[NSTextAttachment alloc] init];
			[(NSCell *)[attachment attachmentCell] setImage: icon];
			NSMutableAttributedString *aString = [[NSAttributedString attributedStringWithAttachment:attachment] mutableCopy];
			[[aString mutableString] appendFormat: @" %@", title]; // myst have space for alignment to work :-(
			[aString addAttribute: NSBaselineOffsetAttributeName
							value: [NSNumber numberWithFloat: -5.0]
							range: NSMakeRange(0, 1 /*aString.length*/)];
			value = aString;
		} else {
			value = title;
		}
		it->outlineTextId = (__bridge_retained void*)value;
		return value;
	}
}



//NSValue* value = [NSValue valueWithPointer: myPointer];
//void* myPointer = [value pointerValue];

// Method returns children item for given tree node item by given index
- (id)outlineView:(NSOutlineView *)outlineView
			child:(NSInteger)index
		   ofItem:(id)item
{
	TWSProjectItem *parent = 0;
	TWSProjectItem *child = 0;
	if (!workshop) return 0;
	if (item) {
		parent = (TWSProjectItem*)[item pointerValue];
		child = parent->GetChild(index);
	} else {
		child = workshop->GetProject();
	}
	if (child) {
		id childId;
		if (!child->outlineId) {
			childId = [NSValue valueWithPointer:child];
			child->outlineId = (__bridge_retained void*)childId;
		} else {
			childId = (__bridge id)child->outlineId;
		}
		return childId;
	} else {
		return 0L;
	}
}

/*
 Add a text view:
 
 NSTextView *text = [[NSTextView alloc] initWithFrame:CGRectMake(...)];
 text.backgroundColor = [UIColor greenColor];
 [text setDelegate:self];
 [self.view addSubView:text];

 -(BOOL)textView ... shouldChangeTextInRange...
*/
- (IBAction)selectProjectItem:(id)sender
{
	//NSTableView* tableView = (NSTableView*)sender;
	NSOutlineView *outline = (NSOutlineView*)sender;
	NSInteger row = [outline clickedRow];
	if (row==-1) return;
	id item = [sender itemAtRow:row];
	TWSProjectItem *it = (TWSProjectItem*)[item pointerValue];
	if (it) {
		if (it->editorId) {
			[contentTab selectTabViewItemWithIdentifier:item];
		} else {
			// either we create an editor or do nothing
			TWSNewtonScript *ns = dynamic_cast<TWSNewtonScript*>(it);
			if (ns) {
				// create a source code editor
				// cretae the tab
				NSTabViewItem *tab = [[NSTabViewItem alloc] initWithIdentifier:item];
				[tab setLabel:[NSString stringWithUTF8String:it->GetName()]];
				[contentTab addTabViewItem:tab];
				// create the editor
				NSTextView *textEdit = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, contentTab.bounds.size.width, contentTab.bounds.size.height)];
				[textEdit setString:[NSString stringWithUTF8String:it->GetName()]];
				[tab setView:textEdit];
				// show the Tab
				[contentTab selectTabViewItem:tab];
				it->editorId = (__bridge_retained void*)textEdit;
			} else {
				// do nothing
			}
		}
	}
}

- (void)UpdateProjectOutline
{
	[projectOutlineView reloadItem:0L reloadChildren:YES];
}

void WorkshopControllerUpdateProjectOutline(TCocoaWorkshopController *self)
{
	return [(id) self UpdateProjectOutline];
}


@end
