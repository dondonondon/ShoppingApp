unit frProductDetail;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading,
  FMX.Edit, FMX.Effects;

type
  TFProductDetail = class(TFrame)
    loMain: TLayout;
    background: TRectangle;
    loHeader: TLayout;
    reHeader: TRectangle;
    seHeader: TShadowEffect;
    btnBack: TCornerButton;
    lblTitle: TLabel;
    imgMain: TImage;
    lblTempExp: TLabel;
    lblTempID: TLabel;
    lblTempPrice: TLabel;
    lblTempStorage: TLabel;
    lblTempTitle: TLabel;
    reStorage: TRectangle;
    lblTempDesc: TLabel;
    imgBottom: TImage;
    loBottom: TLayout;
    reBottom: TRectangle;
    seBottom: TShadowEffect;
    btnNewOrder: TCornerButton;
    loControlPM: TLayout;
    btnMin: TCornerButton;
    btnPlus: TCornerButton;
    lblValue: TLabel;
    loChangePrice: TLayout;
    reChangePrice: TRectangle;
    loCPMain: TLayout;
    reCPMainBackground: TRectangle;
    loCPIncDecPrice: TLayout;
    btnCPDec: TCornerButton;
    btnCPInc: TCornerButton;
    lblProductName: TLabel;
    Label3: TLabel;
    edCPPrice: TEdit;
    btnCPOk: TCornerButton;
    procedure Label1Click(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure btnPlusClick(Sender: TObject);
    procedure btnNewOrderClick(Sender: TObject);
    procedure reChangePriceClick(Sender: TObject);
    procedure btnCPOkClick(Sender: TObject);
    procedure btnCPIncClick(Sender: TObject);
    procedure btnCPDecClick(Sender: TObject);
  private
    procedure SetFrame;
  public
    FPrice : Single;
    FIndexImage : Integer;
  published
    procedure Show;
    procedure Back;

    constructor Create(AOwner : TComponent); override;
  end;

var
  FProductDetail: TFProductDetail;

implementation

{$R *.fmx}

uses frMain, BFA.Global.Variable,
  BFA.Control.Form.Message, BFA.Control.Frame, BFA.Control.Keyboard,
  BFA.Control.Permission, BFA.Control.PushNotification, BFA.Global.Func,
  BFA.Helper.Main, BFA.Helper.MemoryTable, uDM, frTransAddProduct;

{ TFTemp }

procedure TFProductDetail.Back;
begin
  //add logic for back here
  if loChangePrice.Visible then
    loChangePrice.Visible := False else
    Frame.Back;
end;

procedure TFProductDetail.btnBackClick(Sender: TObject);
begin
  Back;
end;

procedure TFProductDetail.btnCPDecClick(Sender: TObject);
begin
  var Val := StrToFloatDef(edCPPrice.Text, FPrice);
  Val := Val - 1;
  if Val <= 0 then Val := 1;

  edCPPrice.Text := FormatFloat('###,##0.00', Val);
end;

procedure TFProductDetail.btnCPIncClick(Sender: TObject);
begin
  var Val := StrToFloatDef(edCPPrice.Text, FPrice);
  Val := Val + 1;

  edCPPrice.Text := FormatFloat('###,##0.00', Val);
end;

procedure TFProductDetail.btnCPOkClick(Sender: TObject);
begin
  loChangePrice.Visible := False;

  var tempFrame := TFTransAddProduct(Frame.GetFrame(C_TRANSADDPRODUCT));

  //procedure AddItem(AIndex : Integer; AName, AExp : String; APrice : Single; AQty : Integer);
  if tempFrame.CheckItemIsAvailable(FIndexImage, StrToFloatDef(edCPPrice.Text, FPrice)) >= 0 then
    tempFrame.AddQty(FIndexImage, StrToFloatDef(edCPPrice.Text, FPrice)) else
    tempFrame.AddItem(
      FIndexImage,
      lblTempTitle.Text,
      lblTempExp.Text,
      StrToFloatDef(edCPPrice.Text, FPrice),
      StrToIntDef(lblValue.Text, 1)
    );

  Back;
end;

procedure TFProductDetail.btnNewOrderClick(Sender: TObject);
begin
  lblProductName.Text := lblTempTitle.Text;

  loChangePrice.Visible := True;
end;

procedure TFProductDetail.btnPlusClick(Sender: TObject);
begin
  var Val := StrToIntDef(lblValue.Text, 1);
  Val := Val + TCornerButton(Sender).Tag;

  if Val < 1 then Val := 1;

  lblValue.Text := Val.ToString;
end;

constructor TFProductDetail.Create(AOwner: TComponent);
begin
  inherited;
  var FFileName := GlobalFunction.LoadFile('detailimage.png');
  if FileExists(FFileName) then
    imgBottom.Bitmap.LoadFromFile(FFileName);
end;

procedure TFProductDetail.Label1Click(Sender: TObject);
begin
  Frame.GoFrame(C_HOME);
end;

procedure TFProductDetail.reChangePriceClick(Sender: TObject);
begin
  loChangePrice.Visible := False;
end;

procedure TFProductDetail.SetFrame;
begin
  lblValue.Text := '1';
  loChangePrice.Visible := False;
end;

procedure TFProductDetail.Show;
begin
  SetFrame;
  edCPPrice.Text := FormatFloat('###,##0.00', FPrice);
end;

end.
