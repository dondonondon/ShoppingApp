unit frSearchHome;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading,
  FMX.Edit, FMX.Effects, FMX.ListBox;

type
  TFSearchHome = class(TFrame)
    loMain: TLayout;
    background: TRectangle;
    loHeader: TLayout;
    reHeader: TRectangle;
    seHeader: TShadowEffect;
    btnBack: TCornerButton;
    edSearch: TEdit;
    btnSearch: TCornerButton;
    loHistorySearch: TLayout;
    lbData: TListBox;
    ListBoxItem1: TListBoxItem;
    CornerButton1: TCornerButton;
    CornerButton2: TCornerButton;
    Label3: TLabel;
    ListBoxItem2: TListBoxItem;
    CornerButton3: TCornerButton;
    CornerButton4: TCornerButton;
    Label1: TLabel;
    ListBoxItem3: TListBoxItem;
    CornerButton5: TCornerButton;
    CornerButton6: TCornerButton;
    Label2: TLabel;
    ListBoxItem4: TListBoxItem;
    CornerButton7: TCornerButton;
    CornerButton8: TCornerButton;
    Label4: TLabel;
    ListBoxItem5: TListBoxItem;
    CornerButton9: TCornerButton;
    CornerButton10: TCornerButton;
    Label5: TLabel;
    ListBoxItem6: TListBoxItem;
    CornerButton11: TCornerButton;
    CornerButton12: TCornerButton;
    Label6: TLabel;
    reBackgroundHistorySearch: TRectangle;
    loContainerHistorySearch: TLayout;
    Rectangle1: TRectangle;
    procedure Label1Click(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure edSearchClick(Sender: TObject);
    procedure reBackgroundHistorySearchClick(Sender: TObject);
  private
    procedure SetFrame;
  public
  published
    procedure Show;
    procedure Back;

    constructor Create(AOwner : TComponent); override;
  end;

var
  FSearchHome: TFSearchHome;

implementation

{$R *.fmx}

uses frMain, BFA.Global.Variable,
  BFA.Control.Form.Message, BFA.Control.Frame, BFA.Control.Keyboard,
  BFA.Control.Permission, BFA.Control.PushNotification, BFA.Global.Func,
  BFA.Helper.Main, BFA.Helper.MemoryTable;

{ TFTemp }

procedure TFSearchHome.Back;
begin
  if loHistorySearch.Visible then
    loHistorySearch.Visible := False
  else
    Frame.Back;
end;

procedure TFSearchHome.btnBackClick(Sender: TObject);
begin
  Back;
end;

procedure TFSearchHome.btnSearchClick(Sender: TObject);
begin
  if edSearch.Text = '' then begin
    edSearch.SetFocus;
    Exit;
  end;
end;

constructor TFSearchHome.Create(AOwner: TComponent);
begin
  inherited;

end;

procedure TFSearchHome.edSearchClick(Sender: TObject);
begin
  loHistorySearch.Visible := True;
end;

procedure TFSearchHome.Label1Click(Sender: TObject);
begin
  Frame.GoFrame(C_HOME);
end;

procedure TFSearchHome.reBackgroundHistorySearchClick(Sender: TObject);
begin
  loHistorySearch.Visible := False;
end;

procedure TFSearchHome.SetFrame;
begin
  loHistorySearch.Visible := False;
end;

procedure TFSearchHome.Show;
begin

end;

end.
