unit frHome;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading,
  FMX.Edit, FMX.Effects, FMX.ListBox, System.Generics.Collections;

type
  TFHome = class(TFrame)
    loMain: TLayout;
    background: TRectangle;
    loHeader: TLayout;
    reHeader: TRectangle;
    seHeader: TShadowEffect;
    btnSearch: TCornerButton;
    btnNotif: TCornerButton;
    loTemp: TLayout;
    reTempBackground: TRectangle;
    tempIcon: TCornerButton;
    lblTempTitle: TLabel;
    lblTempDesc: TLabel;
    lTempGap: TLine;
    lblTempColor: TLabel;
    lblTempValue: TLabel;
    lbData: TListBox;
    btnTempAddProduct: TCornerButton;
    btnTempOrderHistory: TCornerButton;
    btnGuest: TCornerButton;
    procedure Label1Click(Sender: TObject);
    procedure btnNotifClick(Sender: TObject);      //btnTempClick
    procedure btnSearchClick(Sender: TObject);
    procedure btnTempClick(Sender: TObject);
    procedure lbDataItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure btnGuestClick(Sender: TObject);
  private
    ListData : TList<TLayout>;
    TransListBoxItem : TListBoxItem;
    procedure SetFrame;
    procedure AddItem(AIndex : Integer; AProductName, ADescription : String; APrice : Single);
    procedure LoadData;
    procedure SetColorFont(ALayout : TLayout; IsSelected : Boolean = False);
  public
  published
    procedure Show;
    procedure Back;

    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
  end;

var
  FHome: TFHome;

implementation

{$R *.fmx}

uses frMain, BFA.Global.Variable,
  BFA.Control.Form.Message, BFA.Control.Frame, BFA.Control.Keyboard,
  BFA.Control.Permission, BFA.Control.PushNotification, BFA.Global.Func,
  BFA.Helper.Main, BFA.Helper.MemoryTable, uDM, frTransAddProduct;

{ TFTemp }

procedure TFHome.AddItem(AIndex: Integer; AProductName, ADescription: String;
  APrice: Single);
begin
  var lb := TListBoxItem.Create(nil);
  lb.Selectable := False;
  lb.Height := loTemp.Height + 16;
  lb.Width := lbData.Width;

  var lo := TLayout(loTemp.Clone(lb));
  lo.Width := lb.Width - 32;
  lo.Position.X := 16;
  lo.Position.Y := 8;

  lb.Tag := AIndex;
  lo.Tag := AIndex;

  TLabel(lo.FindStyleResource(lblTempTitle.StyleName)).Text := AProductName;
  TLabel(lo.FindStyleResource(lblTempDesc.StyleName)).Text := ADescription;
  TLabel(lo.FindStyleResource(lblTempValue.StyleName)).Text := APrice.ToString + ' TMT';
  TLabel(lo.FindStyleResource(lblTempValue.StyleName)).Hint := APrice.ToString;

  if APrice < 0 then TLabel(lo.FindStyleResource(lblTempColor.StyleName)).FontColor := $FFFF004B else
    TLabel(lo.FindStyleResource(lblTempColor.StyleName)).FontColor := $FF219653;

  TCornerButton(lo.FindStyleResource(btnTempAddProduct.StyleName)).OnClick := btnTempClick;

  ListData.Add(lo);

  lo.Visible := True;
  lb.AddObject(lo);
  lbData.AddObject(lb);
end;

procedure TFHome.Back;
begin
  if Frame.FrameAliasBefore = C_ORDERHISTORY then Exit;  
  Frame.Back;
end;

procedure TFHome.btnGuestClick(Sender: TObject);
begin
  TFTransAddProduct(Frame.GetFrame(C_TRANSADDPRODUCT)).TransID := '';
  TFTransAddProduct(Frame.GetFrame(C_TRANSADDPRODUCT)).IsMember := False;
  HelperFunction.MoveToFrame(C_TRANSADDPRODUCT);
end;

procedure TFHome.btnNotifClick(Sender: TObject);
begin
  HelperFunction.MoveToFrame(C_NOTIF);
end;

procedure TFHome.btnSearchClick(Sender: TObject);
begin
  HelperFunction.MoveToFrame(C_SEARCHHOME);
end;

procedure TFHome.btnTempClick(Sender: TObject);
begin
  var FFrameName := TCornerButton(Sender).Hint;
  if FFrameName = '' then Exit;

  var lo := TLayout(TCornerButton(Sender).Parent);

  TFTransAddProduct(Frame.GetFrame(C_TRANSADDPRODUCT)).TransID := lo.Tag.ToString;
  TFTransAddProduct(Frame.GetFrame(C_TRANSADDPRODUCT)).IsMember := True;
  HelperFunction.MoveToFrame(C_TRANSADDPRODUCT);
end;

