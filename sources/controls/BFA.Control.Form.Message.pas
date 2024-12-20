unit BFA.Control.Form.Message;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, System.Generics.Collections, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent,
  FMX.Objects, FMX.Ani, System.Permissions, FMX.DialogService
  {$IF DEFINED (ANDROID)}
  , Androidapi.Helpers, Androidapi.Jni.Os
  {$ENDIF}
  ;

type
  TPositionMessage = (Top, Bottom);
  TTypeMessage = (Error, Success, Information);

  TMainHelper = class
  private
    FTransLayoutPopup : TLayout;

    FListTemporaryToast : TList<TLayout>;
    FListTemporaryPopup : TList<TLayout>;
    FSetForm: TForm;
    FTransProccess : TProc;
    FStateLoading: Boolean;
    FStatePopup: Boolean;

    procedure defClickToast(Sender : TObject);
    procedure defClickPopUp(Sender : TObject);
    procedure flFinish(Sender : TObject);
  public
    procedure ShowToastMessage(AMessage : String; ATypeMessage : TTypeMessage = Information; APositionMessage : TPositionMessage = Top);
    procedure ShowPopUpMessage(AMessage : String; ATypeMessage : TTypeMessage; APositionMessage : TPositionMessage = Top; FProc : TProc = nil);
    procedure Loading(IsState : Boolean; AText : String = '');

    procedure StartLoading(AText : String = '');
    procedure StopLoading;

    procedure ClosePopup;

    property SetForm : TForm read FSetForm write FSetForm;
    property StateLoading : Boolean read FStateLoading write FStateLoading;
    property StatePopup : Boolean read FStatePopup write FStatePopup;

    constructor Create;
    destructor Destroy; override;
  end;


implementation

{ TMainHelper }

procedure TMainHelper.ClosePopup;
begin
  if StatePopup then begin
    StatePopup := False;

    FListTemporaryPopup.Add(FTransLayoutPopup);
    FTransLayoutPopup.Visible := False;

    if Assigned(FTransProccess) then
      FTransProccess;

    FTransProccess := nil;
  end;
end;

constructor TMainHelper.Create;
begin
  FListTemporaryToast := TList<TLayout>.Create;
  FListTemporaryPopup := TList<TLayout>.Create;
end;

procedure TMainHelper.defClickPopUp(Sender: TObject);
begin
  ClosePopup;
//  StatePopup := False;
//
//  FListTemporaryPopup.Add(TLayout(TControl(Sender).Parent));
//  TLayout(TControl(Sender).Parent).Visible := False;
//
//  if Assigned(FTransProccess) then
//    FTransProccess;
//
//  FTransProccess := nil;
end;

procedure TMainHelper.defClickToast(Sender: TObject);
var
  lo : TLayout;
  loToast : TLayout;
begin
  loToast := TLayout(TControl(Sender).Parent);
  if Assigned(loToast) then begin
    lo := TLayout(loToast.FindStyleResource('loToast'));
//    loToast.Parent := nil;

    FListTemporaryToast.Add(loToast);

//    if Assigned(lo) then
//      if lo.ControlsCount = 0 then
//        lo.DisposeOf;
  end;
end;

destructor TMainHelper.Destroy;
begin
  if FListTemporaryToast.Count > 0 then begin
    for var i := FListTemporaryToast.Count - 1 downto 0 do begin
      if Assigned(FListTemporaryToast[i]) then begin
        FListTemporaryToast[i].DisposeOf;
        FListTemporaryToast.Delete(i);
      end;
    end;
  end;

  if FListTemporaryPopup.Count > 0 then begin
    for var i := FListTemporaryPopup.Count - 1 downto 0 do begin
      if Assigned(FListTemporaryPopup[i]) then begin
        FListTemporaryPopup[i].DisposeOf;
        FListTemporaryPopup.Delete(i);
      end;
    end;
  end;

  FListTemporaryToast.DisposeOf;
  FListTemporaryPopup.DisposeOf;

  inherited;
end;

procedure TMainHelper.flFinish(Sender: TObject);
var
  lo : TLayout;
  loToast : TLayout;
begin
  TFloatAnimation(Sender).Enabled := False;
  loToast := TLayout(TFloatAnimation(Sender).Parent);
  if Assigned(loToast) then begin
    lo := TLayout(loToast.FindStyleResource('loToast'));
    loToast.Parent := nil;

    FListTemporaryToast.Add(loToast);

    if Assigned(lo) then
      if lo.ControlsCount = 0 then
        lo.DisposeOf;
  end;
end;

