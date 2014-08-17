@protocol DatePickerDelegate
- (void)DateSelected:(NSString *)Date;
@end


@interface DataSetPickerView : UIViewController {
    IBOutlet UIDatePicker *_datepicker;
//    NSString *_date;
//    IBOutlet UIButton *saveDateButton;
//    IBOutlet UILabel *chooseDateLabel;
//    IBOutlet UITextField* chooseDayTextField;
//    IBOutlet UITextField* chooseMonthTextField;
//    IBOutlet UITextField* chooseYearTextField;
    id<DatePickerDelegate> _delegate;
}
- (IBAction)setDate;
@property (nonatomic, retain) UIDatePicker *datepicker;
@property (nonatomic, assign) id<DatePickerDelegate> delegate;

@end