constructor TFHome.Create(AOwner: TComponent);
begin
  inherited;
  ListData := TList<TLayout>.Create;

  loTemp.Visible := False;
  lbData.AniCalculations.BoundsAnimation := True;
  btnTempAddProduct.Visible := False;
  btnTempOrderHistory.Visible := False;
end;

destructor TFHome.Destroy;
begin
  ListData.DisposeOf;
  inherited;
end;

procedure TFHome.Label1Click(Sender: TObject);
begin
  Frame.GoFrame(C_HOME);
end;

procedure TFHome.lbDataItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
var
  lo : TLayout;
begin
  if Assigned(TransListBoxItem) then begin
    lo := ListData[TransListBoxItem.Tag];
    lo.Height := loTemp.Height;
    TransListBoxItem.Height := loTemp.Height + 16;

    TCornerButton(lo.FindStyleResource(btnTempAddProduct.StyleName)).Visible := False;
    TCornerButton(lo.FindStyleResource(btnTempOrderHistory.StyleName)).Visible := False;
    TRectangle(lo.FindStyleResource(reTempBackground.StyleName)).Fill.Color := $FFF4F8FB;

    SetColorFont(lo);
  end;

  if TransListBoxItem = Item then begin
    TransListBoxItem := nil;
    Exit;
  end;

  TransListBoxItem := Item;

  if ListData.Count = 0 then Exit;

  lo := ListData[Item.Tag];
  Item.Height := 225 + 16;
  lo.Height := 225;

  TCornerButton(lo.FindStyleResource(btnTempAddProduct.StyleName)).Visible := True;
  TCornerButton(lo.FindStyleResource(btnTempOrderHistory.StyleName)).Visible := True;
  TRectangle(lo.FindStyleResource(reTempBackground.StyleName)).Fill.Color := $FF3E79BE;

  SetColorFont(lo, True);
end;

procedure TFHome.LoadData;
var
  AVal : Integer;
begin
  lbData.BeginUpdate;
  try
    TransListBoxItem := nil;
    ListData.Clear;
    for var i := 0 to 10 do begin
      AVal := 1;
      if (Random(100) mod 2) = 0 then
        AVal := -1;

      AddItem(i,
        'Fajar Donny Delphi, '+i.ToString+' Mkr, Jakarta, Indonesia, 271496',
        'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
        (Random(1000) + 1000) * AVal
      )
    end;
  finally
    lbData.EndUpdate;
  end;
end;

procedure TFHome.SetColorFont(ALayout : TLayout; IsSelected : Boolean);
begin
  var FFontColor := $FF0B1527;
  if IsSelected then FFontColor := $FFFFFFFF;

  TLabel(ALayout.FindStyleResource(lblTempTitle.StyleName)).FontColor := FFontColor;
  TLabel(ALayout.FindStyleResource(lblTempDesc.StyleName)).FontColor := FFontColor;
  TLabel(ALayout.FindStyleResource(lblTempColor.StyleName)).FontColor := FFontColor;
  TLabel(ALayout.FindStyleResource(lblTempValue.StyleName)).FontColor := FFontColor;
  TLabel(ALayout.FindStyleResource(btnTempAddProduct.StyleName)).FontColor := FFontColor;
  TLabel(ALayout.FindStyleResource(btnTempOrderHistory.StyleName)).FontColor := FFontColor;

  TCornerButton(ALayout.FindStyleResource(tempIcon.StyleName)).ImageIndex := 9;
  if not IsSelected then begin
    TCornerButton(ALayout.FindStyleResource(tempIcon.StyleName)).ImageIndex := 8;
    var FVal := StrToFloatDef(TLabel(ALayout.FindStyleResource(lblTempValue.StyleName)).Hint, 0);

    if FVal < 0 then TLabel(ALayout.FindStyleResource(lblTempColor.StyleName)).FontColor := $FFFF004B else
      TLabel(ALayout.FindStyleResource(lblTempColor.StyleName)).FontColor := $FF219653;
  end;
end;

procedure TFHome.SetFrame;
var
  lo : TLayout;
begin
  if Assigned(TransListBoxItem) then begin
    lo := ListData[TransListBoxItem.Tag];
    lo.Height := loTemp.Height;
    TransListBoxItem.Height := loTemp.Height + 16;

    TCornerButton(lo.FindStyleResource(btnTempAddProduct.StyleName)).Visible := False;
    TCornerButton(lo.FindStyleResource(btnTempOrderHistory.StyleName)).Visible := False;
    TRectangle(lo.FindStyleResource(reTempBackground.StyleName)).Fill.Color := $FFF4F8FB;

    SetColorFont(lo);

    TransListBoxItem := nil;
  end;


  HelperFunction.SetStatusBarColor($FFFFFFFF);
  HelperFunction.SetMenu(FMain.btnClient, False);
  FMain.loBottom.Visible := True;
end;

procedure TFHome.Show;
begin
  SetFrame;

  if lbData.Items.Count > 0 then Exit;

  LoadData;
end;

end.
