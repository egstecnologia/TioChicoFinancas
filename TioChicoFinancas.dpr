program TioChicoFinancas;

uses
  System.StartUpCopy,
  FMX.Forms,
  ULogin in 'ULogin.pas' {FrmLogin},
  u99Permissions in 'Units\u99Permissions.pas',
  UPrincipal in 'UPrincipal.pas' {FrmPrincipal},
  ULancamentos in 'ULancamentos.pas' {FrmLancamentos},
  ULancamentosCadastro in 'ULancamentosCadastro.pas' {FrmLancamentosCadastro},
  UCategorias in 'UCategorias.pas' {FrmCategorias},
  UCategoriasCadastro in 'UCategoriasCadastro.pas' {FrmCategoriasCadastro},
  UDataModule in 'UDataModule.pas' {dm: TDataModule},
  cCategoria in 'Classes\cCategoria.pas',
  cLancamento in 'Classes\cLancamento.pas',
  uFormat in 'Units\uFormat.pas',
  cUsuario in 'Classes\cUsuario.pas',
  UComboCategoria in 'UComboCategoria.pas' {FrmComboCategoria},
  UResumo in 'UResumo.pas' {FrmResumo};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(Tdm, dm);
  Application.CreateForm(TFrmLogin, FrmLogin);
  Application.CreateForm(TFrmComboCategoria, FrmComboCategoria);
  Application.CreateForm(TFrmResumo, FrmResumo);
  Application.Run;
end.
