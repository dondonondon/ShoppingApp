unit BFA.Global.Variable;

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
  BFA.Control.PushNotification, FMX.Objects, FMX.Styles, System.Generics.Collections
  {$IF DEFINED(IOS) or DEFINED(ANDROID)}
   ,AndroidApi.JNI.GraphicsContentViewText, AndroidApi.JNI.OS, AndroidApi.Helpers, AndroidApi.JNI.Net,
  AndroidApi.JNI.JavaTypes, AndroidApi.JNIBridge, AndroidApi.JNI.Provider, AndroidApi.JNI.Telephony,
  FMX.PhoneDialer, FMX.PhoneDialer.Android, FMX.Platform.Android,
  AndroidApi.JNI.Java.Net,
  AndroidApi.JNI.Android.Security
  {$ENDIF}
  ;

type
  TTypeTheme = (Dark, Light);
  HelperStyle = class
    class function GetTheme : TTypeTheme;
    class function GetColorLogin : Cardinal;
    class function GetColorHeader : Cardinal;
    class function GetColorContainer : Cardinal;
    class function GetColorMain : Cardinal;

    class procedure ApplyStyle(ATheme : TTypeTheme = Light);
  end;

const
  C_HOME = 'HOME';
  C_LOADING = 'LOADING';
  C_LOGIN = 'LOGIN';
  C_NOTIF = 'NOTIF';
  C_SEARCHHOME = 'SEARCHHOME';
  C_TRANSADDPRODUCT = 'TRANSADDPRODUCT';
  C_PRODUCT = 'PRODUCT';
  C_PRODUCTDETAIL = 'PRODUCTDETAIL';
  C_PAYMENT = 'PAYMENT';
  C_ORDERHISTORY = 'ORDERHISTORY';

var
  FNotification : TPushNotif;
  FKeyboard : TKeyboardShow;
  ListMenu : TList<TCornerButton>;

  Frame : TGoFrame;
  Helper : TMainHelper;

implementation

{ HelperStyle }

uses frMain;

class procedure HelperStyle.ApplyStyle(ATheme: TTypeTheme);
var
  tempControl : TControl;
  tempRect : TRectangle;
  tempEdit : TEdit;
begin
  if not Assigned(Frame) then Exit;

  if ATheme = Light then begin
    GlobalFunction.SaveSettingString('theme', 'style', 'light');
    FMain.SB.Clear;
    FMain.SB.LoadFromFile(GlobalFunction.LoadFile('light.style'));
  end else begin
    GlobalFunction.SaveSettingString('theme', 'style', 'dark');
    FMain.SB.Clear;
    FMain.SB.LoadFromFile(GlobalFunction.LoadFile('dark.style'));
  end;

//  TStyleManager.SetStyle(FMain.SB);
  FMain.Invalidate;

  for var Alias in Frame.Alias do begin
    var FControl := Frame.GetFrame(Alias);

    for var i := 0 to FControl.ComponentCount - 1 do begin
      if FControl.Components[i] is TRectangle then begin
        tempRect := TRectangle(FControl.Components[i]);
        if tempRect.StyleName <> '' then begin
          if tempRect.StyleName = 'container' then tempRect.Fill.Color := GetColorContainer else
          if tempRect.StyleName = 'header' then tempRect.Fill.Color := GetColorHeader else
          if tempRect.StyleName = 'loginbackground' then tempRect.Fill.Color := GetColorLogin else
        end;
      end else if FControl.Components[i] is TEdit then begin
        if ATheme = Light then TEdit(FControl.Components[i]).FontColor := $FF2F3847 else TEdit(FControl.Components[i]).FontColor := $FFFFFFFF;
        TEdit(FControl.Components[i]).StyledSettings := [];
      end;
    end;

    FControl.Repaint;
  end;
end;

class function HelperStyle.getColorContainer: Cardinal;
begin
  if GetTheme = Light then Result := $FFFCFCFC else Result := $FF0C1527;
end;

class function HelperStyle.getColorHeader: Cardinal;
begin
  if GetTheme = Light then Result := $FFFFFFFF else Result := $FF0B1527;
end;

class function HelperStyle.getColorLogin: Cardinal;
begin
  if GetTheme = Light then Result := $FF5775CD else Result := $FF415372;
end;

class function HelperStyle.getColorMain: Cardinal;
begin
  Result := $FF5775CD;
end;

class function HelperStyle.GetTheme: TTypeTheme;
begin
  var FValue := GlobalFunction.LoadSettingString('theme', 'style', 'light');
  if FValue = 'light' then Result := TTypeTheme.Light else Result := TTypeTheme.Dark;
end;

end.
