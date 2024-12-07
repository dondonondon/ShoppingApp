unit BFA.Helper.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, System.Generics.Collections, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent, FireDAC.Stan.Intf, FireDAC.Stan.Option, System.Json, System.NetEncoding, Data.DBXJsonCommon,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.FMXUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FMX.ListView.Types,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, System.DateUtils,
  FMX.Objects, System.IniFiles, System.IOUtils, FMX.Grid.Style, FMX.Grid, REST.Json, FMX.ListBox, System.RegularExpressions,
  BFA.Control.Rest, Rest.Types,
  BFA.Control.Form.Message,
  System.Threading, FMX.Edit, FMX.ExtCtrls, FMX.Ani, BFA.Global.Variable;

type
  HelperPosition = class
    class procedure SetCenter(AOrigin, AOwner : TControl);
  end;

  HelperFunction = class
    class procedure MoveToFrame(AAlias : String);

    class procedure ShowToastMessage(AMessage : String; ATypeMessage : TTypeMessage = TTypeMessage.Information; APositionMessage : TPositionMessage = Top);
    class procedure ShowPopUpMessage(AMessage : String; ATypeMessage : TTypeMessage = TTypeMessage.Information;
      APositionMessage : TPositionMessage = Top);

    class procedure Loading(AState : Boolean = False; AMessage : String = '');
    class procedure StartLoading(AMessage : String = '');
    class procedure StopLoading;

    class procedure SetMenu(AButton : TCornerButton; IsShowFrame : Boolean = True);
    class procedure SetStatusBarColor(AColor : Cardinal);

    class procedure HideBottomNav;
    class procedure ShowBottomNav;
  end;

  HelperEditText = class
    class function CreateFloatAnimation(AControl : TControl) : TFloatAnimation;
    class function CreateLabelText(AEditText : TEdit) : TLabel;
    class procedure SetEdit(AEditText : TEdit; AColor : Cardinal = $FF9094B8);
    class procedure SetMessage(AEditText : TEdit; AMessage : String; AColor : Cardinal = $FF9094B8; AVisible : Boolean = False);
  end;

  HelperRest = class
    class function Request(AData : TFDMemTable; AURL, ABodyJSON : String) : Boolean;
  end;

implementation

uses
  {$IFDEF ANDROID}
    Androidapi.Helpers, FMX.Platform.Android, System.Android.Service,
    FMX.Helpers.Android, Androidapi.JNI.PlayServices, Androidapi.JNI.Os,
  {$ENDIF}
  frMain, BFA.Control.Frame, BFA.Control.Keyboard,
  BFA.Control.Permission, BFA.Control.PushNotification, BFA.Global.Func,
  BFA.Helper.MemoryTable, BFA.Helper.Bitmap, uDM;

{ Helper }

class procedure HelperFunction.StartLoading(AMessage: String);
begin
  Loading(True, AMessage);
end;

class procedure HelperFunction.StopLoading;
begin
  Loading(False);
end;

class procedure HelperFunction.HideBottomNav;
begin
  TThread.Synchronize(nil, procedure begin FMain.loBottom.Visible := False; end);
end;

class procedure HelperFunction.Loading(AState: Boolean; AMessage: String);
begin
  TThread.Synchronize(nil, procedure begin
    Helper.Loading(AState, AMessage);
  end);
end;

class procedure HelperFunction.MoveToFrame(AAlias: String);
begin
  if AAlias = '' then Exit;
  TThread.Synchronize(nil, procedure begin
    Frame.GoFrame(AAlias);
  end);
end;

class procedure HelperFunction.SetMenu(AButton: TCornerButton;
  IsShowFrame: Boolean);
begin
  for var B in ListMenu do begin
    B.StyleLookup := 'btnMenuV2Default';
    B.ImageIndex := B.Tag;
  end;

  AButton.StyleLookup := 'btnMenuV2Selected';
  AButton.ImageIndex := AButton.Tag + 1;

  if IsShowFrame then
    MoveToFrame(AButton.Hint);
end;

class procedure HelperFunction.SetStatusBarColor(AColor: Cardinal);
begin
  {$IFDEF ANDROID}
  TAndroidHelper.Activity.getWindow.setStatusBarColor(AColor);
  {$ENDIF}
end;

class procedure HelperFunction.ShowBottomNav;
begin
  TThread.Synchronize(nil, procedure begin FMain.loBottom.Visible := True; end);
end;

class procedure HelperFunction.ShowPopUpMessage(AMessage: String;
  ATypeMessage: TTypeMessage; APositionMessage : TPositionMessage);
begin
  TThread.Synchronize(nil, procedure begin
    Helper.ShowPopUpMessage(AMessage, ATypeMessage, APositionMessage);
  end);
end;

class procedure HelperFunction.ShowToastMessage(AMessage: String;
  ATypeMessage: TTypeMessage; APositionMessage : TPositionMessage);
begin
  TThread.Synchronize(nil, procedure begin
    Helper.ShowToastMessage(AMessage, ATypeMessage, APositionMessage);
  end);
end;

{ HelperRest }

class function HelperRest.Request(AData: TFDMemTable;
  AURL, ABodyJSON: String): Boolean;
