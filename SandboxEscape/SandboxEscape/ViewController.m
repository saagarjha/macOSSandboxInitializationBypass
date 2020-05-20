//
//  ViewController.m
//  SandboxEscape
//
//  Created by Saagar Jha on 1/20/20.
//  Copyright © 2020 Saagar Jha. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	// Do any additional setup after loading the view.
	
	NSError *error;
	NSString *contents = [[NSFileManager.defaultManager contentsOfDirectoryAtPath:NSHomeDirectory() error:&error] componentsJoinedByString:@"\n"];
	if (!error) {
		self.textView.string = contents;
	} else {
		self.textView.string = error.description;
	}
}


- (void)setRepresentedObject:(id)representedObject {
	[super setRepresentedObject:representedObject];

	// Update the view, if already loaded.
}


@end
