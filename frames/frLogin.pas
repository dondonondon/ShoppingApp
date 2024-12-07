unit frLogin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, System.Threading,
  FMX.Edit, FMX.Effects, frCalender, IdGlobal, FMX.ExtCtrls, FMX.Ani,
  FMX.Filter.Effects, FMX.Styles;

type
  TFLogin = class(TFrame)
    loMain: TLayout;
    loginbackground: TRectangle;
    loLogin: TLayout;
    imgHeader: TImage;
    Label1: TLabel;
    background: TRectangle;
    mainbackground: TRectangle;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    edEmail: TEdit;
    edPassword: TEdit;
    Label5: TLabel;
    edPasswordEye: TPasswordEditButton;
    btnLogin: TCornerButton;
    cbRememberMe: TCheckBox;
    swTheme: TSwitch;
    procedure edEmailTyping(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
    procedure swThemeClick(Sender: TObject);
    procedure Label1Click(Sender: TObject);
  private
    ACalender : TFCalender;
  public
  published
    procedure Show;
    procedure Back;

    constructor Create(AOwner : TComponent); override;
  end;

var
  FLogin: TFLogin;

implementation

{$R *.fmx}

uses
  {$IFDEF ANDROID}
    Androidapi.Helpers, FMX.Platform.Android, System.Android.Service, System.IOUtils,
    FMX.Helpers.Android, Androidapi.JNI.PlayServices, Androidapi.JNI.Os,
  {$ENDIF}
  frMain, BFA.Global.Variable,
  BFA.Control.Form.Message, BFA.Control.Frame, BFA.Control.Keyboard,
  BFA.Control.Permission, BFA.Control.PushNotification, BFA.Global.Func,
  BFA.Helper.Main, BFA.Helper.MemoryTable, uDM;

{ TFTemp }

procedure TFLogin.Back;
begin
  Frame.Back;
end;

procedure TFLogin.btnLoginClick(Sender: TObject);
begin
  if (edEmail.Text = 'admin') AND (edPassword.Text = 'admin') then begin
    HelperFunction.MoveToFrame(C_HOME);
  end else begin
    HelperEditText.SetMessage(edEmail, '', $FF0B1527, False);
    HelperEditText.SetMessage(edPassword, '', $FF0B1527, False);

    HelperEditText.SetEdit(edEmail, $FF0B1527);
    HelperEditText.SetEdit(edPassword, $FF0B1527);

    HelperFunction.ShowToastMessage('Please checked true "Remember me"', TTypeMessage.Error, TPositionMessage.Bottom);

    if cbRememberMe.IsChecked then begin
      HelperEditText.SetMessage(edEmail, 'Error Text. user "admin"', $FFFF004B, True);
      HelperEditText.SetMessage(edPassword, 'Error Text pass "admin"', $FFFF004B, True);
    end;
  end;
end;

constructor TFLogin.Create(AOwner: TComponent);
begin
  inherited;
end;

procedure TFLogin.edEmailTyping(Sender: TObject);
begin
  HelperEditText.SetEdit(TEdit(Sender));
  HelperEditText.SetMessage(TEdit(Sender), '', $FF0B1527, False);
  btnLogin.Enabled := (edEmail.Text <> '') AND (edPassword.Text <> '');
end;

procedure TFLogin.Label1Click(Sender: TObject);
begin
//  HelperFunction.MoveToFrame(C_HOME);
//  Self.Visible := False;
//  TTask.Run(procedure begin
//    Sleep(2000);
//    TThread.Synchronize(nil, procedure begin
//      Self.Visible := True;
//    end);
//  end).Start;
end;

procedure TFLogin.Show;
begin
  HelperFunction.SetStatusBarColor($FF5775CD);

  swTheme.IsChecked := HelperStyle.GetTheme = Dark;
end;

procedure TFLogin.swThemeClick(Sender: TObject);
begin
  if swTheme.IsChecked then
    HelperStyle.ApplyStyle(TTypeTheme.Dark)
  else
    HelperStyle.ApplyStyle(TTypeTheme.Light);
end;

end.
