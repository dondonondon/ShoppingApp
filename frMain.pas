unit frMain;

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
  BFA.Global.Variable, BFA.Helper.Main, BFA.Control.PushNotification,
  FMX.MultiView, FMX.ListBox, System.ImageList, FMX.ImgList, System.Generics.Collections,
  FMX.Objects, FMX.Effects
  {$IF DEFINED (ANDROID)}
  , Androidapi.Helpers, Androidapi.JNI.Os, Androidapi.JNI.JavaTypes
  {$ENDIF}
  ;

type
  TFMain = class(TForm)
    loMain: TLayout;
    vsMain: TVertScrollBox;
    loFrame: TLayout;
    SB: TStyleBook;
    loTest: TLayout;
    loSidebar: TLayout;
    mvMain: TMultiView;
    Layout1: TLayout;
    loBottom: TLayout;
    lbMenu: TListBox;
    ListBoxItem1: TListBoxItem;
    imgMenu: TImageList;
    ListBoxItem2: TListBoxItem;
    ListBoxItem3: TListBoxItem;
    ListBoxItem4: TListBoxItem;
    btnClient: TCornerButton;
    btnProduct: TCornerButton;
    btnOrder: TCornerButton;
    btnSetting: TCornerButton;
    seHeader: TShadowEffect;
    procedure FormShow(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnClientClick(Sender: TObject);
  private

  public

    function AppEventProc(AAppEvent: TApplicationEvent;
      AContext: TObject): Boolean;

  end;

var
  FMain: TFMain;

implementation

{$R *.fmx}

uses
  frHome, frLoading, frLogin, BFA.Control.Permission, BFA.Init, BFA.FontSetting;

function TFMain.AppEventProc(AAppEvent: TApplicationEvent;
  AContext: TObject): Boolean;
begin
//  FNotification.AppEventProc(AAppEvent, AContext);

  if (AAppEvent = TApplicationEvent.BecameActive) then begin
    //your code here
  end;
end;

procedure TFMain.btnClientClick(Sender: TObject);
begin
  HelperFunction.SetMenu(TCornerButton(Sender));
end;

procedure TFMain.FormCreate(Sender: TObject);
var
  FormatBr: TFormatSettings;
begin
  FormatBr                     := TFormatSettings.Create;
  FormatBr.DecimalSeparator    := '.';
  FormatBr.ThousandSeparator   := ',';
  FormatBr.DateSeparator       := '-';
  FormatBr.TimeSeparator       := ':';
  FormatBr.ShortDateFormat     := 'yyyy-mm-dd';
  FormatBr.LongDateFormat      := 'yyyy-mm-dd hh:nn:ss';

  System.SysUtils.FormatSettings := FormatBr;

  TInitControls.InitFunction;
  ListMenu := TList<TCornerButton>.Create;
  ListMenu.Add(btnClient);
  ListMenu.Add(btnProduct);
  ListMenu.Add(btnOrder);
  ListMenu.Add(btnSetting);

  loBottom.Visible := False;
end;

procedure TFMain.FormDestroy(Sender: TObject);
begin
  TInitControls.ReleaseVariable;
  ListMenu.DisposeOf;
end;

procedure TFMain.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
var
  Routine : TMethod;
  Exec : TExec;
  LFrame : TControl;
  FService: IFMXVirtualKeyboardService;
begin
  if (Key = vkHardwareBack) or (Key = vkEscape) then begin {if you type esc on keyboard, frame execute "Back" Procedure on Published inside TFrame}
    TPlatformServices.Current.SupportsPlatformService(IFMXVirtualKeyboardService, IInterface(FService));
    if (FService <> nil) and (TVirtualKeyboardState.Visible in FService.VirtualKeyBoardState) then begin
      FService.HideVirtualKeyboard;
      FKeyboard.HideKeyboard;
    end else begin
      FKeyboard.HideKeyboard;
      Key := 0;

      if Assigned(Helper) then begin
        if Helper.StateLoading then begin
          Helper.ShowToastMessage('Still loading');
          Exit;
        end else if Helper.StatePopup then begin
          Helper.ClosePopup;
          Exit;
        end;
      end;

      if Assigned(Frame.LastControl) then begin
        LFrame := Frame.LastControl;
        Routine.Data := Pointer(LFrame);
        Routine.Code := LFrame.MethodAddress('Back');

        if not Assigned(Routine.Code) then
          Exit;

        Exec := TExec(Routine);
        Exec;
      end;
    end;
  end else begin
    FKeyboard.KeyUp(Key, KeyChar, Shift);
  end;
end;

procedure TFMain.FormShow(Sender: TObject);
begin
//  FNotification.ServiceConnectionStatus(True);

//  HelperStyle.ApplyStyle(HelperStyle.GetTheme);
//  Frame.GoFrame(C_HOME);
  Frame.GoFrame(C_LOADING);
end;

end.


