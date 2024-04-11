unit ULancamentosCadastro;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Edit,
  FMX.DateTimeCtrls, FMX.ListBox, FireDAC.Comp.Client, FireDAC.DApt, uFormat,
  FMX.DialogService;

type
  TFrmLancamentosCadastro = class(TForm)
    LayBotaoLancamentosCadastro: TLayout;
    LblTituloLancamentosCadastro: TLabel;
    ImgVoltarLancamentosCadastro: TImage;
    ImgSalvaLancamentoCadastro: TImage;
    LayDescricaoLancamentosCadastro: TLayout;
    LblDescricaoLancamentosCadastro: TLabel;
    EdtDescricaoLancamentosCadastro: TEdit;
    LineDescricao: TLine;
    LayDataLancamentosCadastro: TLayout;
    LblDataLancamentosCadastro: TLabel;
    LineDataLancamentosCadastro: TLine;
    LayCategoriaLancamentosCadastro: TLayout;
    LblCategoriaLancamentosCadastro: TLabel;
    LayValorLancamentosCadastro: TLayout;
    LblValorLancamentosCadastro: TLabel;
    EdtValorLancamentosCadastro: TEdit;
    LineValorLancamentosCadastro: TLine;
    EdtDDataLancamentosCadastro: TDateEdit;
    ImgBtnHoje: TImage;
    ImgBtnOntem: TImage;
    RectRodapeLancamentosCadastro: TRectangle;
    ImgRodapeBotaoDel: TImage;
    imgTipoLancamento: TImage;
    imgDespesa: TImage;
    imgReceita: TImage;
    LblCategoria: TLabel;
    ImgCategoria: TImage;
    LineCategoria: TLine;
    procedure ImgVoltarLancamentosCadastroClick(Sender: TObject);
    procedure imgTipoLancamentoClick(Sender: TObject);
    procedure ImgBtnHojeClick(Sender: TObject);
    procedure ImgBtnOntemClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ImgSalvaLancamentoCadastroClick(Sender: TObject);
    procedure EdtValorLancamentosCadastroEnter(Sender: TObject);
    procedure EdtValorLancamentosCadastroExit(Sender: TObject);
    procedure ImgRodapeBotaoDelClick(Sender: TObject);
    procedure LblCategoriaClick(Sender: TObject);
  private
    procedure ComboCategoria;
    { Private declarations }
  public
    { Public declarations }
    modo: string; // I Inclusão ou A Alteração
    idLancamento: Integer;
  end;

var
  FrmLancamentosCadastro: TFrmLancamentosCadastro;

implementation

{$R *.fmx}

uses UPrincipal, UDataModule, cCategoria, cLancamento, UComboCategoria;

{$IFDEF AUTOREFCOUNT}
constructor TIntegerWrapper.Create(AValue: Integer);
begin
  inherited Create;
  Value := AValue;
end;
{$ENDIF}


procedure TFrmLancamentosCadastro.ComboCategoria;
var
  c: TCategoria;
  erro: string;
  qry: TFDQuery;
begin
    try
      //cmbCategoria.Items.Clear;
      c := TCategoria.Create(dm.conn);
      qry:= c.ListarCategoria(erro);

      if erro <> '' then
      begin
        ShowMessage(erro);
        exit
      end;

      while NOT qry.Eof do
      begin
//        cmbCategoria.Items.AddObject(qry.FieldByName('descricao').AsString,
//          TObject(qry.FieldByName('idCategoria').AsInteger));
//            cmbCategoria.Items.AddObject(qry.FieldByName('descricao').AsString,
//            {$IFDEF AUTOREFCOUT}
//              Tintege

        qry.Next;
      end;

    finally
      qry.DisposeOf;
      c.DisposeOf
    end;

end;

procedure TFrmLancamentosCadastro.EdtValorLancamentosCadastroEnter(
  Sender: TObject);
begin
  ResetFormat(EdtValorLancamentosCadastro);
end;

procedure TFrmLancamentosCadastro.EdtValorLancamentosCadastroExit(
  Sender: TObject);
begin
  Formatar(EdtValorLancamentosCadastro, TFormato.Valor);
end;

procedure TFrmLancamentosCadastro.FormShow(Sender: TObject);
var
  lancamento: TLancamento;
  qry: TFDQuery;
  erro: string;