procedure TMainHelper.Loading(IsState: Boolean; AText : String);
var
  FLayout : TLayout;
  FAni : TAniIndicator;

  FLabel : TLabel;
begin
  StateLoading := IsState;

  if not IsState then begin
    FLayout := TLayout(SetForm.FindStyleResource('FLayout'));
    if Assigned(FLayout) then
      FLayout.DisposeOf;

    Exit;
  end;

  FLayout := TLayout(SetForm.FindStyleResource('FLayout'));
  if not Assigned(FLayout) then begin
    FLayout := TLayout.Create(SetForm);
    FLayout.Align := TAlignLayout.Contents;
    FLayout.HitTest := True;
    FLayout.StyleName := 'FLayout';

    FAni := TAniIndicator.Create(FLayout);
    FAni.Align := TAlignLayout.Center;
    FAni.Enabled := IsState;
    FAni.StyleName := 'FAni';

    FLayout.AddObject(FAni);
    SetForm.AddObject(FLayout);
    FLayout.BringToFront;

    FLabel := TLabel.Create(SetForm);
    FLabel.Text := AText;
    FLabel.Font.Size := 12.5;
    FLabel.FontColor := $FF606060;
    FLabel.StyledSettings := [];
    FLabel.Width := SetForm.Width - 32;
    FLabel.AutoSize := True;
    FLabel.Position.X := 16;
    FLabel.Position.Y := FAni.Position.Y + FAni.Height + 16;

    FLabel.TextSettings.HorzAlign := TTextAlign.Center;

    FLabel.StyleName := 'labelLoading';

    FLayout.AddObject(FLabel);
  end else begin
    FLayout.Visible := IsState;
    FAni := TAniIndicator(FLayout.FindStyleResource('FAni'));
    if Assigned(FAni) then
      FAni.Enabled := IsState;
    FLayout.BringToFront;

    TLabel(FLayout.FindStyleResource('labelLoading')).Text := AText;
  end;
end;

procedure TMainHelper.ShowPopUpMessage(AMessage: String; ATypeMessage: TTypeMessage;
  APositionMessage : TPositionMessage; FProc: TProc);
var
  lo : TLayout;
  reBlack : TRectangle;
  reSide : TRectangle;
  reBackground : TRectangle;
  LStatus : TLabel;
  LMessage : TText;
  LClick : TLabel;
  FStatus : String;
  FColor : Cardinal;
begin
  if StatePopup then Exit;

  FTransProccess := nil;

  if FListTemporaryPopup.Count > 0 then begin
    for var i := FListTemporaryPopup.Count - 1 downto 0 do begin
      if Assigned(FListTemporaryPopup[i]) then begin
        FListTemporaryPopup[i].DisposeOf;
        FListTemporaryPopup.Delete(i);
      end;
    end;
  end;

  if ATypeMessage = TTypeMessage.Success then begin
    FStatus := 'Success!';
    FColor := $FF4BC961;
  end else if ATypeMessage = TTypeMessage.Error then begin
    FStatus := 'Error...';
    FColor := $FFFF004B;
  end else if ATypeMessage = TTypeMessage.Information then begin
    FStatus := 'Information';
    FColor := $FF36414A;
  end;

  if not Assigned(TLayout(SetForm.FindStyleResource('loPopUp'))) then begin
    lo := TLayout.Create(SetForm);
    lo.StyleName := 'loPopUp';
    lo.HitTest := True;
    lo.Align := TAlignLayout.Contents;

    SetForm.AddObject(lo);

      reBlack := TRectangle.Create(lo);
      reBlack.Align := TAlignLayout.Contents;
      reBlack.Stroke.Kind := TBrushKind.None;
      reBlack.Fill.Color := TAlphaColorRec.Black;
      reBlack.Opacity := 0.10;
      lo.AddObject(reBlack);

        reBackground := TRectangle.Create(lo);
        reBackground.Fill.Color := TAlphaColorRec.White;
        reBackground.Stroke.Kind := TBrushKind.None;

//        reBackground.Width := lo.Width - 32;
//        reBackground.Position.X := 16;
//        reBackground.Position.Y := 32;

        if APositionMessage = Bottom then reBackground.Align := TAlignLayout.Bottom else reBackground.Align := TAlignLayout.Top;
        reBackground.Margins.Left := 16;
        reBackground.Margins.Right := reBackground.Margins.Left;
        reBackground.Margins.Top := reBackground.Margins.Left;
        reBackground.Margins.Bottom := reBackground.Margins.Left;

        reBackground.XRadius := 8;
        reBackground.YRadius := reBackground.XRadius;
