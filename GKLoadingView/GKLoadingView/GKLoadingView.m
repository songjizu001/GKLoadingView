//
//  GKLoadingView.m
//  GKLoadingView
//
//  Created by QuintGao on 2017/11/23.
//  Copyright © 2017年 QuintGao. All rights reserved.
//

#import "GKLoadingView.h"

@interface GKLoadingView()<CAAnimationDelegate>

// 动画layer
@property (nonatomic, strong) CAShapeLayer *animatedLayer;

// 半径layer
@property (nonatomic, strong) CAShapeLayer *backgroundLayer;

/** 加载方式 */
@property (nonatomic, assign) GKLoadingStyle loadingStyle;

@property (nonatomic, copy) void(^completion)(GKLoadingView *loadingView, BOOL finished);

@end

@implementation GKLoadingView

+ (instancetype)loadingViewWithFrame:(CGRect)frame style:(GKLoadingStyle)style {
    return [[self alloc] initWithFrame:frame loadingStyle:style];
}

- (instancetype)initWithFrame:(CGRect)frame loadingStyle:(GKLoadingStyle)loadingStyle {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        self.loadingStyle   = loadingStyle;
        
        self.centerButton   = [UIButton new];
        [self addSubview:self.centerButton];
        
        // 设置默认值
        self.lineWidth      = 4;
        self.radius         = 24;
        self.bgColor        = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.strokeColor    = [UIColor whiteColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // centerButton必须保持在loadingView内部
    CGFloat btnWH = self.radius * 2 - self.lineWidth;
    
    self.centerButton.bounds = CGRectMake(0, 0, btnWH, btnWH);
    self.centerButton.center = CGPointMake(CGRectGetWidth(self.bounds) * 0.5, CGRectGetHeight(self.bounds) * 0.5);
    
    self.centerButton.layer.cornerRadius  = btnWH * 0.5;
    self.centerButton.layer.masksToBounds = YES;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview) {
        [self layoutAnimatedLayer];
    }else {
        [self.animatedLayer removeFromSuperlayer];
        self.animatedLayer = nil;
        
        [self.backgroundLayer removeFromSuperlayer];
        self.backgroundLayer = nil;
    }
}

- (void)layoutAnimatedLayer {
    CALayer *layer = self.animatedLayer;
    [self.layer addSublayer:layer];
    
    CGFloat viewW   = CGRectGetWidth(self.bounds);
    CGFloat viewH   = CGRectGetHeight(self.bounds);
    CGFloat layerW  = CGRectGetWidth(layer.bounds);
    CGFloat layerH  = CGRectGetHeight(layer.bounds);
    
    CGFloat widthDiff  = viewW - layerW;
    CGFloat heightDiff = viewH - layerH;
    
    CGFloat positionX  = viewW - layerW * 0.5 - widthDiff * 0.5;
    CGFloat positionY  = viewH - layerH * 0.5 - heightDiff * 0.5;
    
    layer.position = CGPointMake(positionX, positionY);

    self.backgroundLayer.position = layer.position;
}

#pragma mark - 懒加载
- (UIButton *)centerButton {
    if (!_centerButton) {
        _centerButton = [UIButton new];
    }
    return _centerButton;
}

- (CAShapeLayer *)animatedLayer {
    if (!_animatedLayer) {
        
        [self.layer addSublayer:self.backgroundLayer];
        
        CGPoint arcCenter = [self layerCenter];
        
        _animatedLayer               = [CAShapeLayer layer];
        _animatedLayer.contentsScale = [UIScreen mainScreen].scale;
        _animatedLayer.frame         = CGRectMake(0, 0, arcCenter.x * 2, arcCenter.y * 2);
        _animatedLayer.fillColor     = [UIColor clearColor].CGColor;
        _animatedLayer.strokeColor   = self.strokeColor.CGColor;
        _animatedLayer.lineWidth     = self.lineWidth;
        _animatedLayer.lineCap       = kCALineCapRound;
        _animatedLayer.lineJoin      = kCALineJoinBevel;
        
        switch (self.loadingStyle) {
            case GKLoadingStyleIndeterminate:
                [self setupIndeterminateAnim:_animatedLayer];
                break;
            case GKLoadingStyleIndeterminateMask:
                [self setupIndeterminateMaskAnim:_animatedLayer];
                break;
            case GKLoadingStyleDeterminate:
                [self setupDeterminateAnim:_animatedLayer];
                break;
                
            default:
                break;
        }
    }
    return _animatedLayer;
}

- (CAShapeLayer *)backgroundLayer {
    if (!_backgroundLayer) {
        CGPoint arcCenter = [self layerCenter];
        
        UIBezierPath *smoothedPath = [UIBezierPath bezierPathWithArcCenter:arcCenter
                                                                    radius:self.radius
                                                                startAngle:-M_PI_2
                                                                  endAngle:M_PI + M_PI_2
                                                                 clockwise:YES];
        
        _backgroundLayer               = [CAShapeLayer layer];
        _backgroundLayer.contentsScale = [UIScreen mainScreen].scale;
        _backgroundLayer.frame         = CGRectMake(0.0f, 0.0f, arcCenter.x * 2, arcCenter.y * 2);
        _backgroundLayer.fillColor     = [UIColor clearColor].CGColor;
        _backgroundLayer.strokeColor   = self.bgColor.CGColor;
        _backgroundLayer.lineWidth     = self.lineWidth;
        _backgroundLayer.lineCap       = kCALineCapRound;
        _backgroundLayer.lineJoin      = kCALineJoinBevel;
        _backgroundLayer.path          = smoothedPath.CGPath;
        _backgroundLayer.strokeEnd     = 1.0f;
    }
    return _backgroundLayer;
}

