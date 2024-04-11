unit cUsuario;

interface

uses FireDAC.Comp.Client, FireDAC.DApt, System.SysUtils, FMX.Graphics,
uFormat, FMX.DialogService;

type
  TUsuario = class
  private
    Fconn: TFDConnection;
    Femail: String;
    FidUsuario: Integer;
    FindLogin: String;
    Fsenha: String;
    Fnome: String;
    Ffoto: TBitmap;

  public
    constructor Create(conn: TFDConnection);
    property idUsuario: Integer read FidUsuario write FidUsuario;
    property nome: String read Fnome write Fnome;
    property email: String read Femail write Femail;
    property senha: String read Fsenha write Fsenha;
    property indLogin: String read FindLogin write FindLogin;
    property foto: TBitmap read Ffoto write Ffoto;

    function ListarUsuario(out erro: String): TFDQuery;
    function Inserir(out erro: String): Boolean;
    function Alterar(out erro: String): Boolean;
    function Excluir(out erro: String): Boolean;
    function ValidarLogin(out erro: String): Boolean;
    function Logout(out erro: String): Boolean;
  end;

implementation

// uses UDataModule;

constructor TUsuario.Create(conn: TFDConnection);
begin
  Fconn := conn;
end;

function TUsuario.Inserir(out erro: String): Boolean;
var
  qry: TFDQuery;
begin
  if nome = '' then
  begin
    erro := 'informe o nome do usuario';
    Result := false;
    exit;
  end;

  if email = '' then
  begin
    erro := 'informe o E-Mail do usuario';
    Result := false;
    exit;
  end;

  if senha = '' then
  begin
    erro := 'informe a senha do usuario';
    Result := false;
    exit;
  end;

  try

    Fconn.StartTransaction;

    try
      qry := TFDQuery.Create(nil);
      qry.Connection := Fconn;

      begin
        qry.Close;
        qry.sql.Clear;
        qry.sql.Add('INSERT INTO TAB_USUARIO(nome, email, senha, indLogin, foto)');
        qry.sql.Add('VALUES(:nome, :email, :senha, :indLogin, :foto)');
        qry.ParamByName('nome').AsString := nome;
        qry.ParamByName('email').AsString := email;
        qry.ParamByName('senha').AsString := senha;
        qry.ParamByName('indLogin').AsString := indLogin;
        qry.ParamByName('foto').Assign(foto);
        qry.ExecSQL;
      end;

      Result := true;
      erro := '';

    except
      on ex: Exception do
      begin
        Result := false;
        erro := 'Erro ao inserir ao inserir' + ex.Message;
      end;
    end;
  finally
    qry.DisposeOf;

  end;

end;

function TUsuario.Alterar(out erro: String): Boolean;
var
  qry: TFDQuery;
begin

  if nome = '' then
  begin
    erro := 'informe o nome do usuario';
    Result := false;
    exit;
  end;

  if email = '' then
  begin
    erro := 'informe o E-Mail do usuario';
    Result := false;
    exit;
  end;

  if senha = '' then
  begin
    erro := 'informe a senha do usuario';
    Result := false;
    exit;
  end;
  try
    qry := TFDQuery.Create(nil);
    qry.Connection := Fconn;
    Fconn.StartTransaction;

    try
      begin
        qry.Close;
        qry.sql.Clear;
        qry.sql.Add
          ('UPDATE TAB_CATEGORIA SET nome = :nome, email = :email,');
        qry.sql.Add('senha = :senha, indLogin = :indLogin, foto = :foto');
        qry.sql.Add('WHERE idCategoria = :idCategoria');
        qry.ParamByName('idUsuario').AsInteger := idUsuario;
        qry.ParamByName('nome').AsString := nome;
        qry.ParamByName('email').AsString := email;
        qry.ParamByName('senha').AsString := senha;
        qry.ParamByName('indLogin').AsString := indLogin;
        qry.ParamByName('foto').Assign(foto);
        qry.ExecSQL;
      end;
      Fconn.Commit;

    except
      on ex: Exception do
      begin
        Fconn.Rollback;
        Raise
      end;
    end;
  finally
    qry.Free;
  end;

