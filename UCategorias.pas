unit UCategorias;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  FireDAC.Comp.Client, FireDAC.DApt, Data.DB;

type
  TFrmCategorias = class(TForm)
    LayBotaoCategorias: TLayout;
    LblTituloCategoria: TLabel;
    ImgBotaoVoltarCategoria: TImage;
    RectRodapeCategorias: TRectangle;
    ImgRodapeCategoria: TImage;
    LblRodapeCategoria: TLabel;
    ListVCategorias: TListView;
    procedure ImgBotaoVoltarCategoriaClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure ListVCategoriasUpdateObjects(const Sender: TObject;
      const AItem: TListViewItem);
    procedure ImgRodapeCategoriaClick(Sender: TObject);
    procedure ListVCategoriasItemClick(const Sender: TObject;
      const AItem: TListViewItem);
  private

    { Private declarations }
  public
    { Public declarations }
    procedure CadastroCatedorias(idCategoria: string);
    procedure listarCategoria;
  end;

var
  FrmCategorias: TFrmCategorias;

implementation

{$R *.fmx}

uses UPrincipal, UCategoriasCadastro, cCategoria, UDataModule;

procedure TFrmCategorias.listarCategoria;
var
  categoria : TCategoria;
  qry : TFDQuery;
  erro : string;
  icone : TStream;

begin
  try
    ListVCategorias.Items.Clear;
    categoria := TCategoria.Create(dm.conn);
    qry := categoria.ListarCategoria(erro);
    while Not qry.Eof do
    begin
      //Convertendo o Icone para Grava no Banco

      if qry.FieldByName('icone').AsString <> '' then
        icone := qry.CreateBlobStream(qry.FieldByName('icone'), TBlobStreamMode.bmRead)
      else
        icone := nil;

      FrmPrincipal.AddCategoria(ListVCategorias,
                                  qry.FieldByName('idCategoria').AsString,
                                  qry.FieldByName('descricao').AsString,
                                  icone);
      if icone <> nil then
        icone.DisposeOf;
      qry.Next;
    end;
    LblRodapeCategoria.Text := ListVCategorias.Items.Count.ToString + ' categoria(s)';
  finally
    qry.DisposeOf;
    categoria.DisposeOf;

  end;

end;

procedure TFrmCategorias.CadastroCatedorias(idCategoria: string);
begin
  if not Assigned(FrmCategoriasCadastro) then
    Application.CreateForm(TFrmCategoriasCadastro, FrmCategoriasCadastro);

  //Inclusão
  if idCategoria = '' then
    begin
      FrmCategoriasCadastro.idCadastro := 0;
      FrmCategoriasCadastro.modo := 'I';
      FrmCategoriasCadastro.LblTituloCadCategoria.text := 'Nova Categoria'
    end
  else

    //Alteração
    begin
      FrmCategoriasCadastro.idCadastro := idCategoria.ToInteger;
      FrmCategoriasCadastro.modo := 'A';
      FrmCategoriasCadastro.LblTituloCadCategoria.text := 'Editar Categoria';
    end;
    FrmCategoriasCadastro.Show;
end;

procedure TFrmCategorias.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  FrmCategorias := nil;
end;

procedure TFrmCategorias.FormShow(Sender: TObject);
begin
  listarCategoria;
end;

procedure TFrmCategorias.ImgBotaoVoltarCategoriaClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmCategorias.ImgRodapeCategoriaClick(Sender: TObject);
begin
  CadastroCatedorias('');
end;

procedure TFrmCategorias.ListVCategoriasItemClick(const Sender: TObject; const AItem: TListViewItem);
begin
  CadastroCatedorias(AItem.TagString);
end;

procedure TFrmCategorias.ListVCategoriasUpdateObjects(const Sender: TObject;
  const AItem: TListViewItem);
begin
  FrmPrincipal.SetupCategoria(ListVCategorias, AItem);
end;

end.
