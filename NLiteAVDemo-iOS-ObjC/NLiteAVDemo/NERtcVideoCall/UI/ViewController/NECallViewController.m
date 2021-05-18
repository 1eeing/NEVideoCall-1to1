//
//  NECallViewController.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/21.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NECallViewController.h"
#import "NECustomButton.h"
#import "NEVideoOperationView.h"
#import "NEVideoView.h"
#import <NERtcSDK/NERtcSDK.h>

@interface NECallViewController ()
@property(strong,nonatomic)NEVideoView *smallVideoView;
@property(strong,nonatomic)NEVideoView *bigVideoView;
@property(strong,nonatomic)UIImageView *remoteAvatorView;
@property(strong,nonatomic)UILabel *titleLabel;
@property(strong,nonatomic)UILabel *subTitleLabel;
//@property(strong,nonatomic)UIButton *closeBtn;
@property(strong,nonatomic)UIButton *switchCameraBtn;
/// 取消呼叫
@property(strong,nonatomic)NECustomButton *cancelBtn;
/// 拒绝接听
@property(strong,nonatomic)NECustomButton *rejectBtn;
/// 接听
@property(strong,nonatomic)NECustomButton *acceptBtn;
@property(strong,nonatomic)NEVideoOperationView *operationView;
@property(assign,nonatomic)BOOL showMyBigView;


@end