end;

function TUsuario.Excluir(out erro: String): Boolean;
var
  qry: TFDQuery;
begin
  try
    qry := TFDQuery.Create(nil);
    qry.Connection := Fconn;
    Fconn.StartTransaction;
    try
      begin
        // Validar se a categoria possui lan�amentos
        qry.Close;
        qry.sql.Clear;
        qry.sql.Add('DELETE FROM TAB_USUARIO');

        if idUsuario > 0  then
        begin
          qry.sql.Add('WHERE idUsuario = :idUsuario');
          qry.ParamByName('idUsuario').AsInteger := idUsuario;

        end;

        qry.ExecSQL;
      end;
        Fconn.Commit;
    except
      on ex:Exception do
      begin
        Fconn.Rollback;
        Raise
      end;
    end;
  finally
    qry.Free;
  end;

end;

function TUsuario.ListarUsuario(out erro: String): TFDQuery;
var
  qry: TFDQuery;
begin
  qry := TFDQuery.Create(nil);
  qry.Connection := Fconn;
  try

    begin
      qry.Active := false;
      qry.sql.Clear;
      qry.sql.Add('SELECT * FROM TAB_USUARIO');
      qry.sql.Add('WHERE 1 = 1');

      if idUsuario > 0 then
      begin
        qry.sql.Add('AND idUsuario = :idUsuario');
        qry.ParamByName('idUsuario').AsInteger := idUsuario;
      end;

       if email <> '' then
      begin
        qry.sql.Add('AND email = :email');
        qry.ParamByName('email').AsString := email;
      end;

      if senha <> '' then
      begin
        qry.sql.Add('AND senha = :senha');
        qry.ParamByName('senha').AsString := senha;
      end;

      qry.Active := true;
    end;
    Result := qry;
    erro := '';

  except
    on ex: Exception do
    begin
      Result := nil;
      erro := 'Erro ao consultar usu�rios: ' + ex.Message;
    end;

  end;
end;

function TUsuario.Logout(out erro: String): Boolean;
var
  qry: TFDQuery;
begin

  try
   qry := TFDQuery.Create(nil);
   qry.Connection := Fconn;

     try
         begin
            qry.Active := false;
            qry.sql.Clear;
            qry.sql.Add('UPDATE TAB_USUARIO');
            qry.sql.Add('SET indLogin = ''N''');
            qry.ExecSQL;
         end;
         Result := true;
         erro := '';

     except on ex: Exception do
        begin
          Result := false;
          erro := 'Erro ao fazer logout: ' + ex.Message;
        end;
     end;

  finally
  qry.DisposeOf;

  end;

end;

function TUsuario.ValidarLogin(out erro: String): Boolean;
var
  qry: TFDQuery;
begin
  if email = '' then
  begin
    erro := 'informe o E-Mail do usuario';
    Result := false;
    exit;
  end;

    if senha = '' then
  begin
    erro := 'informe a senha do usuario';
    Result := false;
    exit;
  end;

  try
   qry := TFDQuery.Create(nil);
   qry.Connection := Fconn;

     try
         begin
            qry.Active := false;
            qry.sql.Clear;
            qry.sql.Add('SELECT * FROM TAB_USUARIO');
            qry.sql.Add('WHERE email = :email');
            qry.sql.Add('AND senha = :senha');
            qry.ParamByName('email').AsString := email;
            qry.ParamByName('senha').AsString := senha;
            qry.Active := true;


            if qry.RecordCount = 0 then
            begin
              Result := false;
              erro := 'Email ou senha inv�lidos';
              exit;
            end;

            qry.Active := false;
            qry.sql.Clear;
            qry.sql.Add('UPDATE TAB_USUARIO');
            qry.sql.Add('SET indLogin = ''S''');
            qry.ExecSQL;
         end;
         Result := true;
         erro := '';

     except on ex: Exception do
        begin
          Result := false;
          erro := 'Erro ao validar login: ' + ex.Message;
        end;
     end;

  finally
  qry.DisposeOf;

  end;

end;

end.