//        reBackground.Anchors := [TAnchorKind.akLeft, TAnchorKind.akRight, TAnchorKind.akTop];
        lo.AddObject(reBackground);

        reSide := TRectangle.Create(reBackground);
        reSide.Fill.Color := FColor;
        reSide.Stroke.Kind := TBrushKind.None;
        reSide.Width := 10;

//        reSide.Position.X := 16;
//        reSide.Position.Y := 32;

        reSide.Align := TAlignLayout.Left;

        reSide.XRadius := reBackground.XRadius;
        reSide.YRadius := reBackground.XRadius;
        reSide.Corners := [TCorner.TopLeft, TCorner.BottomLeft];
        reBackground.AddObject(reSide);

        LClick := TLabel.Create(reBackground);
        LClick.Text := 'Close';
        LClick.Font.Size := 12.5;
        LClick.Width := 60;
        LClick.FontColor := $FFBCBFC2;

//        LClick.Position.X := lo.Width - (LClick.Width + 16);

        LClick.Align := TAlignLayout.Right;
        LClick.Margins.Right := 8;

        LClick.TextSettings.HorzAlign := TTextAlign.Center;
        LClick.HitTest := True;
        LClick.StyledSettings := [];
        reBackground.AddObject(LClick);

        LStatus := TLabel.Create(reBackground);
        LStatus.Font.Size := 15;
        LStatus.Text := FStatus;
        LStatus.Height := 20;
        LStatus.Width := reBackground.Width - (LClick.Width + reSide.Width + 16);;
        LStatus.FontColor := FColor;
        LStatus.Position.X := reSide.Position.X + reSide.Width + 8;
        LStatus.Position.Y := 8;
        LStatus.StyledSettings := [];
        reBackground.AddObject(LStatus);

        LMessage := TText.Create(reBackground);
        LMessage.Font.Size := 12.5;
        LMessage.Text := AMessage;
        LMessage.AutoSize := True;
        LMessage.WordWrap := True;
        LMessage.Width := reBackground.Width - (LClick.Width + reSide.Width + 16);
        LMessage.TextSettings.FontColor := $FF36414A;
        LMessage.Position.X := reSide.Position.X + reSide.Width + 8;
        LMessage.Position.Y := LStatus.Position.Y + LStatus.Height + 4;
        LMessage.TextSettings.HorzAlign := TTextAlign.Leading;
        reBackground.AddObject(LMessage);

        reBackground.Height := LStatus.Height + LMessage.Height + 20;
        reSide.Height := reBackground.Height;
        LClick.Height := reBackground.Height;
        LClick.Position.Y := reBackground.Position.Y;

        FTransProccess := FProc;
        LClick.OnClick := defClickPopUp;

    FTransLayoutPopup := lo;
    StatePopup := True;
  end;
end;

procedure TMainHelper.ShowToastMessage(AMessage: String; ATypeMessage: TTypeMessage; APositionMessage : TPositionMessage);
var
  lo : TLayout;
  loPop : TLayout;
  reBlack : TRectangle;
  reSide : TRectangle;
  reBackground : TRectangle;
  LStatus : TLabel;
  LMessage : TText;
  LClick : TLabel;
  FStatus : String;
  FColor : Cardinal;
begin
  if FListTemporaryToast.Count > 0 then begin
    for var i := FListTemporaryToast.Count - 1 downto 0 do begin
      if Assigned(FListTemporaryToast[i]) then begin
        FListTemporaryToast[i].DisposeOf;
        FListTemporaryToast.Delete(i);
      end;
    end;
  end;

  if ATypeMessage = TTypeMessage.Success then begin
    FStatus := 'Success!';
    FColor := $FF4BC961;
  end else if ATypeMessage = TTypeMessage.Error then begin
    FStatus := 'Error...';
    FColor := $FFFF004B;
  end else if ATypeMessage = TTypeMessage.Information then begin
    FStatus := 'Information';
    FColor := $FF36414A;
  end;

  if not Assigned(TLayout(SetForm.FindStyleResource('loToast'))) then begin
    lo := TLayout.Create(SetForm);
    lo.StyleName := 'loToast';
    lo.Align := TAlignLayout.Contents;
    SetForm.AddObject(lo);
  end else begin
    lo := TLayout(SetForm.FindStyleResource('loToast'));
  end;

  loPop := TLayout.Create(lo);
