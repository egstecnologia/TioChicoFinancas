unit ULancamentos;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  FireDAC.Comp.Client, FireDAC.DApt, data.DB, DateUtils;

type
  TFrmLancamentos = class(TForm)
    LayBotaoVoltarLancamentos: TLayout;
    LblTituloLancamentos: TLabel;
    ImgVoltarLancamentos: TImage;
    LayBotaoMes: TLayout;
    ImgVoltar: TImage;
    ImgAvancar: TImage;
    ImgMesSelecao: TImage;
    LblMesSelecao: TLabel;
    RectRodapeLancamentos: TRectangle;
    LayRodapelancamentos: TLayout;
    ImgRodapeBotaoAdd: TImage;
    LblIndicadorValorReceitas: TLabel;
    LblindicadorReceitas: TLabel;
    LblIndicadorValorDespesas: TLabel;
    LblindicadorDespesas: TLabel;
    LblIndicadorValorSaldo: TLabel;
    LblindicadorSaldo: TLabel;
    ListVLancamentos: TListView;
    ImgCategoria: TImage;
    ImgResumo: TImage;
    procedure ImgVoltarLancamentosClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure ListVLancamentosUpdateObjects(const Sender: TObject;
      const AItem: TListViewItem);
    procedure ListVLancamentosItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure ImgRodapeBotaoAddClick(Sender: TObject);
    procedure ImgAvancarClick(Sender: TObject);
    procedure ImgVoltarClick(Sender: TObject);
    procedure ImgResumoClick(Sender: TObject);
  private
    procedure AbrirLancamento(idLancamento: string);
    procedure ListarLancamentos;
    procedure NavegarMes(numMes: integer);
    function NomeMes: string;
    { Private declarations }
  public
    { Public declarations }
    dtFiltro : TDate;
  end;

var
  FrmLancamentos: TFrmLancamentos;

implementation

{$R *.fmx}

uses UPrincipal, ULancamentosCadastro, cLancamento, UDataModule, UResumo;

procedure TFrmLancamentos.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//  Action := TCloseAction.caFree;
//  FrmLancamentos := nil; // Estamos Destruindo no Form Principal
end;

function TFrmLancamentos.NomeMes(): string;
begin
    case MonthOf(dtFiltro) of
        1: Result := 'Janeiro';
        2: Result := 'Fevereiro';
        3: Result := 'Março';
        4: Result := 'Abril';
        5: Result := 'Maio';
        6: Result := 'Junho';
        7: Result := 'Julho';
        8: Result := 'Agosto';
        9: Result := 'Setembro';
        10: Result := 'Outubro';
        11: Result := 'Novembro';
        12: Result := 'Dezembro';
    end;

    Result := Result + ' / ' + YearOf(dtFiltro).ToString;

end;

procedure TFrmLancamentos.ListarLancamentos;
var
  lancamento: TLancamento;
  qry: TFDQuery;
  erro: string;
  foto: TStream;
  vlReceita, vlDespesa :Double;

  begin
     try
      FrmLancamentos.ListVLancamentos.Items.Clear;
        vlReceita := 0;
        vlDespesa := 0;
        lancamento := TLancamento.Create(dm.conn);
        lancamento.dataDe := FormatDateTime('YYYY-MM-DD', StartOfTheMonth(dtFiltro));
        lancamento.dataAte := FormatDateTime('YYYY-MM-DD', EndOfTheMonth(dtFiltro));

        qry := lancamento.ListarLancamento(0, erro);
      if erro <> '' then
      begin
        ShowMessage(erro);
        exit
      end;

      while Not qry.Eof do
      begin

        if qry.FieldByName('icone').AsString <> '' then
           foto := qry.CreateBlobStream(qry.FieldByName('icone'), TBlobStreamMode.bmRead)
        else
          foto := nil;

        FrmPrincipal.AddLancamento(FrmLancamentos.ListVLancamentos,
          qry.FieldByName('idLancamento').AsString,
          qry.FieldByName('descricao').AsString,
          qry.FieldByName('descricaoCategoria').AsString,
          qry.FieldByName('valor').AsCurrency,
          qry.FieldByName('data').AsDateTime,
          foto);

          if   qry.FieldByName('valor').AsFloat > 0 then
            vlReceita:= vlReceita + qry.FieldByName('valor').AsCurrency
          else
            vlDespesa:= vlDespesa + qry.FieldByName('valor').AsCurrency;

        qry.Next;
        foto.DisposeOf;
      end;

    finally
      lancamento.DisposeOf;
    end;
    LblIndicadorValorReceitas.Text := FormatFloat('#,##0.00', vlReceita);
    LblIndicadorValorDespesas.Text := FormatFloat('#,##0.00', vlDespesa);
    LblIndicadorValorSaldo.Text := FormatFloat('#,##0.00', vlReceita + vlDespesa);
end;

procedure TFrmLancamentos.NavegarMes(numMes: integer);
begin
    dtFiltro:=  IncMonth(dtFiltro, numMes);
    LblMesSelecao.Text := NomeMes;
    ListarLancamentos;

end;

procedure TFrmLancamentos.FormShow(Sender: TObject);

begin
  dtFiltro := Date;
  NavegarMes(0);
end;

procedure TFrmLancamentos.ImgAvancarClick(Sender: TObject);
begin
  NavegarMes(1);
end;

procedure TFrmLancamentos.ImgResumoClick(Sender: TObject);
begin
  if NOT Assigned(FrmResumo) then
    Application.CreateForm(TFrmResumo, FrmResumo);

  FrmResumo.LblMesSelecao.Text := FrmLancamentos.LblMesSelecao.Text;
  FrmResumo.dtFiltro := FrmLancamentos.dtFiltro;
  FrmResumo.Show;


end;

procedure TFrmLancamentos.ImgRodapeBotaoAddClick(Sender: TObject);
begin
  AbrirLancamento('');
end;

procedure TFrmLancamentos.ImgVoltarClick(Sender: TObject);
begin
  NavegarMes(-1);
end;

procedure TFrmLancamentos.ImgVoltarLancamentosClick(Sender: TObject);
begin
  close;
end;

procedure TFrmLancamentos.AbrirLancamento(idLancamento: string);
begin
  if Not Assigned(FrmLancamentosCadastro) then
    Application.CreateForm(TFrmLancamentosCadastro, FrmLancamentosCadastro);

    if idLancamento <> '' then
      begin
        FrmLancamentosCadastro.modo := 'A';
        FrmLancamentosCadastro.idLancamento := idLancamento.ToInteger;
      end
    else
      begin
        FrmLancamentosCadastro.modo := 'I';
        FrmLancamentosCadastro.idLancamento := 0;
      end;


    FrmLancamentosCadastro.ShowModal(procedure (ModalResult: TModalResult)
    begin
      ListarLancamentos;
    end);


end;

procedure TFrmLancamentos.ListVLancamentosItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
  AbrirLancamento(AItem.TagString);
end;

procedure TFrmLancamentos.ListVLancamentosUpdateObjects(const Sender: TObject;
  const AItem: TListViewItem);
begin
  FrmPrincipal.SetupLancamento(FrmLancamentos.ListVLancamentos, AItem);
end;

end.