- (void)setupIndeterminateAnim:(CAShapeLayer *)layer {
    CGPoint arcCenter = [self layerCenter];
    
    UIBezierPath *smoothedPath = [UIBezierPath bezierPathWithArcCenter:arcCenter
                                                                radius:self.radius
                                                            startAngle:-M_PI_2
                                                              endAngle:M_PI_2 - M_PI_4
                                                             clockwise:YES];
    layer.path = smoothedPath.CGPath;
    
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    rotateAnimation.fromValue   = @0;
    rotateAnimation.toValue     = @(M_PI * 2);
    rotateAnimation.duration    = 0.8;
    rotateAnimation.repeatCount = HUGE;
    rotateAnimation.removedOnCompletion = NO;
    [layer addAnimation:rotateAnimation forKey:nil];
}

- (void)setupIndeterminateMaskAnim:(CAShapeLayer *)layer {
    CGPoint arcCenter = [self layerCenter];
    
    UIBezierPath *smoothedPath = [UIBezierPath bezierPathWithArcCenter:arcCenter
                                                                radius:self.radius
                                                            startAngle:(M_PI * 3 / 2)
                                                              endAngle:(M_PI / 2 + M_PI * 5)
                                                             clockwise:YES];
    
    layer.path = smoothedPath.CGPath;
    
    CALayer *maskLayer = [CALayer layer];
    
    maskLayer.contents  = (__bridge id)[[UIImage imageNamed:@"angle-mask"] CGImage];
    maskLayer.frame     = layer.bounds;
    layer.mask          = maskLayer;
    
    NSTimeInterval animationDuration   = 1;
    CAMediaTimingFunction *linearCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    CABasicAnimation *animation   = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animation.fromValue           = @0;
    animation.toValue             = @(M_PI * 2);
    animation.duration            = animationDuration;
    animation.timingFunction      = linearCurve;
    animation.removedOnCompletion = NO;
    animation.repeatCount         = HUGE;
    animation.fillMode            = kCAFillModeForwards;
    animation.autoreverses        = NO;
    [layer.mask addAnimation:animation forKey:@"rotate"];
    
    CAAnimationGroup *animationGroup    = [CAAnimationGroup animation];
    animationGroup.duration             = animationDuration;
    animationGroup.repeatCount          = HUGE;
    animationGroup.removedOnCompletion  = NO;
    animationGroup.timingFunction       = linearCurve;
    
    CABasicAnimation *strokeStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    strokeStartAnimation.fromValue = @0.015;
    strokeStartAnimation.toValue   = @0.515;
    
    CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    strokeEndAnimation.fromValue = @0.485;
    strokeEndAnimation.toValue   = @0.985;
    
    animationGroup.animations = @[strokeStartAnimation, strokeEndAnimation];
    [layer addAnimation:animationGroup forKey:@"progress"];
}

- (void)setupDeterminateAnim:(CAShapeLayer *)layer {
    CGPoint arcCenter = [self layerCenter];
    
    UIBezierPath *smoothedPath = [UIBezierPath bezierPathWithArcCenter:arcCenter
                                                                radius:self.radius
                                                            startAngle:-M_PI_2
                                                              endAngle:(M_PI + M_PI_2)
                                                             clockwise:YES];
    layer.path      = smoothedPath.CGPath;
    layer.strokeEnd = 0.0f;
}

- (void)setFrame:(CGRect)frame {
    if (!CGRectEqualToRect(frame, super.frame)) {
        [super setFrame:frame];
        
        if (self.superview) {
            [self layoutAnimatedLayer];
        }
    }
}

- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
    
    self.animatedLayer.lineWidth   = lineWidth;
    self.backgroundLayer.lineWidth = lineWidth;
    
    [self layoutIfNeeded];
}

- (void)setRadius:(CGFloat)radius {
    if (radius != _radius) {
        _radius = radius;
        
        [self.animatedLayer removeFromSuperlayer];
        self.animatedLayer = nil;
        
        [self.backgroundLayer removeFromSuperlayer];
        self.backgroundLayer = nil;
        
        if (self.superview) {
            [self layoutAnimatedLayer];
        }
    }
    
    [self layoutIfNeeded];
}

- (void)setBgColor:(UIColor *)bgColor {
    _bgColor = bgColor;
    
    self.backgroundLayer.strokeColor = bgColor.CGColor;
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    _strokeColor = strokeColor;
    
    self.animatedLayer.strokeColor = strokeColor.CGColor;
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.animatedLayer.strokeEnd = progress;
    !self.progressChange ? : self.progressChange(self, progress);
    [CATransaction commit];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat wh = (self.radius + self.lineWidth * 0.5 + 5 ) * 2;
    return CGSizeMake(wh, wh);
}

- (CGPoint)layerCenter {
    CGFloat xy = self.radius + self.lineWidth * 0.5 + 5;
    return CGPointMake(xy, xy);
}

- (void)startLoadingWithDuration:(NSTimeInterval)duration completion:(void (^)(GKLoadingView *, BOOL))completion {
    self.completion = completion;
    
    self.progress = 1.0;
    
    CABasicAnimation *pathAnimation     = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration              = duration;
    pathAnimation.fromValue             = @(0.0);
    pathAnimation.toValue               = @(1.0);
    pathAnimation.removedOnCompletion   = YES;
    pathAnimation.delegate              = self;
    [self.animatedLayer addAnimation:pathAnimation forKey:nil];
}

- (void)hideLoadingView {
    [self.layer removeAllAnimations];
    [self removeFromSuperview];
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    !self.completion ? : self.completion(self, flag);
}

@end
