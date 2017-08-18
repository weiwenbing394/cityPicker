//
//  FYLCityPickView.m
//  QinYueHui
//
//  Created by FuYunLei on 2017/4/14.
//  Copyright © 2017年 FuYunLei. All rights reserved.
//

#import "FYLCityPickView.h"
#import "FYLCityModel.h"

#define kHeaderHeight    45
#define kPickViewHeight  216
#define kSureBtnColor    [UIColor blackColor]
#define kCancleBtnColor  [UIColor blackColor]
#define kHeaderViewColor [UIColor whiteColor]
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@interface FYLCityPickView()<UIPickerViewDataSource,UIPickerViewDelegate>


@property (nonatomic,strong)NSMutableArray *allProvinces;
/**
 *  省份对应的下标
 */
@property (nonatomic,assign)NSInteger rowOfProvince;
/**
 *  市对应的下标
 */
@property (nonatomic,assign)NSInteger rowOfCity;
/**
 *  区对应的下标
 */
@property (nonatomic,assign)NSInteger rowOfTown;

@end

@implementation FYLCityPickView

//弹出城市选择器，默认选中上海
+ (FYLCityPickView *)showPickViewWithComplete:(FYLCityBlock)block{
    return [self showPickViewWithDefaultProvince:nil city:nil area:nil complete:block];
}

//弹出城市选择器，可以传入自定省市区
+ (FYLCityPickView *)showPickViewWithProvince:(NSString *)province city:(NSString *)city area:(NSString *)area  Complete:(FYLCityBlock)block{
    return [self showPickViewWithDefaultProvince:province city:city area:area complete:block];
};


+ (FYLCityPickView *)showPickViewWithDefaultProvince:(NSString *)province city:(NSString *)city area:(NSString *)area complete:(FYLCityBlock)block{
    
    CGFloat screenWitdth = [[UIScreen mainScreen] bounds].size.width;
    
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    FYLCityPickView *pickView= [[FYLCityPickView alloc] initWithFrame:CGRectMake(0, 0, screenWitdth, screenHeight)];
    
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:pickView];
    pickView.completeBlcok = block;
    
    if (0<province.length && 0<city.length && 0<area.length) {
        
        //省
        NSInteger customProvince = [pickView rowOfProvinceWithName:province];
        if (customProvince != recordRowOfProvince) {
//            static dispatch_once_t onceToken;
//            dispatch_once(&onceToken, ^{
                recordRowOfProvince =customProvince;
                recordRowOfCity = 0;
                recordRowOfTown = 0;
//            });
        }
        
        //市
        NSInteger customCity = [pickView rowOfCityWithName:city];
        if (customCity != recordRowOfCity) {
//            static dispatch_once_t onceToken;
//            dispatch_once(&onceToken, ^{
                recordRowOfCity = customCity;
                recordRowOfTown = 0;
//            });
        }
        
        //区
        NSInteger customArea = [pickView rowOfAreaWithName:area];
        if (customArea != recordRowOfTown) {
//            static dispatch_once_t onceToken;
//            dispatch_once(&onceToken, ^{
                recordRowOfTown = customArea;
//            });
        }
    }
    
    [pickView scrollToRow:recordRowOfProvince secondRow:recordRowOfCity thirdRow:recordRowOfTown];
    
    return pickView;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadData];
        [self setupUI];
    }
    return self;
}

- (void)loadData{
    
    _allProvinces = [NSMutableArray array];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"FYLCity" ofType:@"plist"];
    
    NSArray *arrData = [NSArray arrayWithContentsOfFile:filePath];
    
    for (NSDictionary *dic in arrData) {
        ///此处用到底 "YYModel"  
        FYLProvince *provice = [FYLProvince yy_modelWithDictionary:dic];
        [_allProvinces addObject:provice];
    }
}

