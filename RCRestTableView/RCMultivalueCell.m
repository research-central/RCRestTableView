// RCMultivalueCell.m
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

#import "RCMultivalueCell.h"
#import "NSValue+RCRestTableVIew.h"
#import "RCUIMultivalueListController.h"
#import "UIView+RCRestTableView.h"

@interface RCMultivalueCell() <RCUIMultivalueListControllerDelegate>
@property (nonatomic,strong) NSArray *values;
@property (nonatomic,strong) NSDictionary *helper;
@property (nonatomic,weak) RCRestTableViewCellViewModel *viewModel;
@property (nonatomic,strong) UIPopoverController *popover;
@property (nonatomic,strong) UITextField *multivalueLabel;
@end

@implementation RCMultivalueCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
	self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
	if (self) {
		self.values = @[];
		self.multivalueLabel = [[UITextField alloc] init];
		[self.multivalueLabel setEnabled:NO];
		[self.multivalueLabel setTextAlignment:NSTextAlignmentLeft];
		self.multivalueLabel.font = [UIFont systemFontOfSize:13.0];
		[self.contentView addSubview:self.multivalueLabel];
		[self installConstraints];
		UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapIntercepted:)];
		[self.contentView addGestureRecognizer:tap];
	}
	return self;
}

- (void)installConstraints{
	self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
	self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
	self.multivalueLabel.translatesAutoresizingMaskIntoConstraints = NO;
	
	// ContentView constraints
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:10]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:10]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:-10]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:-10]];
	
	// TextLabel contraints
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeWidth multiplier:.35 constant:0]];
	
	// Detail constraints
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.multivalueLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.textLabel attribute:NSLayoutAttributeTrailing multiplier:1 constant:10]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.multivalueLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.multivalueLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.multivalueLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-20]];
}

- (void)RCUIMultivalueListController:(RCUIMultivalueListController*)controller newKeySelected:(NSString*)key{
	[self.viewModel setValue:key];
	[self.multivalueLabel setText:[self.helper valueForKey:key]];
}

- (void)tapIntercepted:(UITapGestureRecognizer*)tap{
	RCUIMultivalueListController *listController = [[RCUIMultivalueListController alloc] initWithValues:self.values selectedKey:self.viewModel.value];
	listController.delegate = self;
	// If is an iPad display the view in a popover
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		self.popover = [[UIPopoverController alloc] initWithContentViewController:listController];
		[self.popover presentPopoverFromRect:self.frame
									  inView:self.tableView
					permittedArrowDirections:UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown
									animated:YES];
	}else{
		UINavigationController *controller = [[self.tableView parentViewController] navigationController];
		if (!controller || ![controller isKindOfClass:[UINavigationController class]]){
#if DEBUG
			NSLog(@"[RCRESTTABLEVIEW] Seems that your TableView is not in a UINavigationController");
#endif
			return;
		}
		[controller pushViewController:listController animated:YES];
	}
}

- (void)bindViewModel:(RCRestTableViewCellViewModel*)viewModel{
	[super bindViewModel:viewModel];
	self.viewModel = viewModel;
	[self setSelectionStyle:UITableViewCellSelectionStyleNone];
	[self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	
	self.textLabel.text = viewModel.title;
	self.values = viewModel.values;
	
	// Build helper
	NSMutableDictionary *mutableHelper = [NSMutableDictionary new];
	for (NSDictionary *obj in viewModel.values) {
		[mutableHelper addEntriesFromDictionary:obj];
	}
	self.helper = mutableHelper;
	
	if ([self.helper valueForKey:viewModel.value]) {
		self.multivalueLabel.text = [self.helper valueForKey:viewModel.value];
	}
	
	for (NSString *selectorString in [viewModel.typeProperties allKeys]) {
		SEL selector = NSSelectorFromString(selectorString);
		NSMethodSignature *methodSignature = [self.multivalueLabel methodSignatureForSelector:selector];
		id value = [viewModel.typeProperties objectForKey:selectorString];
		NSInvocation *inv = [NSInvocation invocationWithMethodSignature:methodSignature];
		[inv setSelector:selector];
		[inv setTarget:self.multivalueLabel];
		[value setAsArgumentForInvocation:inv atIndex:2];
		[inv invoke];
	}
}

@end
