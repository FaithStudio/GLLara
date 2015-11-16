//
//  GLLMeshDrawer.m
//  GLLara
//
//  Created by Torsten Kammer on 01.09.12.
//  Copyright (c) 2012 Torsten Kammer. All rights reserved.
//

#import "GLLMeshDrawer.h"

#import <OpenGL/gl3.h>

#import "NSArray+Map.h"
#import "GLLModelMesh.h"
#import "GLLModelProgram.h"
#import "GLLVertexFormat.h"
#import "GLLUniformBlockBindings.h"
#import "GLLResourceManager.h"
#import "GLLTexture.h"
#import "LionSubscripting.h"

@interface GLLMeshDrawer ()
{
	GLuint vertexArray;
	GLsizei elementsCount;
    GLenum elementType;
}

@end

@implementation GLLMeshDrawer

- (id)initWithMesh:(GLLModelMesh *)mesh resourceManager:(GLLResourceManager *)resourceManager error:(NSError *__autoreleasing*)error;
{
	if (!(self = [super init])) return nil;
	
	_modelMesh = mesh;
			
	// Create the element and vertex buffers, and spend a lot of time setting up the vertex attribute arrays and pointers.
	glGenVertexArrays(1, &vertexArray);
	glBindVertexArray(vertexArray);
	
	GLuint buffers[2];
	glGenBuffers(2, buffers);
	
	glBindBuffer(GL_ARRAY_BUFFER, buffers[0]);
	glBufferData(GL_ARRAY_BUFFER, mesh.vertexData.length, mesh.vertexData.bytes, GL_STATIC_DRAW);
	
	glEnableVertexAttribArray(GLLVertexAttribPosition);
	glVertexAttribPointer(GLLVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, (GLsizei) mesh.vertexFormat.stride, (GLvoid *) mesh.vertexFormat.offsetForPosition);
	
	glEnableVertexAttribArray(GLLVertexAttribNormal);
	glVertexAttribPointer(GLLVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, (GLsizei) mesh.vertexFormat.stride, (GLvoid *) mesh.vertexFormat.offsetForNormal);
	
	glEnableVertexAttribArray(GLLVertexAttribColor);
	glVertexAttribPointer(GLLVertexAttribColor, 4, GL_UNSIGNED_BYTE, GL_TRUE, (GLsizei) mesh.vertexFormat.stride, (GLvoid *) mesh.vertexFormat.offsetForColor);
	
	if (mesh.hasBoneWeights)
	{
		glEnableVertexAttribArray(GLLVertexAttribBoneIndices);
		glVertexAttribIPointer(GLLVertexAttribBoneIndices, 4, GL_UNSIGNED_SHORT, (GLsizei) mesh.vertexFormat.stride, (GLvoid *) mesh.vertexFormat.offsetForBoneIndices);
		
		glEnableVertexAttribArray(GLLVertexAttribBoneWeights);
		glVertexAttribPointer(GLLVertexAttribBoneWeights, 4, GL_FLOAT, GL_FALSE, (GLsizei) mesh.vertexFormat.stride, (GLvoid *) mesh.vertexFormat.offsetForBoneWeights);
	}
	
	for (GLuint i = 0; i < mesh.countOfUVLayers; i++)
	{
		glEnableVertexAttribArray(GLLVertexAttribTexCoord0 + 2*i);
		glVertexAttribPointer(GLLVertexAttribTexCoord0 + 2*i, 2, GL_FLOAT, GL_FALSE, (GLsizei) mesh.vertexFormat.stride, (GLvoid *) [mesh.vertexFormat offsetForTexCoordLayer:i]);
		
		if (mesh.hasTangents)
		{
			glEnableVertexAttribArray(GLLVertexAttribTangent0 + 2*i);
			glVertexAttribPointer(GLLVertexAttribTangent0 + 2*i, 4, GL_FLOAT, GL_FALSE, (GLsizei) mesh.vertexFormat.stride, (GLvoid *) [mesh.vertexFormat offsetForTangentLayer:i]);
		}
    }
    
    elementsCount = (GLsizei) mesh.countOfElements;
    const GLuint *elements = mesh.elementData.bytes;
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, buffers[1]);
    if (mesh.countOfVertices < UINT8_MAX) {
        elementType = GL_UNSIGNED_BYTE;
        uint8_t *data = malloc(elementsCount * 2);
        for (GLsizei i = 0; i < elementsCount; i++)
            data[i] = (uint8_t) elements[i];
        
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, elementsCount, data, GL_STATIC_DRAW);
        free(data);
    } else if (mesh.countOfVertices < UINT16_MAX) {
        elementType = GL_UNSIGNED_SHORT;
        uint16_t *data = malloc(elementsCount * 2);
        for (GLsizei i = 0; i < elementsCount; i++)
            data[i] = (uint16_t) elements[i];
        
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, elementsCount * 2, data, GL_STATIC_DRAW);
        free(data);
    } else {
        elementType = GL_UNSIGNED_INT;
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, elementsCount * 4, elements, GL_STATIC_DRAW);
    }
	
	glBindVertexArray(0);
	glDeleteBuffers(2, buffers);
	
	return self;
}

- (void)draw;
{
	// Set standard vertex attribs for optional items
	glVertexAttrib4usv(GLLVertexAttribBoneIndices, (const GLushort [4]) { 0, 0, 0, 0 });
	glVertexAttrib4f(GLLVertexAttribBoneIndices, 1.0f, 0.0f, 0.0f, 0.0f);
	glVertexAttrib4f(GLLVertexAttribTangent0, 0.0f, 0.0f, 0.0f, 0.0f);
	glVertexAttrib2f(GLLVertexAttribTexCoord0 + 2U, 0.0f, 0.0f);
	glVertexAttrib4f(GLLVertexAttribTangent0 + 3U, 0.0f, 0.0f, 0.0f, 0.0f);
	
	// Load and draw the vertices
	glBindVertexArray(vertexArray);
	glDrawElements(GL_TRIANGLES, elementsCount, elementType, NULL);
}

- (void)unload
{
	glDeleteVertexArrays(1, &vertexArray);
	vertexArray = 0;
	elementsCount = 0;
}

- (void)dealloc
{
	NSAssert(vertexArray == 0 && elementsCount == 0, @"Did not call unload before calling dealloc!");
}

@end
