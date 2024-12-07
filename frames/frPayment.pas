unit frPayment;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading,
  FMX.Edit, FMX.Effects, FMX.ListBox, FMX.DateTimeCtrls, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Memo, StrUtils;

type
  TFPayment = class(TFrame)
    loMain: TLayout;
    background: TRectangle;
    loHeader: TLayout;
    reHeader: TRectangle;
    seHeader: TShadowEffect;
    btnBack: TCornerButton;
    lblTitle: TLabel;
    loDetailClient: TLayout;
    tempIcon: TCornerButton;
    lblTempTitle: TLabel;
    lblTempDesc: TLabel;
    lbListInput: TListBox;
    ListBoxItem1: TListBoxItem;
    Label4: TLabel;
    cbTypePayment: TComboBox;
    ListBoxItem2: TListBoxItem;
    ListBoxItem3: TListBoxItem;
    Label1: TLabel;
    Rectangle2: TRectangle;
    Label5: TLabel;
    swCredit: TSwitch;
    Label2: TLabel;
    edSubTotal: TEdit;
    ListBoxItem4: TListBoxItem;
    Label3: TLabel;
    edDiscount: TEdit;
    edTax: TEdit;
    lbDate: TListBoxItem;
    Label6: TLabel;
    dtCredit: TDateEdit;
    loFooter: TLayout;
    Rectangle1: TRectangle;
    lblTotalPrice: TLabel;
    Label8: TLabel;
    btnContinue: TCornerButton;
    seFooter: TShadowEffect;
    ListBoxItem6: TListBoxItem;
    Memo1: TMemo;
    Rectangle3: TRectangle;
    lblRealPrice: TLabel;
    procedure Label1Click(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure swCreditClick(Sender: TObject);
    procedure edDiscountTyping(Sender: TObject);
    procedure btnContinueClick(Sender: TObject);
  private
    procedure SetFrame;
  public
    FValueSubTotal : Single;
    FValueTax : Single;
    TransID : String;
    IsMember : Boolean;
  published
    procedure Show;
    procedure Back;

    constructor Create(AOwner : TComponent); override;
  end;

var
  FPayment: TFPayment;

implementation

{$R *.fmx}

uses frMain, BFA.Global.Variable,
  BFA.Control.Form.Message, BFA.Control.Frame, BFA.Control.Keyboard,
  BFA.Control.Permission, BFA.Control.PushNotification, BFA.Global.Func,
  BFA.Helper.Main, BFA.Helper.MemoryTable, frConfirmation;

{ TFTemp }

procedure TFPayment.Back;
begin
  //add logic for back here
  Frame.Back;
end;

procedure TFPayment.btnBackClick(Sender: TObject);
begin
  Back;
end;

procedure TFPayment.btnContinueClick(Sender: TObject);
begin
  if Assigned(FConfirmation) then FreeAndNil(FConfirmation);

  FConfirmation := TFConfirmation.Create(FMain);
  FConfirmation.Parent := FMain;
  FConfirmation.TypePopup := Success;
  FConfirmation.Title := 'CONFIRMATION';
  FConfirmation.Caption := 'Process Order';
  FConfirmation.Description := 'Are you sure you want to continue this order process? If yes, then press the confirm button';

  FConfirmation.Show(procedure begin
    HelperFunction.ShowToastMessage('Order Success', Success);
    HelperFunction.MoveToFrame(C_ORDERHISTORY);
  end);
end;

constructor TFPayment.Create(AOwner: TComponent);
begin
  inherited;
  GlobalFunction.SetFontCombobox(cbTypePayment, 12.5, True);
end;

procedure TFPayment.edDiscountTyping(Sender: TObject);
var
  FTotal,
  FDiscount : Single;
begin
  lblRealPrice.Text := '';
  if ContainsStr(edDiscount.Text, '%') then begin
    var FText := GlobalFunction.ReplaceStr(edDiscount.Text, '%', '');
    FDiscount := (StrToFloatDef(Trim(FText), 0) / 100 * FValueSubTotal);
  end else begin
    FDiscount := StrToFloatDef(Trim(edDiscount.Text), 0);
  end;

  FTotal := (FValueSubTotal + FValueTax) - FDiscount;
  if edDiscount.Text <> '' then
    lblRealPrice.Text := FormatFloat('###,##0.00', FValueSubTotal + FValueTax);

  lblTotalPrice.Text := FormatFloat('###,##0.00', FTotal);
end;

procedure TFPayment.Label1Click(Sender: TObject);
begin
  Frame.GoFrame(C_HOME);
end;

procedure TFPayment.SetFrame;
begin
  loDetailClient.Visible := IsMember;
  swCredit.IsChecked := False;
  lbDate.Visible := swCredit.IsChecked;

  dtCredit.Date := Now;
  edDiscount.Text := '';
  cbTypePayment.ItemIndex := 0;

  lblRealPrice.Text := '';
end;

procedure TFPayment.Show;
begin
  SetFrame;
end;

procedure TFPayment.swCreditClick(Sender: TObject);
begin
  lbDate.Visible := swCredit.IsChecked;
end;

end.
