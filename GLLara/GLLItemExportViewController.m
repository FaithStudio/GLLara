//
//  GLLItemExportViewController.m
//  GLLara
//
//  Created by Torsten Kammer on 19.09.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "GLLItemExportViewController.h"

@interface GLLItemExportViewController ()

@end

@implementation GLLItemExportViewController

- (id)init
{
	if (!(self = [super initWithNibName:@"GLLItemExportView" bundle:nil]))
		return nil;
    
    return self;
}

- (void)loadView
{
	// Load explicitly with this method, to make sure it goes through DMLocalizedNibBundle.
	[NSBundle loadNibNamed:self.nibName owner:self];
}

@end
