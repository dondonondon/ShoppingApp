unit BFA.Init;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Controls.Presentation, FMX.InertialMovement, BFA.Control.Keyboard, FMX.Platform,
  FMX.Edit, FMX.VirtualKeyboard, FMX.StdCtrls, BFA.Control.Frame,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, BFA.Control.Form.Message, System.Rtti,
  FMX.Grid.Style, FMX.Grid, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  Data.Bind.EngExt, Fmx.Bind.DBEngExt, Fmx.Bind.Grid, System.Bindings.Outputs,
  Fmx.Bind.Editors, Data.Bind.Components, Data.Bind.Grid, Data.Bind.DBScope,
  BFA.Helper.MemoryTable, BFA.Global.Func,
  BFA.Global.Variable, BFA.Helper.Main, BFA.Control.PushNotification, frMain,
  BFA.Control.Permission, FMX.FontGlyphs
  {$IF DEFINED (ANDROID)}
  , Androidapi.Helpers, Androidapi.JNI.Os, Androidapi.JNI.JavaTypes
  {$ENDIF}
  ;

type
  TInitControls = class
  public
    class procedure ReleaseVariable;

    class procedure InitFunction;
    class procedure InitKeyboard;
    class procedure InitPushNotification;
    class procedure InitToastMessage;
    class procedure InitFrame;

    class procedure LoadFont;
  end;

implementation

uses
  frHome, frLoading, frLogin, BFA.Helper.OpenDialog, frNotification,
  frSearchHome, frTransAddProduct, frProduct, frProductDetail, frPayment,
  frOrderHistory;

{ TInitControls }

class procedure TInitControls.InitFrame;
begin
  Frame := TGoFrame.Create;
  Frame.ControlParent := FMain.loFrame;
  Frame.CloseAppWhenDoubleTap := True;
  Frame.MainHelper := Helper;

  Frame.RegisterClassesFrame(  {register class using array}
    [TFLoading, TFHome, TFNotif, TFSearchHome],
    [C_LOADING, C_HOME, C_NOTIF, C_SEARCHHOME]
  );

  {or you can register class one by one like below...}
  Frame.RegisterClassFrame(TFLogin, C_LOGIN);
  Frame.RegisterClassFrame(TFTransAddProduct, C_TRANSADDPRODUCT);
  Frame.RegisterClassFrame(TFProduct, C_PRODUCT);
  Frame.RegisterClassFrame(TFProductDetail, C_PRODUCTDETAIL);
  Frame.RegisterClassFrame(TFPayment, C_PAYMENT);
  Frame.RegisterClassFrame(TFOrderHistory, C_ORDERHISTORY);

  Frame.AddDoubleTapBackExit([C_LOGIN, C_LOADING, C_HOME]); {when frame on list, if you tap back / esc then application terminate}
end;

class procedure TInitControls.InitFunction;
begin
  InitKeyboard;
//  InitPushNotification;
  InitToastMessage; //init before Initframe
  InitFrame;

  TBFAOpenDialog.InitSubsribeMessage;
end;

class procedure TInitControls.InitKeyboard;
begin
  FKeyboard := TKeyboardShow.Create(
    FMain, FMain.vsMain, FMain.loFrame, True
  );
end;

class procedure TInitControls.InitPushNotification;
begin
//  FNotification := TPushNotif.Create;
  FNotification := TPushNotif.Create(FMain.AppEventProc);
  //you can replace AppEventProc. It's for Push Notif from firebase. You can set nil => FNotification := TPushNotif.Create;
end;

class procedure TInitControls.InitToastMessage;
begin
  Helper := TMainHelper.Create;
  Helper.SetForm := FMain;
end;

class procedure TInitControls.LoadFont;
begin
//  if FileExists(GlobalFunction.LoadFile('SF Pro Text.ttf')) then
end;

class procedure TInitControls.ReleaseVariable;
begin
  if Assigned(FKeyboard) then
    FKeyboard.DisposeOf;

  if Assigned(Frame) then
    Frame.DisposeOf;

  if Assigned(FNotification) then
    FNotification.DisposeOf;

  if Assigned(Helper) then
    Helper.DisposeOf;
end;

end.
