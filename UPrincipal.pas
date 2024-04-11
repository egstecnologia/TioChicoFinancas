unit UPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView, FMX.Ani,
  FireDAC.Comp.Client, FireDAC.DApt, data.DB, DateUtils;

type
  TFrmPrincipal = class(TForm)
    LayTopMenuPrincipal: TLayout;
    ImgBotaoMenu: TImage;
    CircleFoto: TCircle;
    ImgNotificacao: TImage;
    LblTituloPrincipal: TLabel;
    LayIndicadoresRD: TLayout;
    LayIndicadores: TLayout;
    LayIndicadorReceitas: TLayout;
    ImgIndicadorReceitas: TImage;
    LblIndicadorValorReceitas: TLabel;
    LblindicadorReceitas: TLabel;
    LayIndicadorDespesas: TLayout;
    ImgIndicadorDespesas: TImage;
    LblIndicadorValorDespesas: TLabel;
    LblIndicadorDespesas: TLabel;
    LayBotaoAdicionar: TLayout;
    RectBotaoAdicionar: TRectangle;
    ImgBotaoAdicionar: TImage;
    RectInformacao: TRectangle;
    LayRectLancamentos: TLayout;
    LblLancamentos: TLabel;
    LblVerTodos: TLabel;
    ListVLancamentos: TListView;
    ImgCategoria: TImage;
    StyleBook1: TStyleBook;
    LayMenuPrincipal: TLayout;
    RectMenuPrincinpal: TRectangle;
    FloatAnMenuPrincinpal: TFloatAnimation;
    ImgFechaAnimacao: TImage;
    LayMenuCategoria: TLayout;
    LblMenuCategoria: TLabel;
    LayMenulogoff: TLayout;
    LblMenuSair: TLabel;
    LaySaldoAtual: TLayout;
    LblSaldoAtual: TLabel;
    LblValorSaldo: TLabel;
    procedure FormShow(Sender: TObject);
    procedure LblVerTodosClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListVLancamentosUpdateObjects(const Sender: TObject;
      const AItem: TListViewItem);
    procedure ImgBotaoMenuClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FloatAnMenuPrincinpalFinish(Sender: TObject);
    procedure FloatAnMenuPrincinpalProcess(Sender: TObject);
    procedure ImgFechaAnimacaoClick(Sender: TObject);
    procedure LayMenuCategoriaClick(Sender: TObject);
    procedure ListVLancamentosItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure ListVLancamentosItemClickEx(const Sender: TObject;
      ItemIndex: Integer; const LocalClickPos: TPointF;
      const ItemObject: TListItemDrawable);
    procedure ListVLancamentosPaint(Sender: TObject; Canvas: TCanvas;
      const ARect: TRectF);
    procedure ImgBotaoAdicionarClick(Sender: TObject);
    procedure LayMenulogoffClick(Sender: TObject);
  private
    procedure ListarUltLancamentos;
    procedure MontaPainel;
    procedure CarregaIcone;
    { Private declarations }
  public
    { Public declarations }
    procedure AddLancamento(ListView: TListView;
      idLancamento, descricao, categoria: String; valor: double; dt: TDateTime;
      foto: TStream);
    procedure SetupLancamento(lv: TListView; Item: TListViewItem);
    procedure AddCategoria(ListView: TListView; idCategoria, categoria: String;
      foto: TStream);
    procedure SetupCategoria(lv: TListView; Item: TListViewItem);
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

uses ULancamentos, UCategorias, cLancamento, UDataModule, ULancamentosCadastro,
  cUsuario, ULogin;


// -----------------Pra uma Unit de Funçoes -----------------------

procedure TFrmPrincipal.AddLancamento(ListView: TListView;
  idLancamento, descricao, categoria: String; valor: double; dt: TDateTime;
  foto: TStream);
var
  img: TListItemImage;
  bmp: TBitmap;
begin
  with ListView.Items.Add do
  begin
    TagString := idLancamento;

    // Informações para listViwer
    TListItemText(Objects.FindDrawable('TxtDescricao')).Text := descricao;
    TListItemText(Objects.FindDrawable('TxtCategoria')).Text := categoria;
    TListItemText(Objects.FindDrawable('TxtValor')).Text := FormatFloat('#,##0.00', valor);
    TListItemText(Objects.FindDrawable('TxtData')).Text :=  FormatDateTime('dd/mm', dt);

    // Icone da listViwer
    img := TListItemImage(Objects.FindDrawable('ImgCategoriaListViwer'));
    if foto <> nil then
    begin
      bmp := TBitmap.Create;
      bmp.LoadFromStream(foto);
      img.OwnsBitmap := True;
      img.Bitmap := bmp;
    end;

  end;