@implementation NECallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupSDK];
    [self updateUIonStatus:self.status];
}
#pragma mark - SDK
- (void)setupSDK {
    [[NERtcCallKit sharedInstance] addDelegate:self];
    [NERtcCallKit sharedInstance].timeOutSeconds = 30;
    if (self.status == NERtcCallStatusCalling) {
        [[NERtcCallKit sharedInstance] call:self.remoteUser.imAccid type:NERtcCallTypeVideo completion:^(NSError * _Nullable error) {
            [[NERtcCallKit sharedInstance] setupLocalView:self.bigVideoView.videoView];
            self.bigVideoView.userID = self.localUser.imAccid;
            if (error) {
                /// 对方离线时 通过APNS推送 UI不弹框提示
                if (error.code == 10202||error.code == 10201) {
                    return;
                }
                [self.view makeToast:error.localizedDescription];
            }
        }];
    }
}
#pragma mark - UI
- (void)setupUI {
    [self.view addSubview:self.bigVideoView];
    CGFloat statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    [self.bigVideoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    [self.view addSubview:self.switchCameraBtn];
    [self.switchCameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(statusHeight + 20);
        make.left.mas_equalTo(20);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    [self.view addSubview:self.smallVideoView];
    [self.smallVideoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(statusHeight + 20);
        make.right.mas_equalTo(self.view.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(90, 160));
    }];
    [self.view addSubview:self.remoteAvatorView];
    [self.remoteAvatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.smallVideoView.mas_top);
        make.right.mas_equalTo(self.view.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    [self.view addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.remoteAvatorView.mas_top).offset(5);
        make.right.mas_equalTo(self.remoteAvatorView.mas_left).offset(-8);
        make.left.mas_equalTo(60);
        make.height.mas_equalTo(25);
    }];
    [self.view addSubview:self.subTitleLabel];
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom);
        make.right.mas_equalTo(self.titleLabel.mas_right);
        make.left.mas_equalTo(self.titleLabel.mas_left);
        make.height.mas_equalTo(20);
    }];
    
    /// 取消按钮
    [self.view addSubview:self.cancelBtn];
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-80);
        make.size.mas_equalTo(CGSizeMake(75, 103));
    }];
    /// 接听和拒接按钮
    [self.view addSubview:self.rejectBtn];
    [self.rejectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(- self.view.frame.size.width/4.0);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-80);
        make.size.mas_equalTo(CGSizeMake(75, 103));
    }];
    [self.view addSubview:self.acceptBtn];
    [self.acceptBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.frame.size.width/4.0);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-80);
        make.size.mas_equalTo(CGSizeMake(75, 103));
    }];
    [self.view addSubview:self.operationView];
    [self.operationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(224, 60));
        make.bottom.mas_equalTo(-50);
    }];
}
- (void)updateUIonStatus:(NERtcCallStatus)status {
    switch (status) {
        case NERtcCallStatusCalling:
        {
            self.titleLabel.text = [NSString stringWithFormat:@"正在呼叫 %@",self.remoteUser.mobile];
            self.subTitleLabel.text = @"等待对方接听……";
            self.remoteAvatorView.hidden = NO;
            [self.remoteAvatorView sd_setImageWithURL:[NSURL URLWithString:self.remoteUser.avatar] placeholderImage:[UIImage imageNamed:@"avator"]];
            self.smallVideoView.hidden = YES;
            self.cancelBtn.hidden = NO;
            self.rejectBtn.hidden = YES;
            self.acceptBtn.hidden = YES;
            self.switchCameraBtn.hidden = YES;
            self.operationView.hidden = YES;
        }
            break;
        case NERtcCallStatusCalled:
        {
            self.titleLabel.text = [NSString stringWithFormat:@"%@",self.remoteUser.mobile];
            self.remoteAvatorView.hidden = NO;
            [self.remoteAvatorView sd_setImageWithURL:[NSURL URLWithString:self.remoteUser.avatar] placeholderImage:[UIImage imageNamed:@"avator"]];
            self.subTitleLabel.text = @"邀请您视频通话";
            self.smallVideoView.hidden = YES;
            self.cancelBtn.hidden = YES;
            self.rejectBtn.hidden = NO;
            self.acceptBtn.hidden = NO;
            self.switchCameraBtn.hidden = YES;
            self.operationView.hidden = YES;
        }
            break;
        case NERtcCallStatusInCall:
        {
            self.smallVideoView.hidden = NO;
            self.titleLabel.hidden = YES;
            self.subTitleLabel.hidden = YES;
            self.remoteAvatorView.hidden = YES;
            self.cancelBtn.hidden = YES;
            self.rejectBtn.hidden = YES;
            self.acceptBtn.hidden = YES;
            self.switchCameraBtn.hidden = NO;
            self.operationView.hidden = NO;
        }
            break;
        default:
            break;
    }
}
#pragma mark - event
- (void)closeEvent:(NECustomButton *)button {
    [[NERtcCallKit sharedInstance] hangup:^(NSError * _Nullable error) {
        
    }];
}
- (void)cancelEvent:(NECustomButton *)button {
    [[NERtcCallKit sharedInstance] cancel:^(NSError * _Nullable error) {
        if (error.code == 10410) {
            // 邀请已接受 取消失败 不销毁VC
        }else {
            [self destroy];
        }
    }];
}
- (void)rejectEvent:(NECustomButton *)button {
    self.acceptBtn.userInteractionEnabled = NO;
    [[NERtcCallKit sharedInstance] reject:^(NSError * _Nullable error) {
        self.acceptBtn.userInteractionEnabled = YES;
        [self destroy];
    }];
}
- (void)acceptEvent:(NECustomButton *)button {
    self.rejectBtn.userInteractionEnabled = NO;
    self.acceptBtn.userInteractionEnabled = NO;
    [[NERtcCallKit sharedInstance] accept:^(NSError * _Nullable error) {
        self.rejectBtn.userInteractionEnabled = YES;
        self.acceptBtn.userInteractionEnabled = YES;
        if (error) {
            [self.view makeToast:@"接听失败"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self destroy];
            });
        }else {
            [[NERtcCallKit sharedInstance] setupLocalView:self.smallVideoView.videoView];
            self.smallVideoView.userID = self.localUser.imAccid;
            [[NERtcCallKit sharedInstance] setupRemoteView:self.bigVideoView.videoView forUser:self.remoteUser.imAccid];
            self.bigVideoView.userID = self.remoteUser.imAccid;
            [self updateUIonStatus:NERtcCallStatusInCall];
        }
    }];
}
- (void)switchCameraBtn:(UIButton *)button {
    [[NERtcCallKit sharedInstance] switchCamera];
}
- (void)microPhoneClick:(UIButton *)button {
    button.selected = !button.selected;
    [[NERtcCallKit sharedInstance] muteLocalAudio:button.selected];
}
- (void)cameraBtnClick:(UIButton *)button {
    button.selected = !button.selected;
    [[NERtcCallKit sharedInstance] enableLocalVideo:!button.selected];
    [self cameraAvailble:!button.selected userId:self.localUser.imAccid];
}
- (void)hangupBtnClick:(UIButton *)button {
    [[NERtcCallKit sharedInstance] hangup:^(NSError * _Nullable error) {
    }];
    [self destroy];
}
- (void)switchVideoView:(UITapGestureRecognizer *)tap {
    self.showMyBigView = !self.showMyBigView;
    if (self.showMyBigView) {
        [[NERtcCallKit sharedInstance] setupLocalView:self.bigVideoView.videoView];
        [[NERtcCallKit sharedInstance] setupRemoteView:self.smallVideoView.videoView forUser:self.remoteUser.imAccid];
        self.bigVideoView.userID = self.localUser.imAccid;
        self.smallVideoView.userID = self.remoteUser.imAccid;
    }else {
        [[NERtcCallKit sharedInstance] setupLocalView:self.smallVideoView.videoView];
        [[NERtcCallKit sharedInstance] setupRemoteView:self.bigVideoView.videoView forUser:self.remoteUser.imAccid];
        self.bigVideoView.userID = self.remoteUser.imAccid;
        self.smallVideoView.userID = self.localUser.imAccid;
    }
}
#pragma mark - NERtcVideoCallDelegate
- (void)onUserEnter:(NSString *)userID {
    [[NERtcCallKit sharedInstance] setupLocalView:self.smallVideoView.videoView];
    self.smallVideoView.userID = self.localUser.imAccid;
    [[NERtcCallKit sharedInstance] setupRemoteView:self.bigVideoView.videoView forUser:userID];
    self.bigVideoView.userID = userID;
    [self updateUIonStatus:NERtcCallStatusInCall];
}
- (void)onUserCancel:(NSString *)userID {
    [[NERtcCallKit sharedInstance] hangup:^(NSError * _Nullable error) {
    }];
    [self destroy];
}
- (void)onCameraAvailable:(BOOL)available userID:(NSString *)userID {
    [self cameraAvailble:available userId:userID];
}
- (void)onCallingTimeOut {
    [self.view makeToast:@"对方无响应"];
    [[NERtcCallKit sharedInstance] cancel:^(NSError * _Nullable error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self destroy];
        });
    }];
}
- (void)onUserBusy:(NSString *)userID {
    [self.view makeToast:@"对方正在通话中"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self destroy];
    });
}
- (void)onCallEnd {
    [self destroy];
}
- (void)onUserReject:(NSString *)userID {
    [self.view makeToast:@"对方拒绝了您的邀请"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self destroy];
    });
}

