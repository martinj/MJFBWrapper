/*
 *
 * MJFBAttachmentImageShackMedia.m
 *  
 * Copyright (c) 2010, Martin Jonsson
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * * Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 * * Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 * * Neither the name of the <organization> nor the
 * names of its contributors may be used to endorse or promote products
 * derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED ''AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL <copyright holder> BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
#import "MJFBAttachmentImageShackMedia.h"


@implementation MJFBAttachmentImageShackMedia
@synthesize image = _image, path = _path;

- (id)initWithImage:(UIImage *)image {
	if (self = [super init]) {
		self.image = image;
	}
	
	return self;
}

- (id)initWithImage:(UIImage *)image href:(NSString *)href{
	if (self = [self initWithImage:image]) {
		self.href = href;
	}
	
	return self;
}

- (id)initWithImagePath:(NSString *)path {
	if (self = [super init]) {
		self.path = path;
	}
	
	return self;
}

- (id)initWithImagePath:(NSString *)path href:(NSString *)href {
	if (self = [self initWithImagePath:path]) {
		self.href = href;
	}
	
	return self;
}

+ (MJFBAttachmentImageShackMedia *)mediaWithImage:(UIImage *)image {
	return [[[MJFBAttachmentImageShackMedia alloc] initWithImage:image] autorelease];
}

+ (MJFBAttachmentImageShackMedia *)mediaWithImage:(UIImage *)image href:(NSString *)href {
	return [[[MJFBAttachmentImageShackMedia alloc] initWithImage:image href:href] autorelease];
}

+ (MJFBAttachmentImageShackMedia *)mediaWithImagePath:(NSString *)path {
	return [[[MJFBAttachmentImageShackMedia alloc] initWithImagePath:path] autorelease];
}

+ (MJFBAttachmentImageShackMedia *)mediaWithImagePath:(NSString *)path href:(NSString *)href {
	return [[[MJFBAttachmentImageShackMedia alloc] initWithImagePath:path href:href] autorelease];
}

- (NSString *)description {
	if (self.src == nil) {
		MJImageShackUploader *uploader = [[MJImageShackUploader alloc] init];
		NSDictionary *links;
		
		if (self.image != nil) {
			links = [uploader uploadImageSynchronous:self.image];
		} else {
			links = [uploader uploadImageFromPathSynchronous:self.path];
		}
		
		[uploader release];
		
		if (self.href == nil) {
			self.href = [links objectForKey:@"yfrog_link"];
		}
		
		self.src = [links objectForKey:@"image_link"];
	}
	
	return [self buildJSONString];
}

- (void)dealloc {
	[_image release];
	[_path release];
	[super dealloc];
}
@end
