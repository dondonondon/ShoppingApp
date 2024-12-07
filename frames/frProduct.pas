unit frProduct;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading,
  FMX.Edit, FMX.Effects, FMX.ListBox, System.Generics.Collections, FMX.SearchBox;

type
  TFProduct = class(TFrame)
    loMain: TLayout;
    background: TRectangle;
    loHeader: TLayout;
    reHeader: TRectangle;
    seHeader: TShadowEffect;
    btnBack: TCornerButton;
    loTemp: TLayout;
    reTempBackground: TRectangle;
    lblTempTitle: TLabel;
    lblTempExp: TLabel;
    lblTempPrice: TLabel;
    lblTempID: TLabel;
    lblTempStorage: TLabel;
    imgTemp: TImage;
    lbData: TListBox;
    sbData: TSearchBox;
    edSearchBar: TEdit;
    btnNotif: TCornerButton;
    procedure btnBackClick(Sender: TObject);
    procedure lbDataItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
  private
    ListData : TList<TLayout>;
    procedure SetFrame;
    procedure AddItem(AIndex : Integer; AName, AExp, AID : String; APrice, AStorageQty : Single);
    procedure LoadData;
  public
  published
    procedure Show;
    procedure Back;

    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
  end;

var
  FProduct: TFProduct;

implementation

{$R *.fmx}

uses frMain, BFA.Global.Variable,
  BFA.Control.Form.Message, BFA.Control.Frame, BFA.Control.Keyboard,
  BFA.Control.Permission, BFA.Control.PushNotification, BFA.Global.Func,
  BFA.Helper.Main, BFA.Helper.MemoryTable, frProductDetail;

{ TFTemp }

procedure TFProduct.AddItem(AIndex: Integer; AName, AExp, AID: String; APrice,
  AStorageQty: Single);
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

  TLabel(lo.FindStyleResource(lblTempPrice.StyleName)).Hint := APrice.ToString;

  TLabel(lo.FindStyleResource(lblTempTitle.StyleName)).Text := AName;
  TLabel(lo.FindStyleResource(lblTempExp.StyleName)).Text := AExp;
  TLabel(lo.FindStyleResource(lblTempPrice.StyleName)).Text := APrice.ToString + ' TMT';
  TLabel(lo.FindStyleResource(lblTempID.StyleName)).Text := AID;
  TLabel(lo.FindStyleResource(lblTempStorage.StyleName)).Text := 'In storage: ' + AStorageQty.ToString + ' ';

  if FileExists(GlobalFunction.LoadFile((AIndex + 1).ToString + '.png')) then
    TImage(lo.FindStyleResource(imgTemp.StyleName)).Bitmap.LoadFromFile(GlobalFunction.LoadFile((AIndex + 1).ToString + '.png'));

  ListData.Add(lo);

  lo.Visible := True;
  lb.AddObject(lo);
  lbData.AddObject(lb);
end;

procedure TFProduct.Back;
begin
  //add logic for back here
  Frame.Back;
end;

procedure TFProduct.btnBackClick(Sender: TObject);
begin
  Back;
end;

constructor TFProduct.Create(AOwner: TComponent);
begin
  inherited;
  ListData := TList<TLayout>.Create;
  loTemp.Visible := False;
end;

destructor TFProduct.Destroy;
begin
  ListData.DisposeOf;
  inherited;
end;

procedure TFProduct.lbDataItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
  var lo := ListData[Item.Tag];
  var TempDetail := TFProductDetail(Frame.GetFrame(C_PRODUCTDETAIL));

  TempDetail.FPrice := StrToFloatDef(TLabel(lo.FindStyleResource(lblTempPrice.StyleName)).Hint, 0);
  TempDetail.FIndexImage := lo.Tag + 1;

  TempDetail.imgMain.Bitmap := TImage(lo.FindStyleResource(imgTemp.StyleName)).Bitmap;
  TempDetail.lblTempTitle.Text := TLabel(lo.FindStyleResource(lblTempTitle.StyleName)).Text;
  TempDetail.lblTempExp.Text := TLabel(lo.FindStyleResource(lblTempExp.StyleName)).Text;
  TempDetail.lblTempID.Text := TLabel(lo.FindStyleResource(lblTempID.StyleName)).Text;
  TempDetail.lblTempPrice.Text := TLabel(lo.FindStyleResource(lblTempPrice.StyleName)).Text;
  TempDetail.lblTempStorage.Text := TLabel(lo.FindStyleResource(lblTempStorage.StyleName)).Text;
//  TempDetail.lblTempDesc.Text := TLabel(lo.FindStyleResource(lblTempDesc.StyleName)).Text;

  HelperFunction.MoveToFrame(C_PRODUCTDETAIL);
end;

procedure TFProduct.LoadData;
begin
  lbData.BeginUpdate;
  try
    ListData.Clear;
    for var i := 0 to 3 do begin
      AddItem(i,
        'Banana Chips - lorem ipsum dolor sit amet, consectetur index ' + i.ToString,
        'EXP date: 23.05.2025',
        '400658101682' + i.ToString,
        Random(20) + 10,
        Random(100) + 1000
      )
    end;
  finally
    lbData.EndUpdate;
  end;
end;

procedure TFProduct.SetFrame;
begin

end;

procedure TFProduct.Show;
begin
  SetFrame;

  if lbData.Items.Count > 0 then Exit;

  LoadData;
end;

end.
