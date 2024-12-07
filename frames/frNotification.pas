unit frNotification;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading,
  FMX.Edit, FMX.Effects, FMX.ImgList, FMX.ListBox;

type
  TFNotif = class(TFrame)
    loMain: TLayout;
    background: TRectangle;
    loHeader: TLayout;
    reHeader: TRectangle;
    seHeader: TShadowEffect;
    btnBack: TCornerButton;
    Label1: TLabel;
    loTemp: TLayout;
    reTempBackground: TRectangle;
    lblTempTitle: TLabel;
    lblTempDesc: TLabel;
    ciTempIndicator: TCircle;
    lbData: TListBox;
    ListBoxItem1: TListBoxItem;
    Layout1: TLayout;
    Rectangle1: TRectangle;
    Label2: TLabel;
    Label3: TLabel;
    Circle1: TCircle;
    ListBoxItem2: TListBoxItem;
    Layout2: TLayout;
    Rectangle2: TRectangle;
    Label4: TLabel;
    Label5: TLabel;
    Circle2: TCircle;
    ListBoxItem3: TListBoxItem;
    Layout3: TLayout;
    Rectangle3: TRectangle;
    Label6: TLabel;
    Label7: TLabel;
    ListBoxItem4: TListBoxItem;
    Layout4: TLayout;
    Rectangle4: TRectangle;
    Label8: TLabel;
    Label9: TLabel;
    procedure Label1Click(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
  private
  public
  published
    procedure Show;
    procedure Back;

    constructor Create(AOwner : TComponent); override;
  end;

var
  FNotif: TFNotif;

implementation

{$R *.fmx}

uses frMain, BFA.Global.Variable,
  BFA.Control.Form.Message, BFA.Control.Frame, BFA.Control.Keyboard,
  BFA.Control.Permission, BFA.Control.PushNotification, BFA.Global.Func,
  BFA.Helper.Main, BFA.Helper.MemoryTable;

{ TFTemp }

procedure TFNotif.Back;
begin
  Frame.Back;
end;

procedure TFNotif.btnBackClick(Sender: TObject);
begin
  Back;
end;

constructor TFNotif.Create(AOwner: TComponent);
begin
  inherited;

  loTemp.Visible := False;
  lbData.AniCalculations.BoundsAnimation := True;

end;

procedure TFNotif.Label1Click(Sender: TObject);
begin
  Frame.GoFrame(C_HOME);
end;

procedure TFNotif.Show;
begin

end;

end.
