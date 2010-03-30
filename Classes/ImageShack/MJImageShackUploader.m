/*
 *
 * MJImageShackUploader.m
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
#import "MJImageShackUploader.h"
#define CONNECTION_ERROR 1
#define IMAGESHACK_IMAGE_UPLOAD_URL @"http://www.imageshack.us/upload_api.php"

@implementation MJImageShackUploader
@synthesize delegate = _delegate, connection, xmlElementContent;

#pragma mark delegate
- (void)didFailWithError:(NSError *)error {
	if (self.delegate && [self.delegate respondsToSelector:@selector(uploader:didFailWithError:)]) {
		[self.delegate uploader:self didFailWithError:error];
	}	
}

- (void)didUploadImageWithResult:(NSDictionary *)result {
	if (self.delegate && [self.delegate respondsToSelector:@selector(uploader:didUploadImageWithResult:)]) {
		[self.delegate uploader:self didUploadImageWithResult:result];
	}	 	
}


#pragma mark private methods
- (NSDictionary *)parseResponseData:(NSData *)responseData {
	/*
	NSString *str = [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
	NSLog(@"RESPONSE %@", str);
	[str release];
	*/
	
	parsedResponse = [[NSMutableDictionary alloc] init];
	
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:responseData];
	[parser setDelegate:self];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	grabXMLContent = NO;
	
	[parser parse];
	[parser release];
	
	NSDictionary *response = [NSDictionary dictionaryWithDictionary:parsedResponse];
	[parsedResponse release];
	return response;
}

- (NSDictionary *)postWithImageData:(NSData *)imageData asynchronous:(BOOL)asynchronous{
	if (recievedData == nil) {
		recievedData = [[NSMutableData alloc] init];
	}
	
	NSString *boundary = @"0123456789IMAGESHACK_API9876543210";	
	NSURL *url = [NSURL URLWithString:IMAGESHACK_IMAGE_UPLOAD_URL];

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:@"POST"];
	[request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-type"];
	
	NSMutableData *postData = [NSMutableData data];
	[postData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[@"Content-Disposition: form-data; name=\"fileupload\"; filename=\"image\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[@"Content-Type: image/jpeg\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[@"Content-Transfer-Encoding: binary\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:imageData];
	[postData appendData:[[NSString stringWithString:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[request setHTTPBody:postData];
	
	if (asynchronous) {
		self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
		if (self.connection == nil) {
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys: @"Couldn't initialize connection", NSLocalizedDescriptionKey, nil];
			NSError *error = [NSError errorWithDomain:@"MJImageShackUploaderError" code:CONNECTION_ERROR userInfo:userInfo];		
			[self didFailWithError:error];
		} else {
			[self.connection start];
		}
	} else {
		self.connection = nil;
		NSError *error;
		NSURLResponse *response;
		NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

		if (response == nil || responseData == nil || error != nil) {
			[self didFailWithError:error];
		} else {
			return [self parseResponseData:responseData];
		}		
	}
	
	return nil;
}

#pragma mark public methods
- (void)uploadImage:(UIImage *)image {
	[self postWithImageData:UIImageJPEGRepresentation(image, 1) asynchronous:YES];
}

- (void)uploadImageFromPath:(NSString *)path {
	[self postWithImageData:[NSData dataWithContentsOfFile:path] asynchronous:YES];
}

- (NSDictionary *)uploadImageSynchronous:(UIImage *)image {
	return [self postWithImageData:UIImageJPEGRepresentation(image, 1) asynchronous:NO];
}

- (NSDictionary *)uploadImageFromPathSynchronous:(NSString *)path {
	return [self postWithImageData:[NSData dataWithContentsOfFile:path] asynchronous:NO];
}


#pragma mark NSURLConnection Delegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[self didFailWithError:error];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[recievedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[recievedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection 
   didSendBodyData:(NSInteger)bytesWritten 
 totalBytesWritten:(NSInteger)totalBytesWritten 
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSDictionary *response = [self parseResponseData:recievedData];
	[self didUploadImageWithResult:response];
	[recievedData setLength:0];																											
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
	return cachedResponse;
}

#pragma mark NSXMLParser delegate
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if (qName) 
        elementName = qName;
	

	if ([elementName isEqualToString:@"links"]) {
		grabXMLContent = YES;
		self.xmlElementContent = nil;
	} else if (grabXMLContent) {
		self.xmlElementContent = [NSMutableString string];
	} else {
		self.xmlElementContent = nil;
	}
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {     
    if (qName)
        elementName = qName;
    
	if ([elementName isEqualToString:@"links"]) {
		[parser abortParsing];
	} else if (grabXMLContent) {
		[parsedResponse setObject:[self.xmlElementContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:elementName];
	}
	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (self.xmlElementContent)
		[self.xmlElementContent appendString:string];
}


#pragma mark Memory Managment
- (void)dealloc {
	[xmlElementContent release];
	[connection release];
	[recievedData release];
	[super dealloc];
}

@end
