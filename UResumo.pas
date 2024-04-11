unit UResumo;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects,
  FMX.Layouts, FireDAC.Comp.Client, FireDAC.DApt, data.DB, cCategoria, DateUtils;

type
  TFrmResumo = class(TForm)
    LayBotaoMes: TLayout;
    ImgMesSelecao: TImage;
    LblMesSelecao: TLabel;
    LayBotaoVoltarLancamentos: TLayout;
    LblTituloLancamentos: TLabel;
    ImgVoltarLancamentos: TImage;
    ListVResumos: TListView;
    ImgCategoria: TImage;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ImgVoltarLancamentosClick(Sender: TObject);
  private

    procedure MontarResumo;
    procedure AddCategoria(ListView: TListView; categoria: String; valor: Double;
      foto: TStream);
    { Private declarations }
  public
    { Public declarations }
    dtFiltro : TDate;
  end;

var
  FrmResumo: TFrmResumo;

implementation

{$R *.fmx}

uses UPrincipal, UDataModule, cLancamento;

procedure TFrmResumo.AddCategoria(ListView: TListView;
  categoria: String; valor: Double; foto: TStream);
var
  txt: TListItemText;
  img: TListItemImage;
  bmp: TBitmap;
begin
  with ListView.Items.Add do
  begin
    // Informações para listViwer
    txt := TListItemText(Objects.FindDrawable('TxtCategoria'));
    txt.Text := categoria;

    txt := TListItemText(Objects.FindDrawable('TxtValor'));
    txt.Text := FormatFloat('#,##0.00', valor);


    // Icone da listViwer
    img := TListItemImage(Objects.FindDrawable('ImgResumoViwer'));
    if foto <> nil then
    begin
      bmp := TBitmap.Create;
      bmp.LoadFromStream(foto);
      img.OwnsBitmap := True;
      img.Bitmap := bmp;
    end;
  end;
end;

procedure TFrmResumo.MontarResumo;
var
  lancamento : TLancamento;
  qry : TFDQuery;
  erro : string;
  icone : TStream;

begin
  try
    ListVResumos.Items.Clear;
    lancamento := TLancamento.Create(dm.conn);
    lancamento.dataDe := FormatDateTime('YYYY-MM-DD', StartOfTheMonth(dtFiltro));
    lancamento.dataAte := FormatDateTime('YYYY-MM-DD', EndOfTheMonth(dtFiltro));
    qry := lancamento.ListarResumo(erro);
    while Not qry.Eof do
    begin
      //Convertendo o Icone para Grava no Banco

      if qry.FieldByName('icone').AsString <> '' then
        icone := qry.CreateBlobStream(qry.FieldByName('icone'), TBlobStreamMode.bmRead)
      else
        icone := nil;

      FrmResumo.AddCategoria(ListVResumos,
                                  qry.FieldByName('descricao').AsString,
                                  qry.FieldByName('valor').AsCurrency,
                                  icone);
      if icone <> nil then
        icone.DisposeOf;
      qry.Next;
    end;

  finally
    qry.DisposeOf;
    lancamento.DisposeOf;

  end;

end;

procedure TFrmResumo.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  FrmResumo := nil;
end;

procedure TFrmResumo.FormShow(Sender: TObject);
begin
 MontarResumo;
end;

procedure TFrmResumo.ImgVoltarLancamentosClick(Sender: TObject);
begin
  Close;
end;

end.
