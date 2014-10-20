//
//  DropboxImagesClient.m
//  WPImages
//
//  Created by Игорь Савельев on 19/10/14.
//  Copyright (c) 2014 Leonspok. All rights reserved.
//

#import "DropboxImagesClient.h"
#import	<CommonCrypto/CommonDigest.h>

@implementation NSString (Hash)

- (NSString *)md5String {
    const char *data = [self UTF8String];
    unsigned char hashBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data, strlen(data), hashBuffer);
    NSMutableString *resultString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for (int i= 0;	i < CC_MD5_DIGEST_LENGTH; i++) {
        [resultString appendFormat:@"%02X", hashBuffer[i]];
    }
    return resultString;
}

@end

@implementation DropboxImagesClient {
    NSURLSession *jsonLoadSession;
    NSURLSession *imageDownloadSession;
    
    NSMutableDictionary *downloadCompletionHandlers;
    
    NSURL *baseURL;
    NSURL *cacheFolderURL;
    
    NSMutableDictionary *pages;
}

- (id)init {
    self = [super init];
    if (self) {
        jsonLoadSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        imageDownloadSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:NSStringFromClass(self.class)] delegate:self delegateQueue:[NSOperationQueue new]];
        
        pages = [NSMutableDictionary dictionary];
        downloadCompletionHandlers = [NSMutableDictionary dictionary];
        
        baseURL = [NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/55523423/Nature/"];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        cacheFolderURL = [NSURL fileURLWithPath:[paths firstObject]];
    }
    return self;
}

+ (instancetype)sharedClient {
    static DropboxImagesClient *imagesClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imagesClient = [[DropboxImagesClient alloc] init];
    });
    return imagesClient;
}

- (void)loadImagesForPage:(NSUInteger)page success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure {
    NSArray *imagesURLs = [pages objectForKey:[NSNumber numberWithInteger:page]];
    if (imagesURLs) {
        if (success) {
            success(imagesURLs);
        }
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%ld.json", (long)page] relativeToURL:baseURL];
    [jsonLoadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        for (NSURLSessionDataTask *task in dataTasks) {
            if ((task.state == NSURLSessionTaskStateSuspended || NSURLSessionTaskStateRunning) && [task.originalRequest.URL isEqual:url]) {
                if (success) {
                    success([NSArray array]);
                }
                return;
            }
        }
        
        [[jsonLoadSession dataTaskWithRequest:[NSURLRequest requestWithURL:url] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                if (failure) {
                    failure(error);
                }
            } else {
                NSError *error;
                NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                if (error) {
                    if (failure) {
                        failure(error);
                    }
                    return;
                }
                
                NSArray *URLstrings = [responseData objectForKey:@"images"];
                NSMutableArray *URLs = [NSMutableArray array];
                for (NSString *URLstring in URLstrings) {
                    [URLs addObject:[NSURL URLWithString:URLstring]];
                }
                
                [pages setObject:URLs forKey:[NSNumber numberWithInteger:page]];
                if (success) {
                    success(URLs);
                }
            }
        }] resume];
    }];
}

- (void)getImageForURL:(NSURL *)url
               success:(void (^)(UIImage *))success
               failure:(void (^)(NSError *))failure {
    NSString *hash = [url.absoluteString md5String];
    NSURL *imageFileURL = [NSURL URLWithString:hash relativeToURL:cacheFolderURL];
    
    if ([imageFileURL checkResourceIsReachableAndReturnError:nil]) {
        if (success) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:imageFileURL]];
                success(image);
            });
        }
        return;
    }
    
    [imageDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        for (NSURLSessionDownloadTask *task in downloadTasks) {
            if ((task.state == NSURLSessionTaskStateRunning || task.state == NSURLSessionTaskStateSuspended) && [task.originalRequest.URL isEqual:url]) {
                if (success) {
                    success(nil);
                }
                return;
            }
        }
        
        [[imageDownloadSession downloadTaskWithRequest:[NSURLRequest requestWithURL:url]] resume];
        
        if (success) {
            void (^successCopy)(UIImage *image) = [success copy];
            [downloadCompletionHandlers setObject:successCopy forKey:hash];
        }
    }];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSURL *url = downloadTask.originalRequest.URL;
    NSString *hash = [url.absoluteString md5String];
    NSURL *imageFileURL = [NSURL URLWithString:hash relativeToURL:cacheFolderURL];
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:imageFileURL error:nil];
    
    void (^success)(UIImage *image) = [downloadCompletionHandlers objectForKey:hash];
    if (success) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:imageFileURL]];
            success(image);
        });
    }
    [downloadCompletionHandlers removeObjectForKey:hash];
}

@end
