//
//  DropboxImagesClient.h
//  WPImages
//
//  Created by Игорь Савельев on 19/10/14.
//  Copyright (c) 2014 Leonspok. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DropboxImagesClient : NSObject <NSURLSessionDownloadDelegate>

+ (instancetype)sharedClient;

- (void)loadImagesForPage:(NSUInteger)page
                  success:(void (^)(NSArray *newImageURLs))success
                  failure:(void (^)(NSError *error))failure;

- (void)getImageForURL:(NSURL *)url
               success:(void (^)(UIImage *image))success
               failure:(void (^)(NSError *error))failure;

@end