#pragma mark - private mothed
- (void)cameraAvailble:(BOOL)available userId:(NSString *)userId {
    NSString *tips = [self.localUser.imAccid isEqualToString:userId]?@"你关闭了摄像头":@"对方关闭了摄像头";
    if ([self.bigVideoView.userID isEqualToString:userId]) {
        self.bigVideoView.titleLabel.hidden = available;
        self.bigVideoView.maskView.hidden = available;
        self.bigVideoView.titleLabel.text = tips;
    }
    if ([self.smallVideoView.userID isEqualToString:userId]) {
        self.smallVideoView.titleLabel.hidden = available;
        self.smallVideoView.maskView.hidden = available;
        self.smallVideoView.titleLabel.text = tips;
    }
}
#pragma mark - destroy
- (void)destroy {
    if (self && [self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    [[NERtcCallKit sharedInstance] removeDelegate:self];
}
#pragma mark - property
- (NEVideoView *)bigVideoView {
    if (!_bigVideoView) {
        _bigVideoView = [[NEVideoView alloc] init];
        _bigVideoView.backgroundColor = [UIColor darkGrayColor];
    }
    return _bigVideoView;
}
- (NEVideoView *)smallVideoView {
    if (!_smallVideoView) {
        _smallVideoView = [[NEVideoView alloc] init];
        _smallVideoView.backgroundColor = [UIColor darkGrayColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchVideoView:)];
        [_smallVideoView addGestureRecognizer:tap];
    }
    return _smallVideoView;
}
- (UIImageView *)remoteAvatorView {
    if (!_remoteAvatorView) {
        _remoteAvatorView = [[UIImageView alloc] init];
        _remoteAvatorView.image = [UIImage imageNamed:@"avator"];
    }
    return _remoteAvatorView;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:18];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentRight;
    }
    return _titleLabel;
}
- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc] init];
        _subTitleLabel.font = [UIFont boldSystemFontOfSize:14];
        _subTitleLabel.textColor = [UIColor whiteColor];
        _subTitleLabel.text = @"等待对方接听……";
        _subTitleLabel.textAlignment = NSTextAlignmentRight;
    }
    return _subTitleLabel;
}

- (NECustomButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [[NECustomButton alloc] init];
        _cancelBtn.titleLabel.text = @"取消";
        _cancelBtn.imageView.image = [UIImage imageNamed:@"call_cancel"];
        [_cancelBtn addTarget:self action:@selector(cancelEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}
- (NECustomButton *)rejectBtn {
    if (!_rejectBtn) {
        _rejectBtn = [[NECustomButton alloc] init];
        _rejectBtn.titleLabel.text = @"拒绝";
        _rejectBtn.imageView.image = [UIImage imageNamed:@"call_cancel"];
        [_rejectBtn addTarget:self action:@selector(rejectEvent:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _rejectBtn;
}
- (NECustomButton *)acceptBtn {
    if (!_acceptBtn) {
        _acceptBtn = [[NECustomButton alloc] init];
        _acceptBtn.titleLabel.text = @"接听";
        _acceptBtn.imageView.image = [UIImage imageNamed:@"call_accept"];
        _acceptBtn.imageView.contentMode = UIViewContentModeCenter;
        [_acceptBtn addTarget:self action:@selector(acceptEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _acceptBtn;
}
- (UIButton *)switchCameraBtn {
    if (!_switchCameraBtn) {
        _switchCameraBtn = [[UIButton alloc] init];
        [_switchCameraBtn setImage:[UIImage imageNamed:@"call_switch_camera"] forState:UIControlStateNormal];
        [_switchCameraBtn addTarget:self action:@selector(switchCameraBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchCameraBtn;
}
- (NEVideoOperationView *)operationView {
    if (!_operationView) {
        _operationView = [[NEVideoOperationView alloc] init];
        _operationView.layer.cornerRadius = 30;
        [_operationView.microPhone addTarget:self action:@selector(microPhoneClick:) forControlEvents:UIControlEventTouchUpInside];
        [_operationView.cameraBtn addTarget:self action:@selector(cameraBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_operationView.hangupBtn addTarget:self action:@selector(hangupBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _operationView;
}

- (void)dealloc {
    NSLog(@"%@ dealloc%@",[self class],self);
}
@end
