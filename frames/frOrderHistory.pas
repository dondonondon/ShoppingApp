unit frOrderHistory;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading,
  FMX.Edit, FMX.Effects, FMX.ListBox;

type
  TFOrderHistory = class(TFrame)
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
    imgNoData: TImage;
    lbData: TListBox;
    procedure Label1Click(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
  private
    procedure SetFrame;
  public
  published
    procedure Show;
    procedure Back;

    constructor Create(AOwner : TComponent); override;
  end;

var
  FOrderHistory: TFOrderHistory;

implementation

{$R *.fmx}

uses frMain, BFA.Global.Variable,
  BFA.Control.Form.Message, BFA.Control.Frame, BFA.Control.Keyboard,
  BFA.Control.Permission, BFA.Control.PushNotification, BFA.Global.Func,
  BFA.Helper.Main, BFA.Helper.MemoryTable;

{ TFTemp }

procedure TFOrderHistory.Back;
begin
  //add logic for back here
//  Frame.Back;
  HelperFunction.MoveToFrame(C_HOME);
end;

procedure TFOrderHistory.btnBackClick(Sender: TObject);
begin
  Back;
end;

constructor TFOrderHistory.Create(AOwner: TComponent);
begin
  inherited;

  var FFileName := GlobalFunction.LoadFile('nodatatransaction.png');
  if FileExists(FFileName) then
    imgNoData.Bitmap.LoadFromFile(FFileName);
end;

procedure TFOrderHistory.Label1Click(Sender: TObject);
begin
  Frame.GoFrame(C_HOME);
end;

procedure TFOrderHistory.SetFrame;
begin
  lbData.Items.Clear;
  imgNoData.Visible := True;
end;

procedure TFOrderHistory.Show;
begin
  SetFrame;
end;

end.
