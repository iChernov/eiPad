//
//  FillClientRequisitesTableViewController.h
//  eiPad
//
//  Created by Ivan Chernov on 16.08.11.
//  Copyright 2011 SKB-Kontur. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClientRequsites.h"
#import "RequisitesTableViewCell.h"

@protocol ModalViewControllerDelegate <NSObject>

- (void)didDismissModalViewWithClientRequisites:(ClientRequsites *)clientReq;
- (ClientRequsites *)getBillClientRequisites;

@end

@interface FillClientRequisitesTableViewController : UITableViewController {
    id<ModalViewControllerDelegate> delegate;
    ClientRequsites *cR;
    BOOL willExit;
    RequisitesTableViewCell *innCell, *kppCell, *bikCell, *ksCell, *rsCell;
    BOOL innIsWrongType1, innIsWrongType2, kppIsWrong, bikIsWrong, rsIsWrong, ksIsWrong;
    UITextField *addressTF, *innTF, *kppTF, *bankNameTF, *bankBikTF, *rsTF, *ksTF;
}
- (BOOL)checkINN;
- (BOOL)checkBankBIK;
- (BOOL)checkKPP;
- (BOOL)checkRs;
- (BOOL)checkKs;
@property (nonatomic, assign) id<ModalViewControllerDelegate> delegate;
@property (nonatomic, retain) RequisitesTableViewCell *innCell, *kppCell, *bikCell, *ksCell, *rsCell;
@end
