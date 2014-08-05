//
//  ViewController.m
//  PDFEdit
//
//  Created by João Vitor on 04/08/14.
//  Copyright (c) 2014 Avnoconn. All rights reserved.
//

#import "ViewController.h"
#import <CoreText/CoreText.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSURL *pathUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/101.pdf",[self pathToPatientPhotoFolder]]];
    
     CGPDFDocumentRef pdf  = CGPDFDocumentCreateWithURL((CFURLRef)pathUrl);
    
    
    
    const size_t numberOfPages = CGPDFDocumentGetNumberOfPages(pdf);
    
    NSMutableData* data = [NSMutableData data];
    UIGraphicsBeginPDFContextToData(data, CGRectZero, nil);
    
    for(size_t page = 1; page <= numberOfPages; page++)
    {
        //	Get the current page and page frame
        CGPDFPageRef pdfPage = CGPDFDocumentGetPage(pdf, page);
        const CGRect pageFrame = CGPDFPageGetBoxRect(pdfPage, kCGPDFMediaBox);
        
        UIGraphicsBeginPDFPageWithInfo(pageFrame, nil);
        
        //	Draw the page (flipped)
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        CGContextScaleCTM(ctx, 1, -1);
        CGContextTranslateCTM(ctx, 0, -pageFrame.size.height);
        CGContextDrawPDFPage(ctx, pdfPage);
        CGContextRestoreGState(ctx);
        
        //	Draw a red box
        [[UIColor redColor] set];
        UIRectFill(CGRectMake(20, 20, 100, 100));
        
        

        //Draw image
        UIImage* logo = [UIImage imageNamed:@"logo"];
        CGRect frame = CGRectMake(50, 100, 80, 100);
        [logo drawInRect:frame];
        
        
        //Draw Text
        NSString* textToDraw = @"Hello World";
        CFStringRef stringRef = (__bridge CFStringRef)textToDraw;
        
        // Prepare the text using a Core Text Framesetter.
        CFAttributedStringRef currentText = CFAttributedStringCreate(NULL, stringRef, NULL);
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(currentText);
        CGRect frameRect = CGRectMake(0, 0, 100, 50);
        CGMutablePathRef framePath = CGPathCreateMutable();
        CGPathAddRect(framePath, NULL, frameRect);
        
        
        
        // Get the frame that will do the rendering.
        CFRange currentRange = CFRangeMake(0, 0);
        CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, currentRange, framePath, NULL);
        CGPathRelease(framePath);
        // Draw the frame.
        CTFrameDraw(frameRef, ctx);
    }
    
    UIGraphicsEndPDFContext();
    
    CGPDFDocumentRelease(pdf);
    pdf = nil;
    

    [self saveDataToPDF:data];

    
    [self showPDFFile];
}

-(void)drawText
{

    NSString* pdfFileName = [NSString stringWithFormat:@"%@/101.pdf",[self pathToPatientPhotoFolder]];
    
    NSString* textToDraw = @"Hello World";
    CFStringRef stringRef = (__bridge CFStringRef)textToDraw;
    
    // Prepare the text using a Core Text Framesetter.
    CFAttributedStringRef currentText = CFAttributedStringCreate(NULL, stringRef, NULL);
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(currentText);
    
    CGRect frameRect = CGRectMake(0, 0, 300, 50);
    CGMutablePathRef framePath = CGPathCreateMutable();
    CGPathAddRect(framePath, NULL, frameRect);
    
    // Get the frame that will do the rendering.
    CFRange currentRange = CFRangeMake(0, 0);
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, currentRange, framePath, NULL);
    CGPathRelease(framePath);
    
    // Create the PDF context using the default page size of 612 x 792.
    UIGraphicsBeginPDFContextToFile(pdfFileName, CGRectZero, nil);
    
    // Mark the beginning of a new page.
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
    
    // Get the graphics context.
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    // Put the text matrix into a known state. This ensures
    // that no old scaling factors are left in place.
    CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity);
    
    // Core Text draws from the bottom-left corner up, so flip
    // the current transform prior to drawing.
    CGContextTranslateCTM(currentContext, 0, 100);
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    
    // Draw the frame.
    CTFrameDraw(frameRef, currentContext);
    
    CFRelease(frameRef);
    CFRelease(stringRef);
    CFRelease(framesetter);
    
    // Close the PDF context and write the contents out.
    UIGraphicsEndPDFContext();
    
}



-(void)showPDFFile
{
    NSString* pdfFileName = [NSString stringWithFormat:@"%@/101.pdf",[self pathToPatientPhotoFolder]];
    
    UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    
    NSURL *url = [NSURL fileURLWithPath:pdfFileName];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView setScalesPageToFit:YES];
    [webView loadRequest:request];
    
    
    
    [self.view addSubview:webView];
    
}

- (NSString *)pathToPatientPhotoFolder {
    
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *patientPhotoFolder = [documentsDirectory stringByAppendingPathComponent:@"pdfFolder"];
    
    // Create the folder if necessary
    BOOL isDir = NO;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if (![fileManager fileExistsAtPath:patientPhotoFolder
                           isDirectory:&isDir] && isDir == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[documentsDirectory stringByAppendingPathComponent:@"pdfFolder"] withIntermediateDirectories:NO attributes:nil error:nil];
        
    }
    
    
    return patientPhotoFolder;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (void)saveDataToPDF:(NSData *)pdfDocumentData
{

    NSData *d =pdfDocumentData;
    [d writeToFile:[NSString stringWithFormat:@"%@/101.pdf",[self pathToPatientPhotoFolder]] atomically:YES];

}
@end
