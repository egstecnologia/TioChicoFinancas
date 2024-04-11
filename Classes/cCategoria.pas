unit cCategoria;

interface

uses FireDAC.Comp.Client, FireDAC.DApt, System.SysUtils, FMX.Graphics;

type
  TCategoria = class
  private
    Fconn: TFDConnection;
    FidCategoria: Integer;
    Fdescricao: String;
    Ficone: TBitmap;
    FindiceIcone: Integer;

  public
    constructor Create(conn: TFDConnection);
    property idCategoria: Integer read FidCategoria write FidCategoria;
    property descricao: String read Fdescricao write Fdescricao;
    property icone: TBitmap read Ficone write Ficone;
    property indiceIcone: Integer read FindiceIcone write FindiceIcone;

    function ListarCategoria(out erro: String): TFDQuery;
    function Inserir(out erro: String): Boolean;
    function Alterar(out erro: String): Boolean;
    function Excluir(out erro: String): Boolean;
  end;

implementation

// uses UDataModule;

constructor TCategoria.Create(conn: TFDConnection);
begin
  Fconn := conn;
end;

function TCategoria.Inserir(out erro: String): Boolean;
var
  qry: TFDQuery;
begin
  if descricao = '' then
  begin
    erro := 'informe a descricao da categoria';
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
        qry.sql.Add('INSERT INTO TAB_CATEGORIA(descricao, icone, indiceIcone)');
        qry.sql.Add('VALUES(:descricao, :icone, :indiceIcone)');
        qry.ParamByName('descricao').AsString := descricao;
        qry.ParamByName('icone').Assign(icone);
        qry.ParamByName('indiceIcone').Value := indiceIcone;
        qry.ExecSQL;
      end;

      Result := true;
      erro := '';

    except
      on ex: Exception do
      begin
        Result := false;
        erro := 'Erro ao inserir a descrição da categoria' + ex.Message;
      end;
    end;
  finally
    qry.DisposeOf;

  end;

end;

function TCategoria.Alterar(out erro: String): Boolean;
var
  qry: TFDQuery;
begin

  if idCategoria <= 0 then
  begin
    erro := 'informe o ID da categoria';
    Result := false;
    exit;
  end;

  if descricao = '' then
  begin
    erro := 'informe a descricao da categoria';
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
          ('UPDATE TAB_CATEGORIA SET descricao = :descricao, icone = :icone,');
        qry.sql.Add('indiceIcone = :indiceIcone');
        qry.sql.Add('WHERE idCategoria = :idCategoria');
        qry.ParamByName('descricao').AsString := descricao;
        qry.ParamByName('icone').Assign(icone);
        qry.ParamByName('idCategoria').AsInteger := idCategoria;
        qry.ParamByName('indiceIcone').AsInteger := indiceIcone;
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

function TCategoria.Excluir(out erro: String): Boolean;
var
  qry: TFDQuery;
begin
  if idCategoria <= 0 then
  begin
    erro := 'informe o ID da categoria';
    Result := false;
    exit;
  end;
  try
    qry := TFDQuery.Create(nil);
    qry.Connection := Fconn;
    Fconn.StartTransaction;
    try
      begin
        // Validar se a categoria possui lançamentos
        qry.Close;
        qry.sql.Clear;
        qry.sql.Add('SELECT * FROM TAB_LANCAMENTO');
        qry.sql.Add('WHERE idCategoria = :idCategoria');
        qry.ParamByName('idCategoria').AsInteger := idCategoria;
        qry.Open;

        if qry.RecordCount > 0 then
        begin
          Result := false;
          erro := 'A categoria possui lançamentos e não pode ser excluida';
          exit;
        end;

        qry.Close;
        qry.sql.Clear;
        qry.sql.Add('DELETE FROM TAB_CATEGORIA');
        qry.sql.Add('WHERE idCategoria = :idCategoria');
        qry.ParamByName('idCategoria').AsInteger := idCategoria;
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

function TCategoria.ListarCategoria(out erro: String): TFDQuery;
var
  qry: TFDQuery;
begin
  qry := TFDQuery.Create(nil);
  qry.Connection := Fconn;
  try

    begin
      qry.Active := false;
      qry.sql.Clear;
      qry.sql.Add('SELECT * FROM TAB_CATEGORIA');
      qry.sql.Add('WHERE 1 = 1');

      if idCategoria > 0 then
      begin
        qry.sql.Add('AND idCategoria = :idCategoria');
        qry.ParamByName('idCategoria').AsInteger := idCategoria;
      end;
      qry.Active := true;
    end;
    Result := qry;
    erro := '';

  except
    on ex: Exception do
    begin
      Result := nil;
      erro := 'Erro ao consultar categorias: ' + ex.Message;
    end;

  end;
end;

end.
