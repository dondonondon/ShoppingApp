unit frTransAddProduct;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading,
  FMX.Edit, FMX.Effects, FMX.ListBox, System.Generics.Collections;

type
  TFTransAddProduct = class(TFrame)
    loMain: TLayout;
    background: TRectangle;
    loHeader: TLayout;
    reHeader: TRectangle;
    seHeader: TShadowEffect;
    btnBack: TCornerButton;
    lblTitle: TLabel;
    btnChat: TCornerButton;
    btnDiscount: TCornerButton;
    loDetailClient: TLayout;
    tempIcon: TCornerButton;
    lblTempTitle: TLabel;
    lblTempDesc: TLabel;
    imgNoData: TImage;
    btnNewOrder: TCornerButton;
    lbData: TListBox;
    loTemp: TLayout;
    reTempBackground: TRectangle;
    lblTempTitleData: TLabel;
    lblTempExp: TLabel;
    lblTempPrice: TLabel;
    imgTemp: TImage;
    btnMin: TCornerButton;
    btnPlus: TCornerButton;
    lblTempQty: TLabel;
    loFooter: TLayout;
    lblSubTotalPrice: TLabel;
    Label2: TLabel;
    btnContinue: TCornerButton;
    Rectangle1: TRectangle;
    seFooter: TShadowEffect;
    procedure btnBackClick(Sender: TObject);
    procedure btnNewOrderClick(Sender: TObject);
    procedure btnPlusClick(Sender: TObject);
    procedure btnContinueClick(Sender: TObject);
  private
    FValueSubTotal : Single;
    FValueTax : Single;
    ListData : TList<TLayout>;
    procedure SetFrame;
    function CheckItem : Boolean;
    procedure CalcSubTotalPrice;
  public
    TransID : String;
    IsMember : Boolean;

    procedure AddItem(AIndex : Integer; AName, AExp : String; APrice : Single; AQty : Integer);
    function CheckItemIsAvailable(AIndex : Integer; APrice : Single) : Integer;
    procedure AddQty(AIndex : Integer; APrice : Single);

  published
    procedure Show;
    procedure Back;

    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
  end;

var
  FTransAddProduct: TFTransAddProduct;

implementation

{$R *.fmx}

uses frMain, BFA.Global.Variable,
  BFA.Control.Form.Message, BFA.Control.Frame, BFA.Control.Keyboard,
  BFA.Control.Permission, BFA.Control.PushNotification, BFA.Global.Func,
  BFA.Helper.Main, BFA.Helper.MemoryTable, frConfirmation, frPayment;

{ TFTemp }

procedure TFTransAddProduct.AddItem(AIndex: Integer; AName, AExp: String;
  APrice: Single; AQty: Integer);
begin
  var lb := TListBoxItem.Create(nil);
  lb.Selectable := False;
  lb.Height := loTemp.Height + 16;
  lb.Width := lbData.Width;
  lb.Hint := (APrice * AQty).ToString;

  var lo := TLayout(loTemp.Clone(lb));
  lo.Width := lb.Width - 32;
  lo.Position.X := 16;
  lo.Position.Y := 8;

  lb.Tag := AIndex;
  lo.Tag := AIndex;

  TLabel(lo.FindStyleResource(lblTempPrice.StyleName)).Hint := APrice.ToString;

  TLabel(lo.FindStyleResource(lblTempTitleData.StyleName)).Text := AName;
  TLabel(lo.FindStyleResource(lblTempExp.StyleName)).Text := AExp;
  TLabel(lo.FindStyleResource(lblTempPrice.StyleName)).Text := (APrice * AQty).ToString + ' TMT';
  TLabel(lo.FindStyleResource(lblTempQty.StyleName)).Text := AQty.ToString;

  if FileExists(GlobalFunction.LoadFile((AIndex).ToString + '.png')) then
    TImage(lo.FindStyleResource(imgTemp.StyleName)).Bitmap.LoadFromFile(GlobalFunction.LoadFile((AIndex).ToString + '.png'));

  TCornerButton(lo.FindStyleResource(btnMin.StyleName)).OnClick := btnPlusClick;
  TCornerButton(lo.FindStyleResource(btnPlus.StyleName)).OnClick := btnPlusClick;

  ListData.Add(lo);

  lo.Visible := True;
  lb.AddObject(lo);
  lbData.AddObject(lb);

  if imgNoData.Visible then imgNoData.Visible := False;

  CalcSubTotalPrice;
end;

procedure TFTransAddProduct.AddQty(AIndex: Integer; APrice : Single);
begin
  var FValue := CheckItemIsAvailable(AIndex, APrice);
  if FValue < 0 then Exit;

  var lo := ListData[FValue];

  var LQty := TLabel(lo.FindStyleResource(lblTempQty.StyleName));
  var FTempQty := StrToIntDef(LQty.Text, 1);
  FTempQty := FTempQty + 1;
  LQty.Text := FTempQty.ToString;
end;

procedure TFTransAddProduct.Back;
begin
  //add logic for back here
  if not CheckItem then
    Frame.Back;
end;

procedure TFTransAddProduct.btnBackClick(Sender: TObject);
begin
  Back;
end;

