//
//  ImageDownloadOperation.h
//  SharkFeed
//
//  Created by Jinhuan Li on 8/11/16.
//  Copyright © 2016 likers33. All rights reserved.
//

#import "PhotoModel.h"

@interface ImageDownloadOperation : NSOperation {
    NSString *imageUrl;
}

-(id)initWithUrl:(NSString *)url Cache:(NSCache *)cache;

@end