- (void)setupUI{
    
    CGFloat width = self.frame.size.width;
    
    [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
    
    UIView *viewBg = [[UIView alloc] initWithFrame:CGRectMake(0,self.frame.size.height,width,kPickViewHeight+kHeaderHeight)];
    viewBg.tag=200;
    [viewBg setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:viewBg];
    
    UIView *viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0,0, width,kHeaderHeight)];
    [viewHeader setBackgroundColor:kHeaderViewColor];
    [viewBg addSubview:viewHeader];
    
    UIButton *cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0, 50, kHeaderHeight)];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:kCancleBtnColor forState:UIControlStateNormal];
    cancelButton.titleLabel.font= font15;
    [cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:cancelButton];
    
    
    UIButton *sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sureButton setFrame:CGRectMake(viewHeader.frame.size.width-50,0, 50, kHeaderHeight)];
    [sureButton setTitle:@"完成" forState:UIControlStateNormal];
    sureButton.titleLabel.font = font15;
    [sureButton setTitleColor:kSureBtnColor forState:UIControlStateNormal];
    [sureButton addTarget:self action:@selector(sureACtion:) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:sureButton];
    
    //标题
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.font = font14;
    titleLabel.text = @"选择地区";
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [viewHeader addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
    }];
    //头部分割线
    UIView *lineView = [[UIView alloc]init];
    lineView.backgroundColor = UIColorFromRGB(0xe5e5e5);
    [viewHeader addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
    }];
    
    
    self.pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0,kHeaderHeight,width,kPickViewHeight)];
    [self.pickerView setBackgroundColor:[UIColor whiteColor]];
    [self.pickerView setShowsSelectionIndicator:YES];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    [viewBg addSubview:self.pickerView];
    
    
    [UIView animateWithDuration:0.25 animations:^{
        [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]];
        viewBg.frame=CGRectMake(0,self.frame.size.height-(kPickViewHeight+kHeaderHeight),width,kPickViewHeight+kHeaderHeight);
    }];
    
}

- (void)cancelAction:(UIButton *)btn{
    UIView *viewBg=[self viewWithTag:200];
    [UIView animateWithDuration:0.25 animations:^{
        [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
        viewBg.frame=CGRectMake(0,self.frame.size.height,self.frame.size.width,kPickViewHeight+kHeaderHeight);
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
}
- (void)sureACtion:(UIButton *)btn{
    NSArray *arr = [self getChooseCityArr];
    if (self.completeBlcok != nil) {
        self.completeBlcok(arr);
    }
    [self cancelAction:nil];
}

#pragma mark - PickerView的数据源方法
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    FYLProvince *province = self.allProvinces[self.rowOfProvince];
    FYLCity *city = province.city[self.rowOfCity];
    
    if (component == 0) {
        //返回省个数
        return self.allProvinces.count;
    }
    
    if (component == 1) {
        //返回市个数
        return province.city.count;
    }
    
    if (component == 2) {
        //返回区个数
        return city.town.count;
    }
    return 0;
    
}


#pragma mark - PickerView的代理方法
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSString *showTitleValue=@"";
    if (component==0){//省
        FYLProvince *province = self.allProvinces[row];
        showTitleValue = province.name;
    }
    if (component==1){//市
        FYLProvince *province = self.allProvinces[self.rowOfProvince];
        FYLCity *city = province.city[row];
        showTitleValue = city.name;
    }
    if (component==2) {//区
        FYLProvince *province = self.allProvinces[self.rowOfProvince];
        FYLCity *city = province.city[self.rowOfCity];
        FYLTown *town = city.town[row];
        showTitleValue = town.name;
    }
    return showTitleValue;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view {
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, ([UIScreen mainScreen].bounds.size.width) / 3.0,42)];
    label.textAlignment=NSTextAlignmentCenter;
    label.font =font15;
    label.textColor=[UIColor blackColor];
    label.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    
    //  设置横线的颜色，实现显示或者隐藏
    ((UILabel *)[pickerView.subviews objectAtIndex:1]).backgroundColor = RGB(231, 231, 231);
    
    ((UILabel *)[pickerView.subviews objectAtIndex:2]).backgroundColor = RGB(231, 231, 231);
    
    return label;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 37;
}

static NSInteger recordRowOfProvince = 8;//上海
static NSInteger recordRowOfCity;
static NSInteger recordRowOfTown=0;

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if (component == 0) {
        self.rowOfProvince = recordRowOfProvince = row;
        self.rowOfCity = recordRowOfCity = 0;
        self.rowOfTown = recordRowOfTown = 0;
        [pickerView reloadComponent:1];
        [pickerView reloadComponent:2];
        [pickerView selectRow:0 inComponent:1 animated:YES];
        [pickerView selectRow:0 inComponent:2 animated:YES];
    }
    else if(component == 1){
        self.rowOfCity = recordRowOfCity = row;
        self.rowOfTown = recordRowOfTown = 0;
        [pickerView reloadComponent:2];
        [pickerView selectRow:0 inComponent:2 animated:YES];
    }
    else if(component==2){
        self.rowOfTown = recordRowOfTown = row;
    }
    
    if (self.autoGetData) {
        NSArray *arr = [self getChooseCityArr];
        if (self.completeBlcok != nil) {
            self.completeBlcok(arr);
        }
    }
    
}