procedure TFTransAddProduct.btnContinueClick(Sender: TObject);
begin
  var tempPayment := TFPayment(Frame.GetFrame(C_PAYMENT));
  tempPayment.TransID := TransID;
  tempPayment.IsMember := IsMember;

  tempPayment.edSubTotal.Text := FormatFloat('###,##0.00', FValueSubTotal);
  tempPayment.edTax.Text := FormatFloat('###,##0.00', FValueTax);
  tempPayment.lblTotalPrice.Text := FormatFloat('###,##0.00', FValueTax + FValueSubTotal);

  tempPayment.FValueSubTotal := FValueSubTotal;
  tempPayment.FValueTax := FValueTax;

  HelperFunction.MoveToFrame(C_PAYMENT);
end;

procedure TFTransAddProduct.btnNewOrderClick(Sender: TObject);
begin
  HelperFunction.MoveToFrame(C_PRODUCT);
end;

procedure TFTransAddProduct.btnPlusClick(Sender: TObject);
begin
  var lo := TLayout(TCornerButton(Sender).Parent);
  var lb := TListBoxItem(lo.Parent);
  var L := TLabel(lo.FindStyleResource(lblTempQty.StyleName));
  var FPrice := StrToFloatDef(TLabel(lo.FindStyleResource(lblTempPrice.StyleName)).Hint, 0);

  var Val := StrToIntDef(L.Text, 1);
  Val := Val + TCornerButton(Sender).Tag;

  if Val < 1 then begin
    lbData.Items.Delete(lb.Index);
  end else begin
    L.Text := Val.ToString;

    lb.Hint := (FPrice * Val).ToString;
    TLabel(lo.FindStyleResource(lblTempPrice.StyleName)).Text := (FPrice * Val).ToString + ' TMT';
  end;

  CalcSubTotalPrice;
end;

procedure TFTransAddProduct.CalcSubTotalPrice;
begin
  if lbData.Items.Count = 0 then begin
    lblSubTotalPrice.Text := '0';
    Exit;
  end;

  var FSubTotal : Single := 0;
  var FTax : Single;
  for var i := 0 to lbData.Items.Count - 1 do begin
    FSubTotal := FSubTotal + StrToFloatDef(lbData.ItemByIndex(i).Hint, 0);
  end;

  FTax := FSubTotal * 0.15;
  lblSubTotalPrice.Text := Format(
    '%s + (Tax : %s)',
    [
      FormatFloat('###,##0.00', FSubTotal),
      FormatFloat('###,##0.00', FTax)
    ]
  );

  FValueSubTotal := FSubTotal;
  FValueTax := FTax;
end;

function TFTransAddProduct.CheckItem: Boolean;
begin
  Result := False;
  if lbData.Items.Count > 0 then begin
    Result := True;
    if Assigned(FConfirmation) then FreeAndNil(FConfirmation);

    FConfirmation := TFConfirmation.Create(FMain);
    FConfirmation.Parent := FMain;
    FConfirmation.TypePopup := Error;
    FConfirmation.Title := 'Confirmation';
    FConfirmation.Caption := 'Cancel order';
    FConfirmation.Description := 'If you confirm cancel the order, the selected items will be lost. Do you want to continue?';

    FConfirmation.ButtonCancel := 'No';

    FConfirmation.Show(procedure begin
      HelperFunction.ShowToastMessage('Order canceled');
      lbData.Items.Clear;
      Back;
    end);
  end;
end;

function TFTransAddProduct.CheckItemIsAvailable(AIndex: Integer; APrice : Single): Integer;
var
  lo : TLayout;
begin
  lo := nil;
  Result := -1;
  for var L in ListData do begin
    if AIndex = L.Tag then begin
      Result := ListData.IndexOf(L);
      lo := L;
      Break;
    end;
  end;

  if Assigned(lo) then begin
    var FPrice := StrToFloatDef(TLabel(lo.FindStyleResource(lblTempPrice.StyleName)).Hint, 0);
    if APrice <> FPrice then Result := -1;
  end;
end;

constructor TFTransAddProduct.Create(AOwner: TComponent);
begin
  inherited;
  ListData := TList<TLayout>.Create;

  loTemp.Visible := False;

  var FFileName := GlobalFunction.LoadFile('nodatatransaction.png');
  if FileExists(FFileName) then
    imgNoData.Bitmap.LoadFromFile(FFileName);
end;

destructor TFTransAddProduct.Destroy;
begin
  ListData.DisposeOf;
  inherited;
end;

procedure TFTransAddProduct.SetFrame;
begin
  loDetailClient.Visible := False;
  if IsMember then loDetailClient.Visible := True;
  loFooter.Visible := lbData.Items.Count > 0;
end;

procedure TFTransAddProduct.Show;
begin
  SetFrame;
  if (Frame.FrameAliasBefore = C_PRODUCTDETAIL) OR (Frame.FrameAliasBefore = C_PRODUCT)
  OR (Frame.FrameAliasBefore = C_PAYMENT) then Exit;

  ListData.Clear;
  lbData.Items.Clear;
  imgNoData.Visible := True;
  loFooter.Visible := lbData.Items.Count > 0;
end;

end.