end;

procedure TFrmPrincipal.CarregaIcone;
var
  u : TUsuario;
  qry: TFDQuery;
  erro: string;
  foto: TStream;
begin
  try
    u:= TUsuario.Create(dm.conn);
    qry:= u.ListarUsuario(erro);

    if qry.FieldByName('foto').AsString <> '' then
      foto := qry.CreateBlobStream(qry.FieldByName('foto'), TBlobStreamMode.bmRead)
    else
      foto := nil;

    if foto <> nil then
    begin
      CircleFoto.Fill.Bitmap.Bitmap.LoadFromStream(foto);
      foto.DisposeOf;
    end;


  finally
    qry.DisposeOf;
    u.DisposeOf;

  end;

end;


procedure TFrmPrincipal.MontaPainel;
var
  lancamento :TLancamento;
  qry :TFDQuery;
  erro : string;
  vlReceita, vlDespesa : Double;

begin
  try
    lancamento := TLancamento.Create(dm.conn);
    lancamento.dataDe := FormatDateTime('yyyy-mm-dd', StartOfTheMonth(date));
    lancamento.dataAte := FormatDateTime('yyyy-mm-dd', EndOfTheMonth(date));
    qry := lancamento.ListarLancamento(0, erro);

    if erro <> '' then
    begin
      ShowMessage(erro);
      exit;
    end;

    vlReceita := 0;
    vlDespesa := 0;

    while NOT qry.Eof do
    begin
        if   qry.FieldByName('valor').AsFloat > 0 then
            vlReceita:= vlReceita + qry.FieldByName('valor').AsFloat
          else
            vlDespesa:= vlDespesa + qry.FieldByName('valor').AsFloat;

    qry.Next
    end;

      LblIndicadorValorReceitas.Text := FormatFloat('#,##0.00', vlReceita);
      LblIndicadorValorDespesas.Text := FormatFloat('#,##0.00', vlDespesa);
      LblValorSaldo.Text := FormatFloat('#,##0.00', vlReceita + vlDespesa);
  finally
    qry.DisposeOf;
    lancamento.DisposeOf;
  end;

end;

procedure TFrmPrincipal.AddCategoria(ListView: TListView;
  idCategoria, categoria: String; foto: TStream);
var
  txt: TListItemText;
  img: TListItemImage;
  bmp: TBitmap;
begin
  with ListView.Items.Add do
  begin
    TagString := idCategoria;

    // Informações para listViwer
    txt := TListItemText(Objects.FindDrawable('TxtCategoria'));
    txt.Text := categoria;

    // Icone da listViwer
    img := TListItemImage(Objects.FindDrawable('ImgCategoriaListViwer'));
    if foto <> nil then
    begin
      bmp := TBitmap.Create;
      bmp.LoadFromStream(foto);
      img.OwnsBitmap := True;
      img.Bitmap := bmp;
    end;
  end;
end;

procedure TFrmPrincipal.SetupLancamento(lv: TListView; Item: TListViewItem);
var
  txt: TListItemText;
begin
  txt := TListItemText(Item.Objects.FindDrawable('TxtDescricao'));
  txt.Width := lv.Width - txt.PlaceOffset.X - 100;
end;

procedure TFrmPrincipal.SetupCategoria(lv: TListView; Item: TListViewItem);
var
  txt: TListItemText;
begin
  txt := TListItemText(Item.Objects.FindDrawable('TxtCategoria'));
  txt.Width := lv.Width - txt.PlaceOffset.X - 20;
end;

// -------------------------------------------------------------------------------------

{$R *.fmx}

procedure TFrmPrincipal.FloatAnMenuPrincinpalFinish(Sender: TObject);
begin
  LayMenuPrincipal.Enabled := FloatAnMenuPrincinpal.Inverse;
  FloatAnMenuPrincinpal.Inverse := NOT FloatAnMenuPrincinpal.Inverse;
end;

procedure TFrmPrincipal.FloatAnMenuPrincinpalProcess(Sender: TObject);
begin
  LayMenuPrincipal.Margins.Right := -260 - RectMenuPrincinpal.Margins.Left;
end;