#pragma mark - Tool
-(NSArray *)getChooseCityArr{
    NSArray *arr;
    
    if (self.rowOfProvince < self.allProvinces.count) {
        FYLProvince *province = self.allProvinces[self.rowOfProvince];
        if (self.rowOfCity < province.city.count) {
            FYLCity *city = province.city[self.rowOfCity];
            if (self.rowOfTown < city.town.count) {
                FYLTown *town = city.town[self.rowOfTown];
                arr = @[province.name,city.name,town.name];
            }
        }
    }
    return arr;
}


-(void)scrollToRow:(NSInteger)firstRow  secondRow:(NSInteger)secondRow thirdRow:(NSInteger)thirdRow{
    if (firstRow < self.allProvinces.count) {
        self.rowOfProvince = firstRow;
        FYLProvince *province = self.allProvinces[firstRow];
        if (secondRow < province.city.count) {
            self.rowOfCity = secondRow;
            [self.pickerView reloadComponent:1];
            FYLCity *city = province.city[secondRow];
            if (thirdRow < city.town.count) {
                self.rowOfTown = thirdRow;
                [self.pickerView reloadComponent:2];
                [self.pickerView selectRow:firstRow inComponent:0 animated:NO];
                [self.pickerView selectRow:secondRow inComponent:1 animated:NO];
                [self.pickerView selectRow:thirdRow inComponent:2 animated:NO];
            }
        }
    }
    if (self.autoGetData) {
        NSArray *arr = [self getChooseCityArr];
        if (self.completeBlcok != nil) {
            self.completeBlcok(arr);
        }
    }
}

//根据省的名称计算选中的下标
//- (NSInteger)rowOfProvinceWithName:(NSString *)provinceName{
//    NSInteger row = 0;
//    for (FYLProvince *province in self.allProvinces) {
//        if ([province.name isEqualToString:provinceName]) {
//            return row;
//        }
//        row++;
//    }
//    return row;
//}

- (NSInteger)rowOfProvinceWithName:(NSString *)provinceName{
    NSMutableArray *nameArray=[NSMutableArray array];
    for (FYLProvince *province in self.allProvinces) {
        [nameArray addObject:province.name];
    }
    if ([nameArray containsObject:provinceName]) {
        return [nameArray indexOfObject:provinceName];
    }else{
        return 0;
    }
}


//根据市的名称计算选中的下标
//- (NSInteger)rowOfCityWithName:(NSString *)cityName{
//    NSInteger row = 0;
//    FYLProvince *province = self.allProvinces[self.rowOfProvince];
//    for (FYLCity *city in province.city) {
//        if ([city.name isEqualToString:cityName]) {
//            return row;
//        }
//        row++;
//    }
//    return row;
//}
- (NSInteger)rowOfCityWithName:(NSString *)cityName{
    FYLProvince *province = self.allProvinces[recordRowOfProvince];
    NSMutableArray *nameArray=[NSMutableArray array];
    for (FYLCity *city in province.city) {
        [nameArray addObject:city.name];
    }
    if ([nameArray containsObject:cityName]) {
        return [nameArray indexOfObject:cityName];
    }else{
        return 0;
    }
}


//根据地区的名字选择下标
//- (NSInteger)rowOfAreaWithName:(NSString *)areaName{
//    NSInteger row = 0;
//    FYLProvince *province = self.allProvinces[self.rowOfProvince];
//    FYLCity     *city = province.city[self.rowOfCity];
//    for (FYLTown *town in city.town) {
//        if ([town.name isEqualToString:areaName]) {
//            return row;
//        }
//        row++;
//    }
//    return row;
//}

- (NSInteger)rowOfAreaWithName:(NSString *)areaName{
    FYLProvince *province = self.allProvinces[recordRowOfProvince];
    FYLCity     *city = province.city[recordRowOfCity];
    NSMutableArray *nameArray=[NSMutableArray array];
    for (FYLTown *town in city.town) {
        [nameArray addObject:town.name];
    }
    if ([nameArray containsObject:areaName]) {
        return [nameArray indexOfObject:areaName];
    }else{
        return 0;
    }
}


//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    [self removeFromSuperview];
//}

@end