begin
  Result := False;

  var Rest := TRequestAPI.Create;
  var TempData := TFDMemTable.Create(nil);
  try
    try
      Rest.Request.Timeout := 15000;
      Rest.Request.ConnectTimeout := 15000;

      Rest.URL := AURL;
      Rest.Method := TRESTRequestMethod.rmPOST;
      Rest.Data := TempData;

      Rest.AddBody(ABodyJSON, TRESTContentType.ctAPPLICATION_JSON);

      Rest.Execute(True);

      AData.FillDataFromString(Rest.Content);

      if Rest.StatusCode = 200 then begin
        if AData.FieldByName('status').AsString = '200' then begin
          Result := True;
          AData.FillDataFromString(AData.FieldByName('data').AsString);
        end;
      end;
    except on E: Exception do
      begin
        Result := False;
        TFDMemTableHelperFunction.FillErrorParse(AData, E.Message, E.ClassName, False);
      end;
    end;
  finally
    TempData.DisposeOf;
    Rest.DisposeOf;
  end;
end;

{ HelperPosition }

class procedure HelperPosition.SetCenter(AOrigin, AOwner: TControl);
var
  wiF, wiP, heF, heP : Integer;
begin
  wiF := Round(AOrigin.Width);
  heF := Round(AOrigin.Height);
  wiP := Round(AOwner.Width);
  heP := Round(AOwner.Height);

  AOwner.BeginUpdate;

  AOwner.Position.X := Round((wiF / 2) - (wiP / 2));
  AOwner.Position.Y := Round((heF / 2) - (heP / 2));
  AOwner.EndUpdate;
end;

{ HelperEditText }

class function HelperEditText.CreateFloatAnimation(
  AControl: TControl): TFloatAnimation;
var
  T : TFloatAnimation;
begin
  T := TFloatAnimation.Create(AControl);
  T.Parent := AControl;
  T.Interpolation := TInterpolationType.Quadratic;
  T.PropertyName := 'Position.Y';
  T.Duration := 0.15;
  T.StartValue := AControl.Position.Y;
  T.StopValue := 8;

  T.Trigger := 'IsVisible=true';
  T.TriggerInverse := 'IsVisible=false';

  Result := T;
end;

class function HelperEditText.CreateLabelText(AEditText: TEdit): TLabel;
var
  L : TLabel;
begin
  L := TLabel.Create(AEditText);
  L.Parent := AEditText;
  L.Width := AEditText.Width - 32;
  L.Text := AEditText.TextPrompt;
  HelperPosition.SetCenter(AEditText, L);
  L.Position.X := 16;
  L.Font.Size := 11;
  L.TextSettings.WordWrap := True;
  L.StyledSettings := [];

  L.Visible := False;

  Result := L;
end;

class procedure HelperEditText.SetEdit(AEditText: TEdit; AColor: Cardinal);
var
  FText : TText;
  FLayout : TLayout;
  L : TLabel;
  T : TFloatAnimation;
  i: Integer;
begin
  FLayout := TLayout(AEditText.FindStyleResource('content'));

  L := nil;

  for i := 0 to AEditText.ControlsCount - 1 do begin
    if AEditText.Controls[i] is TLabel then begin
      if TLabel(AEditText.Controls[i]).StyleName = 'FieldLabel' then begin
        L := TLabel(AEditText.Controls[i]);
        Break;
      end;
    end;
  end;

  if not Assigned(L) then begin
    L := CreateLabelText(AEditText);
    L.StyleName := 'FieldLabel';
    L.Position.Y := 8;
//    T := CreateFloatAnimation(L);
  end;

  L.FontColor := AColor;

  if AEditText.Text <> '' then begin
    FLayout.Margins.Top := 24;
    L.Visible := True;
  end else begin
    FLayout.Margins.Top := 8;
    L.Visible := False;
  end;
end;

class procedure HelperEditText.SetMessage(AEditText: TEdit; AMessage : String;
  AColor: Cardinal; AVisible : Boolean);
var
  L : TLabel;
  i: Integer;
  R : TRectangle;
begin
  L := nil;
  R := nil;

  for i := 0 to AEditText.ControlsCount - 1 do begin
    if AEditText.Controls[i] is TLabel then begin
      if TLabel(AEditText.Controls[i]).StyleName = 'MessageLabel' then begin
        L := TLabel(AEditText.Controls[i]);
      end;
    end else if AEditText.Controls[i] is TRectangle then begin
      if TRectangle(AEditText.Controls[i]).StyleName = 'MessageRectangle' then begin
        R := TRectangle(AEditText.Controls[i]);
      end;
    end;
  end;

  if not Assigned(L) then begin
    L := CreateLabelText(AEditText);
    L.StyleName := 'MessageLabel';
    L.Position.Y := AEditText.Height + 2;
  end;

  if not Assigned(R) then begin
    R := TRectangle.Create(AEditText);
    R.Parent := AEditText;
    R.StyleName := 'MessageRectangle';
    R.Align := TAlignLayout.Bottom;
    R.Height := 3;

    R.Margins.Left := 6;
    R.Margins.Right := 6;

    R.Stroke.Kind := TBrushKind.None;
  end;


  R.Visible := AVisible;
  R.Fill.Color := AColor;

  L.Text := AMessage;
  L.Visible := AVisible;
  L.FontColor := AColor;

  if AVisible then
    SetEdit(AEditText, AColor);
end;

end.