//  loPop.Align := TAlignLayout.Top;
  if APositionMessage = Bottom then loPop.Align := TAlignLayout.Bottom else loPop.Align := TAlignLayout.Top;
  loPop.Margins.Top := 16;
  loPop.Margins.Left := 16;
  loPop.Margins.Bottom := 16;
  if SetForm.Width < 392 then
    loPop.Margins.Right := 24
  else
    loPop.Margins.Right := SetForm.Width - 392;

  loPop.Position.Y := 1000;
  lo.AddObject(loPop);

  reBackground := TRectangle.Create(loPop);
  reBackground.Fill.Color := TAlphaColorRec.White;
  reBackground.Stroke.Color := $FFBCBFC2;
  reBackground.Width := loPop.Width;
  reBackground.Position.X := 0;
  reBackground.Position.Y := 0;
  reBackground.XRadius := 8;
  reBackground.YRadius := reBackground.XRadius;
  reBackground.Align := TAlignLayout.Contents;
  reBackground.HitTest := False;
  //reBackground.Anchors := [TAnchorKind.akLeft, TAnchorKind.akRight, TAnchorKind.akTop, TAnchorKind.akBottom];
  loPop.AddObject(reBackground);

  reBackground.HitTest := False;

  reSide := TRectangle.Create(loPop);
  reSide.Fill.Color := FColor;
  reSide.Stroke.Kind := TBrushKind.None;
  reSide.Width := 10;
  reSide.Position.X := 0;
  reSide.Position.Y := 0;
  reSide.XRadius := reBackground.XRadius;
  reSide.YRadius := reBackground.XRadius;
  reSide.Corners := [TCorner.TopLeft, TCorner.BottomLeft];
  reSide.Align := TAlignLayout.Left;
  //reSide.Anchors := [TAnchorKind.akLeft, TAnchorKind.akTop, TAnchorKind.akBottom];
  loPop.AddObject(reSide);

  reSide.HitTest := False;

  LClick := TLabel.Create(loPop);
  LClick.Text := 'Close';
  LClick.Font.Size := 12.5;
  LClick.Width := 16;
  LClick.Height := loPop.Height;
  LClick.FontColor := $FFBCBFC2;
  LClick.Position.X := loPop.Width - LClick.Width;
  LClick.Position.Y := 0;
  LClick.TextSettings.HorzAlign := TTextAlign.Center;
  LClick.HitTest := True;
  LClick.StyledSettings := [];
  LClick.Align := TAlignLayout.Right;
  //LClick.Anchors := [TAnchorKind.akRight, TAnchorKind.akTop, TAnchorKind.akBottom];
  loPop.AddObject(LClick);

  LStatus := TLabel.Create(loPop);
  LStatus.Font.Size := 15;
  LStatus.Text := FStatus;
  LStatus.Height := 20;
  LStatus.Width := reBackground.Width - (LClick.Width + reSide.Width + 16);;
  LStatus.FontColor := FColor;
  LStatus.Position.X := reSide.Position.X + reSide.Width + 8;
  LStatus.Position.Y := 8;
  LStatus.StyledSettings := [];
  loPop.AddObject(LStatus);

  LMessage := TText.Create(loPop);
  LMessage.Font.Size := 12.5;
  LMessage.Text := AMessage;
  LMessage.AutoSize := True;
  LMessage.WordWrap := True;
  LMessage.Width := reBackground.Width - (LClick.Width + reSide.Width + 16);
  LMessage.TextSettings.FontColor := $FF36414A;
  LMessage.Position.X := reSide.Position.X + reSide.Width + 8;
  LMessage.Position.Y := LStatus.Position.Y + LStatus.Height + 4;
  LMessage.TextSettings.HorzAlign := TTextAlign.Leading;
  loPop.AddObject(LMessage);

  loPop.Height := LStatus.Height + LMessage.Height + 20;

  LClick.OnClick := defClickToast;

  LClick.Visible := False; //hide because error

  var FLOpa : TFloatAnimation;
  FLOpa := TFloatAnimation.Create(loPop);
  FLOpa.Parent := loPop;
  FLOpa.PropertyName := 'Opacity';
  FLOpa.StartValue := 1;
  FLOpa.StopValue := 0;
  FLOpa.Delay := 1;
  FLOpa.Duration := 3.75;

  FLOpa.OnFinish := flFinish;

  loPop.HitTest := False;

  FLOpa.Enabled := True;
end;

procedure TMainHelper.StartLoading(AText : String);
begin
  TThread.Synchronize(TThread.CurrentThread, procedure begin Self.Loading(True, AText); end);
end;

procedure TMainHelper.StopLoading;
begin
  TThread.Synchronize(TThread.CurrentThread, procedure begin Self.Loading(False); end);
end;

end.

