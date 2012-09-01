//
//  GLLBone.m
//  GLLara
//
//  Created by Torsten Kammer on 01.09.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "GLLBone.h"

#import "GLLModel.h"
#import "TRInDataStream.h"

@implementation GLLBone

- (id)initFromStream:(TRInDataStream *)stream partOfModel:(GLLModel *)model;
{
	if (!(self = [super init])) return nil;
	
	_model = model;
	
	_name = [stream readPascalString];
	_parentIndex = [stream readUint16];
	_defaultPositionX = [stream readFloat32];
	_defaultPositionY = [stream readFloat32];
	_defaultPositionZ = [stream readFloat32];
	
	return self;
}

#pragma mark -
#pragma mark Accessing the bones as a tree

// These methods are not the fastest way to do this (the fastest way would be to cache the results or load them explicitly once all bones have been loaded), but they are definitely the shortest way to write the code. Until I see proof that this causes problems, I prefer shorter.
- (GLLBone *)parent
{
	return self.model.bones[self.parentIndex];
}
- (NSArray *)children
{
	return [self.model.bones filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(GLLBone *bone, NSDictionary *bindings){
		return bone.parent == self;
	}]];
}

@end