begin
  //ComboCategoria;
    if modo = 'I' then
    begin
      EdtDescricaoLancamentosCadastro.Text := '';
      EdtDDataLancamentosCadastro.Date := date;
      EdtValorLancamentosCadastro.Text := '';
      imgTipoLancamento.Bitmap := imgDespesa.Bitmap;
      imgTipoLancamento.Tag := -1;
      RectRodapeLancamentosCadastro.Visible := false;
      LblCategoria.Text := '';
      LblCategoria.Tag := 0;
    end
    else
    begin
      try
        lancamento := TLancamento.Create(dm.conn);
        lancamento.idLancamento := idLancamento;
        qry := lancamento.ListarLancamento(0, erro);

        if qry.RecordCount = 0 then
        begin
          ShowMessage('Lançamento não encontrado');
          exit
        end;

        EdtDescricaoLancamentosCadastro.Text := qry.FieldByName('descricao').AsString;
        EdtDDataLancamentosCadastro.Date := qry.FieldByName('data').AsDateTime;

        if qry.FieldByName('valor').AsFloat < 0 then
        begin
          //Tratamento Para saver que o calor é despesa
          EdtValorLancamentosCadastro.Text := FormatFloat('#,##0.00', qry.FieldByName('valor').AsFloat * -1);
          imgTipoLancamento.Bitmap := imgDespesa.Bitmap;
          imgTipoLancamento.Tag := -1;
        end
        else
        begin
          //Tratamento Para saver que o calor é despesa
          EdtValorLancamentosCadastro.Text := FormatFloat('#,##0.00', qry.FieldByName('valor').AsFloat);
          imgTipoLancamento.Bitmap := imgReceita.Bitmap;
          imgTipoLancamento.Tag := 1;
        end;

        LblCategoria.Text := qry.FieldByName('descricaoCategoria').AsString;
        LblCategoria.Tag := qry.FieldByName('idCategoria').AsInteger;


        //{$IFDEF AUTOREFCOUNT}
        //lanc.ID_CATEGORIA := TIntegerWrapper(cmb_categoria.Items.Objects[cmb_categoria.ItemIndex]).Value;
        //{$ELSE}
        //lanc.ID_CATEGORIA := Integer(cmb_categoria.Items.Objects[cmb_categoria.ItemIndex]);
        //{$ENDIF}
      finally
        qry.DisposeOf;
        lancamento.DisposeOf;
      end;

    end;
end;

procedure TFrmLancamentosCadastro.ImgBtnHojeClick(Sender: TObject);
begin
  EdtDDataLancamentosCadastro.Date := Date;
end;

procedure TFrmLancamentosCadastro.ImgBtnOntemClick(Sender: TObject);
begin
  EdtDDataLancamentosCadastro.Date := Date -1;
end;

procedure TFrmLancamentosCadastro.ImgRodapeBotaoDelClick(Sender: TObject);
var
  lancamento : TLancamento;
  erro : string;
begin

  TDialogService.MessageDialog('Confirma a exclusão do lançamento?',
      TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
      TMsgDlgBtn.mbNo,
      0,
      procedure (const AResult: TModalResult)
      var
        erro: string;
      begin
        if AResult = mrYes then
        begin
            try
              lancamento := TLancamento.Create(dm.conn);
              lancamento.idLancamento := idLancamento;

              if NOT lancamento.Excluir(erro) then
              begin
                ShowMessage(erro);
                exit
              end;

              Close;
            finally
              lancamento.DisposeOf;
            end;
        end;
      end
      );
end;

function TrataValor(str: string): Double;
begin
  //Tratar os pontos dos valores e virgulas dos valores
  //exemplo 2.250,90
  str := StringReplace(str, '.', '', [rfReplaceAll]); //2250,90
  str := StringReplace(str, ',', '', [rfReplaceAll]); //225090
  try
    Result := StrToFloat(str) / 100;
  except
    Result :=0;
  end;
end;

procedure TFrmLancamentosCadastro.ImgSalvaLancamentoCadastroClick(
  Sender: TObject);
var
  lancamento: TLancamento;
  erro: string;

begin
    try
        lancamento := TLancamento.Create(dm.conn);
        lancamento.descricao := EdtDescricaoLancamentosCadastro.Text;
        lancamento.valor := TrataValor(EdtValorLancamentosCadastro.Text) * imgTipoLancamento.Tag;
    //    lancamento.idCategoria := Integer(cmbCategoria.Items.Objects[cmbCategoria.ItemIndex]);
        lancamento.data := EdtDDataLancamentosCadastro.Date;
        lancamento.idCategoria := LblCategoria.Tag;

      if modo = 'I' then
        lancamento.Inserir(erro)
        else
        begin
          lancamento.idLancamento := idLancamento;
          lancamento.Alterar(erro)
        end;

      if erro <> '' then
        begin
          ShowMessage(erro);
          exit
        end;
      close;

    finally
        lancamento.DisposeOf;
    end;


end;

procedure TFrmLancamentosCadastro.imgTipoLancamentoClick(Sender: TObject);
begin
  if imgTipoLancamento.Tag = 1 then
    begin
      imgTipoLancamento.Bitmap := imgDespesa.Bitmap;
      imgTipoLancamento.Tag := -1;
    end
  else
    begin
      imgTipoLancamento.Bitmap := imgReceita.Bitmap;
      imgTipoLancamento.Tag := 1;
    end;
end;

procedure TFrmLancamentosCadastro.ImgVoltarLancamentosCadastroClick(
  Sender: TObject);
begin
  Close;
end;

procedure TFrmLancamentosCadastro.LblCategoriaClick(Sender: TObject);
begin
  // Abre listagens de categorias

  if NOT Assigned(FrmComboCategoria) then
    Application.CreateForm(TFrmComboCategoria, FrmComboCategoria);

  FrmComboCategoria.ShowModal(procedure(ModalResult: TModalResult)
  begin
    if FrmComboCategoria.IdCategoriaSelecao > 0 then
      begin
        LblCategoria.Text := FrmComboCategoria.CategoriaSelecao;
        LblCategoria.Tag := FrmComboCategoria.IdCategoriaSelecao;
      end;

  end);

   if NOT Assigned(FrmComboCategoria) then
        Application.CreateForm(TFrmComboCategoria, FrmComboCategoria);

end;

end.
