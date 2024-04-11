unit ULogin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Layouts, FMX.Controls.Presentation, FMX.Edit, FMX.StdCtrls, FMX.TabControl,
  System.Actions, FMX.ActnList, u99Permissions, FMX.MediaLibrary.Actions,
  FireDAC.Comp.Client, FireDAC.DApt,
  {$IFDEF ANDROID}
  FMX.VirtualKeyboard, FMX.Platform,
  {$ENDIF}
  FMX.StdActns;
type
  TFrmLogin = class(TForm)
    LayPrincipalCentro: TLayout;
    ImgLogin: TImage;
    LayLoginEmail: TLayout;
    RoundLoginEmail: TRoundRect;
    EdtLoginEmail: TEdit;
    StyleBook1: TStyleBook;
    LayBotaoAcessar: TLayout;
    RoundBotaoAcessar: TRoundRect;
    LayLoginSenha: TLayout;
    RoundLoginSenha: TRoundRect;
    EdtLoginSenha: TEdit;
    LblABotaoAcessar: TLabel;
    TcMenusprincipais: TTabControl;
    TabLogin: TTabItem;
    TabConta: TTabItem;
    LayConta: TLayout;
    Image3: TImage;
    LayContaEmail: TLayout;
    RoundContaEmail: TRoundRect;
    EdtContaEmail: TEdit;
    LayProximo: TLayout;
    RoundProximo: TRoundRect;
    LblProximo: TLabel;
    LayContaSenha: TLayout;
    RoundContaSenha: TRoundRect;
    EdtContaSenha: TEdit;
    LayCriarNome: TLayout;
    RoundCriarNome: TRoundRect;
    EdtCriarNome: TEdit;
    TabFoto: TTabItem;
    LayCadastroFoto: TLayout;
    CircleCadastroFoto: TCircle;
    LayBotaoCarregarFoto: TLayout;
    RoundBotaoCarregarFoto: TRoundRect;
    LblBotaoCarregarFoto: TLabel;
    TabSelecionarFoto: TTabItem;
    LaySelecionarFoto: TLayout;
    LblSelecionarFoto: TLabel;
    ImgSelecionarFotoCamera: TImage;
    ImgSelecionarFotoGaleria: TImage;
    LayBotaoVoltarCadastro: TLayout;
    ImgBotaoVoltarCadastro: TImage;
    LayBotaoVoltarFoto: TLayout;
    ImgVoltarFoto: TImage;
    LayRodapeTabLogin: TLayout;
    LayLblLogin: TLayout;
    LblLogin: TLabel;
    LblCriarConta: TLabel;
    Rectangle1: TRectangle;
    ActionList1: TActionList;
    ActTabConta: TChangeTabAction;
    ActTabFoto: TChangeTabAction;
    ActTabLogin: TChangeTabAction;
    ActTabSelecionarConta: TChangeTabAction;
    LayRodapeTabConta: TLayout;
    LayLblTacConta: TLayout;
    LblLoginTabConta: TLabel;
    LblCriarContaTabConta: TLabel;
    Rectangle2: TRectangle;
    ActBiblioteca: TTakePhotoFromLibraryAction;
    ActCamera: TTakePhotoFromCameraAction;
    TimerLogin: TTimer;
    procedure LblCriarContaClick(Sender: TObject);
    procedure LblLoginTabContaClick(Sender: TObject);
    procedure RoundProximoClick(Sender: TObject);
    procedure ImgBotaoVoltarCadastroClick(Sender: TObject);
    procedure CircleCadastroFotoClick(Sender: TObject);
    procedure ImgVoltarFotoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ImgSelecionarFotoCameraClick(Sender: TObject);
    procedure ImgSelecionarFotoGaleriaClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ActBibliotecaDidFinishTaking(Image: TBitmap);
    procedure ActCameraDidFinishTaking(Image: TBitmap);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure RoundBotaoAcessarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure RoundBotaoCarregarFotoClick(Sender: TObject);
    procedure TimerLoginTimer(Sender: TObject);
    procedure FormVirtualKeyboardShown(Sender: TObject;
      KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormVirtualKeyboardHidden(Sender: TObject;
      KeyboardVisible: Boolean; const Bounds: TRect);
  private
    { Private declarations }
    permissao: T99Permissions;
    procedure TrataErroPermissao(Sender: TObject);
  public
    { Public declarations }

  end;

var
  FrmLogin: TFrmLogin;

implementation

{$R *.fmx}

uses UPrincipal, cUsuario, UDataModule;

procedure TFrmLogin.ActBibliotecaDidFinishTaking(Image: TBitmap);
begin
  CircleCadastroFoto.Fill.Bitmap.Bitmap := Image;
  ActTabFoto.Execute;
end;

procedure TFrmLogin.ActCameraDidFinishTaking(Image: TBitmap);
begin
 CircleCadastroFoto.Fill.Bitmap.Bitmap := Image;
 ActTabFoto.Execute;
end;

procedure TFrmLogin.CircleCadastroFotoClick(Sender: TObject);
begin
  ActTabSelecionarConta.Execute;
end;

procedure TFrmLogin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  FrmLogin := nil;
end;

procedure TFrmLogin.FormCreate(Sender: TObject);
begin
  permissao := T99Permissions.Create;
end;

procedure TFrmLogin.FormDestroy(Sender: TObject);
begin
    permissao.DisposeOf;
end;

procedure TFrmLogin.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
{$IFDEF ANDROID}
var
    FService : IFMXVirtualKeyboardService;
{$ENDIF}

begin
    {$IFDEF ANDROID}
    if (Key = vkHardwareBack) then
    begin
        TPlatformServices.Current.SupportsPlatformService(IFMXVirtualKeyboardService,
                                                          IInterface(FService));

        if (FService <> nil) and
           (TVirtualKeyboardState.Visible in FService.VirtualKeyBoardState) then
        begin
            // Botao back pressionado e teclado visivel...
            // (apenas fecha o teclado)
        end
        else
        begin
            // Botao back pressionado e teclado NAO visivel...

            if TcMenusprincipais.ActiveTab = TabConta then
            begin
                Key := 0;
                ActTabLogin.Execute
            end
            else if TcMenusprincipais.ActiveTab = TabFoto then
            begin
                Key := 0;
                ActTabConta.Execute
            end
            else if TcMenusprincipais.ActiveTab = TabSelecionarFoto then
            begin
                Key := 0;
                ActTabFoto.Execute;
            end;
        end;
    end;
    {$ENDIF}
end;

procedure TFrmLogin.FormShow(Sender: TObject);

begin
  TcMenusprincipais.ActiveTab := TabLogin;
  TimerLogin.Enabled := true;
end;

procedure TFrmLogin.FormVirtualKeyboardHidden(Sender: TObject;
  KeyboardVisible: Boolean; const Bounds: TRect);
begin
  TcMenusprincipais.Margins.Bottom := 0;
end;

procedure TFrmLogin.FormVirtualKeyboardShown(Sender: TObject;
  KeyboardVisible: Boolean; const Bounds: TRect);
begin
  TcMenusprincipais.Margins.Bottom := 160;
end;

procedure TFrmLogin.ImgBotaoVoltarCadastroClick(Sender: TObject);
begin
 ActTabConta.Execute;
end;

procedure TFrmLogin.TimerLoginTimer(Sender: TObject);
var
  u :TUsuario;
  erro :string;
  qry : TFDQuery;
begin

  TimerLogin.Enabled := false;

  //Validar se o usiario já logou uma vez
  try
    u := TUsuario.Create(dm.conn);
    qry := TFDQuery.Create(nil);
    qry := u.ListarUsuario(erro);

    if qry.FieldByName('indLogin').AsString <> 'S' then
      exit

  finally
    qry.DisposeOf;
    u.DisposeOf;

  end;

    if NOT Assigned(FrmPrincipal) then
    Application.CreateForm(TFrmPrincipal, FrmPrincipal);

  Application.MainForm := FrmPrincipal;
  FrmPrincipal.Show;
end;

procedure TFrmLogin.TrataErroPermissao(Sender: TObject);
begin
  ShowMessage('Você não possui acesso para esse recurso');
end;

procedure TFrmLogin.ImgSelecionarFotoCameraClick(Sender: TObject);
begin
  permissao.Camera(ActCamera, TrataErroPermissao);
end;

procedure TFrmLogin.ImgSelecionarFotoGaleriaClick(Sender: TObject);
begin
  permissao.PhotoLibrary(ActBiblioteca, TrataErroPermissao);
end;

procedure TFrmLogin.ImgVoltarFotoClick(Sender: TObject);
begin
  ActTabFoto.Execute;
end;

procedure TFrmLogin.LblCriarContaClick(Sender: TObject);
begin
   ActTabConta.Execute;
end;

procedure TFrmLogin.LblLoginTabContaClick(Sender: TObject);
begin
  ActTabLogin.Execute;
end;

procedure TFrmLogin.RoundBotaoAcessarClick(Sender: TObject);
var
  u :TUsuario;
  erro :String;
begin
  try
    u := TUsuario.Create(dm.conn);
    u.email := EdtLoginEmail.Text;
    u.senha := EdtLoginSenha.Text;


    if NOT u.ValidarLogin(erro) then
    begin
      ShowMessage(erro);
      exit
    end;

   finally
  u.DisposeOf;

  end;


  if NOT Assigned(FrmPrincipal) then
    Application.CreateForm(TFrmPrincipal, FrmPrincipal);

  Application.MainForm := FrmPrincipal;
  FrmPrincipal.Show;
  FrmLogin.Close;

end;

procedure TFrmLogin.RoundBotaoCarregarFotoClick(Sender: TObject);
var
  u :TUsuario;
  erro :String;
begin
  try
    u := TUsuario.Create(dm.conn);
    u.nome := EdtCriarNome.Text;
    u.email := EdtContaEmail.Text;
    u.senha := EdtContaSenha.Text;
    u.indLogin := 'S';
    u.foto := CircleCadastroFoto.Fill.Bitmap.Bitmap;

    //Excluir conta existente
    if not u.Excluir(erro)  then
    begin
      ShowMessage(erro);
      exit
    end;

    //Inserir novo usuario
    if not u.Inserir(erro)  then
    begin
      ShowMessage(erro);
      exit
    end;

  finally
    u.DisposeOf;
  end;


  if NOT Assigned(FrmPrincipal) then
    Application.CreateForm(TFrmPrincipal, FrmPrincipal);

  Application.MainForm := FrmPrincipal;
  FrmPrincipal.Show;
  FrmLogin.Close;

end;

procedure TFrmLogin.RoundProximoClick(Sender: TObject);
begin
  ActTabFoto.Execute;
end;

end.
