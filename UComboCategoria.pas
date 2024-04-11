unit UComboCategoria;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  FireDAC.Comp.Client, FireDAC.DApt, Data.DB;

type
  TFrmComboCategoria = class(TForm)
    LayComboCategoria: TLayout;
    LblTituloComboCategoria: TLabel;
    ImgVoltarComboCategoria: TImage;
    ListVComboCategorias: TListView;
    procedure ImgVoltarComboCategoriaClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListVComboCategoriasItemClick(const Sender: TObject;
      const AItem: TListViewItem);
  private
    procedure listarCategoria;
    { Private declarations }
  public
    { Public declarations }
    CategoriaSelecao :String;
    IdCategoriaSelecao :Integer;
  end;

var
  FrmComboCategoria: TFrmComboCategoria;

implementation

{$R *.fmx}

uses UPrincipal, cCategoria, UDataModule;

procedure TFrmComboCategoria.listarCategoria;
var
  categoria : TCategoria;
  qry : TFDQuery;
  erro : string;
  icone : TStream;

begin
  try
    ListVComboCategorias.Items.Clear;
    Categoria := TCategoria.Create(dm.conn);
    qry := categoria.ListarCategoria(erro);
    while Not qry.Eof do
    begin
      //Convertendo o Icone para Grava no Banco

      if qry.FieldByName('icone').AsString <> '' then
        icone := qry.CreateBlobStream(qry.FieldByName('icone'), TBlobStreamMode.bmRead)
      else
        icone := nil;

      FrmPrincipal.AddCategoria(FrmComboCategoria.ListVComboCategorias,
                                  qry.FieldByName('idCategoria').AsString,
                                  qry.FieldByName('descricao').AsString,
                                  icone);
      if icone <> nil then
        icone.DisposeOf;
      qry.Next;
    end;

  finally
    qry.DisposeOf;
    categoria.DisposeOf;

  end;

end;


procedure TFrmComboCategoria.ListVComboCategoriasItemClick(
  const Sender: TObject; const AItem: TListViewItem);
begin
  IdCategoriaSelecao := AItem.TagString.ToInteger;
  CategoriaSelecao := TListItemText(AItem.Objects.FindDrawable('TxtCategoria')).Text;
  Close;
end;

procedure TFrmComboCategoria.FormShow(Sender: TObject);
begin
  listarCategoria;
end;

procedure TFrmComboCategoria.ImgVoltarComboCategoriaClick(Sender: TObject);
begin
  IdCategoriaSelecao := 0;
  CategoriaSelecao := '';
  Close;
end;

end.
