// UIImage+RCRestTableView.m
// Copyright (c) 2015 Research Central (http://www.researchcentral.co/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "UIImage+RCRestTableView.h"

@implementation UIImage (RCRestTableView)

+ (UIImage*)findImageWithValue:(id)value{
	if ([value isKindOfClass:[UIImage class]])
		return value;
	if ([value isKindOfClass:[NSString class]] && [value length] >0) {
		UIImage *image;
		// Check if the image is in the bundle
		image = [UIImage imageNamed:value];
		if (image) return image;
		
		// Check if the image is in the documents directory
		NSString *imagePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",value];
		image = [self imageAtPath:imagePath];
		if (image) return image;
		
		// Check if the image is in the temporary directory
		imagePath = [NSTemporaryDirectory() stringByAppendingFormat:@"/%@",value];
		image = [self imageAtPath:imagePath];
		if (image) return image;
	}
	return nil;
}

+ (UIImage*)imageAtPath:(NSString*)path{
	NSData *data= [NSData dataWithContentsOfFile:path];
	return data ? [UIImage imageWithData:data] : nil;
}

@end
