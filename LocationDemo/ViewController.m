
#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>//地图

@interface ViewController ()<CLLocationManagerDelegate>
{
    CLLocationManager *_manager;//定位的对象,必须为全局变量.
    CLGeocoder *_geocoder; //解析经度和纬度
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*
     定位
     1.定位在进入ios8之后的变化
     */
    
    if (![CLLocationManager locationServicesEnabled]) {
        
        [[[UIAlertView alloc] initWithTitle:@"message" message:@"定位已关闭" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
        
        return;
    }
    
    _manager = [[CLLocationManager alloc] init];
    _manager.delegate = self;
    _manager.distanceFilter = 10.0f;
    
    
    if ([_manager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_manager requestAlwaysAuthorization];
    }
    [_manager startUpdatingLocation];
}

#pragma mark -----定位代理方法-------
//授权
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    switch (status) {
            
        case kCLAuthorizationStatusNotDetermined:
            
            if ([manager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                
                [manager requestAlwaysAuthorization];
            }
            
            break;
            
        default:
            
            break;
            
    }
}

//定位成功
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    
    if (newLocation.coordinate.latitude == oldLocation.coordinate.latitude && newLocation.coordinate.longitude == oldLocation.coordinate.longitude) {
        [manager stopUpdatingLocation];
    }
    
    NSString *lat = [NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
    NSString *lng = [NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
    NSLog(@"lat = %@,lng = %@",lat,lng);
    
    //将经度和纬度解析为地名
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    [_geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark *placemark in placemarks) {
            for (NSString *key in placemark.addressDictionary.allKeys) {
                NSLog(@"%@:%@",key,placemark.addressDictionary[key]);
            }
        }
    }];
    
}

//定位失败
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"Monitor定位失败,error = %@",error);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