procedure TFrmPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(FrmLancamentos) then
  begin
    FrmLancamentos.DisposeOf;
    FrmLancamentos := nil;
  end;
  Action := TCloseAction.caFree;
  FrmPrincipal := nil;
end;

procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
  RectMenuPrincinpal.Margins.Left := -260;
  RectMenuPrincinpal.Align := TAlignLayout.Left;
  RectMenuPrincinpal.Visible := True;
end;

procedure TFrmPrincipal.ListarUltLancamentos;
var
//  X: Integer;
  lancamento: TLancamento;
  qry: TFDQuery;
  erro: string;
  foto: TStream;
begin
  try
    FrmPrincipal.ListVLancamentos.Items.Clear;
    lancamento := TLancamento.Create(dm.conn);

    qry := lancamento.ListarLancamento(10, erro);
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

      AddLancamento(FrmPrincipal.ListVLancamentos,
        qry.FieldByName('idLancamento').AsString,
        qry.FieldByName('descricao').AsString,
        qry.FieldByName('descricaoCategoria').AsString,
        qry.FieldByName('valor').AsFloat,
        qry.FieldByName('data').AsDateTime,
        foto);
      qry.Next;
      foto.DisposeOf;
    end;

  finally
    lancamento.DisposeOf;
  end;
    MontaPainel;
end;

procedure TFrmPrincipal.FormShow(Sender: TObject);
begin
  ListarUltLancamentos;
  CarregaIcone;
end;

procedure TFrmPrincipal.ImgBotaoAdicionarClick(Sender: TObject);
begin
  if NOT Assigned(FrmLancamentosCadastro) then
    Application.CreateForm(TFrmLancamentosCadastro, FrmLancamentosCadastro);

    FrmLancamentosCadastro.modo := 'I';
    FrmLancamentosCadastro.idLancamento := 0;
    FrmLancamentosCadastro.ShowModal (procedure (ModalResult: TModalResult)
    begin
      ListarUltLancamentos
    end);
end;

procedure TFrmPrincipal.ImgBotaoMenuClick(Sender: TObject);
begin
  FloatAnMenuPrincinpal.Start;
end;

procedure TFrmPrincipal.ImgFechaAnimacaoClick(Sender: TObject);
begin
  FloatAnMenuPrincinpal.Start;
end;

procedure TFrmPrincipal.LayMenuCategoriaClick(Sender: TObject);
begin
  FloatAnMenuPrincinpal.Start;
  if not Assigned(FrmCategorias) then
    Application.CreateForm(TFrmCategorias, FrmCategorias);
  FrmCategorias.Show;
end;

procedure TFrmPrincipal.LayMenulogoffClick(Sender: TObject);
var
  u : TUsuario;
  erro : string;
begin
  try
    u := TUsuario.Create(dm.conn);
    if NOT u.Logout(erro) then
    begin
      ShowMessage(erro);
      exit
    end;

  finally
    u.DisposeOf;
  end;

  if NOT Assigned(FrmLogin) then
    Application.CreateForm(TFrmLogin, FrmLogin);

  Application.MainForm := FrmLogin;
  FrmPrincipal.Close;

end;

procedure TFrmPrincipal.LblVerTodosClick(Sender: TObject);
begin
  if NOT Assigned(FrmLancamentos) then
    Application.CreateForm(TFrmLancamentos, FrmLancamentos);
  FrmLancamentos.Show;

end;

procedure TFrmPrincipal.ListVLancamentosItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
 if Not Assigned(FrmLancamentosCadastro) then
    Application.CreateForm(TFrmLancamentosCadastro, FrmLancamentosCadastro);

    FrmLancamentosCadastro.modo := 'A';
    FrmLancamentosCadastro.idLancamento := AItem.TagString.ToInteger;

    FrmLancamentosCadastro.ShowModal(procedure (ModalResult: TModalResult)
    begin
      ListarUltLancamentos;
    end);

end;

procedure TFrmPrincipal.ListVLancamentosItemClickEx(const Sender: TObject;
  ItemIndex: Integer; const LocalClickPos: TPointF;
  const ItemObject: TListItemDrawable);
begin
///dddd
end;

procedure TFrmPrincipal.ListVLancamentosPaint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
begin
//0000
end;

procedure TFrmPrincipal.ListVLancamentosUpdateObjects(const Sender: TObject;
  const AItem: TListViewItem);
begin
  SetupLancamento(FrmPrincipal.ListVLancamentos, AItem);
end;

end.
