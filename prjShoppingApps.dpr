program prjShoppingApps;



{$R *.dres}

uses
  System.StartUpCopy,
  FMX.Forms,
  FMX.Skia,
  frMain in 'frMain.pas' {FMain},
  uDM in 'uDM.pas' {DM: TDataModule},
  BFA.Global.Variable in 'sources\BFA.Global.Variable.pas',
  BFA.Global.Func in 'sources\BFA.Global.Func.pas',
  BFA.Control.Form.Message in 'sources\controls\BFA.Control.Form.Message.pas',
  BFA.Control.Frame in 'sources\controls\BFA.Control.Frame.pas',
  BFA.Control.Keyboard in 'sources\controls\BFA.Control.Keyboard.pas',
  BFA.Control.Permission in 'sources\controls\BFA.Control.Permission.pas',
  BFA.Control.PushNotification in 'sources\controls\BFA.Control.PushNotification.pas',
  BFA.Helper.Main in 'sources\helpers\BFA.Helper.Main.pas',
  BFA.Helper.MemoryTable in 'sources\helpers\BFA.Helper.MemoryTable.pas',
  BFA.Init in 'sources\BFA.Init.pas',
  BFA.Control.Rest in 'sources\controls\BFA.Control.Rest.pas',
  frLoading in 'frames\frLoading.pas' {FLoading: TFrame},
  frLogin in 'frames\frLogin.pas' {FLogin: TFrame},
  frHome in 'frames\frHome.pas' {FHome: TFrame},
  frCalender in 'frames\controls\frCalender.pas' {FCalender: TFrame},
  BFA.Helper.Bitmap in 'sources\helpers\BFA.Helper.Bitmap.pas',
  BFA.Log in 'sources\helpers\BFA.Log.pas',
  BFA.OpenUrl in 'sources\helpers\BFA.OpenUrl.pas',
  BFA.Helper.OpenDialog in 'sources\helpers\BFA.Helper.OpenDialog.pas',
  frNotification in 'frames\frNotification.pas' {FNotif: TFrame},
  BFA.FontSetting in 'sources\helpers\BFA.FontSetting.pas',
  frSearchHome in 'frames\frSearchHome.pas' {FSearchHome: TFrame},
  frTransAddProduct in 'frames\frTransAddProduct.pas' {FTransAddProduct: TFrame},
  frProduct in 'frames\frProduct.pas' {FProduct: TFrame},
  frProductDetail in 'frames\frProductDetail.pas' {FProductDetail: TFrame},
  frConfirmation in 'frames\controls\frConfirmation.pas' {FConfirmation: TFrame},
  frPayment in 'frames\frPayment.pas' {FPayment: TFrame},
  frOrderHistory in 'frames\frOrderHistory.pas' {FOrderHistory: TFrame};

//  {$IF DEFINED (ANDROID)}
//  FMX.MediaLibrary.Android in 'sources\libraries\FMX.MediaLibrary.Android.pas',
//  {$ENDIF }

{$R *.res}

begin
  GlobalUseSkia := True;
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.CreateForm(TFMain, FMain);
  Application.CreateForm(TDM, DM);
  Application.Run;

end.
