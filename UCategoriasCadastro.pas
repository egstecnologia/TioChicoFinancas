unit UCategoriasCadastro;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.ListBox, FMX.Edit,
  FireDAC.Comp.Client, FireDAC.DApt, FMX.DialogService;

type
  TFrmCategoriasCadastro = class(TForm)
    LayBotaoCadCategoria: TLayout;
    LblTituloCadCategoria: TLabel;
    ImgVoltarCadCategoria: TImage;
    ImgSalvaCadCategoria: TImage;
    LayCadCategoria: TLayout;
    LblCadCategoria: TLabel;
    EdtCadCategoria: TEdit;
    LineDescricao: TLine;
    LblIconeCadCategoria: TLabel;
    ListBCadCategoria: TListBox;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    ListBoxItem3: TListBoxItem;
    ListBoxItem4: TListBoxItem;
    ListBoxItem5: TListBoxItem;
    ListBoxItem6: TListBoxItem;
    ListBoxItem7: TListBoxItem;
    ListBoxItem8: TListBoxItem;
    ListBoxItem9: TListBoxItem;
    ListBoxItem10: TListBoxItem;
    ListBoxItem11: TListBoxItem;
    ListBoxItem12: TListBoxItem;
    ListBoxItem13: TListBoxItem;
    ListBoxItem14: TListBoxItem;
    ListBoxItem15: TListBoxItem;
    ListBoxItem16: TListBoxItem;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Image7: TImage;
    Image8: TImage;
    Image9: TImage;
    Image10: TImage;
    Image11: TImage;
    Image12: TImage;
    Image13: TImage;
    Image14: TImage;
    Image15: TImage;
    Image16: TImage;
    ImgSelecao: TImage;
    RectRodapeCategoriaCadastro: TRectangle;
    ImgBotaoDelCategoria: TImage;
    procedure FormResize(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ImgSalvaCadCategoriaClick(Sender: TObject);
    procedure ImgBotaoDelCategoriaClick(Sender: TObject);
  private
    { Private declarations }
    iconeSelecionado: TBitmap;
    indiceSelecionado: Integer;
    procedure SelecionaIcone(img: TImage);

  public
    { Public declarations }
    modo : string; // I (Inclusão) | A (Alteração)
    idCadastro  : Integer;
  end;

var
  FrmCategoriasCadastro: TFrmCategoriasCadastro;

implementation

{$R *.fmx}

uses UPrincipal, UDataModule, cCategoria, UCategorias;


procedure TFrmCategoriasCadastro.FormShow(Sender: TObject);
var
  categoria : TCategoria;
  qry : TFDQuery;
  erro : string;
  item : TListBoxItem;
  img : TImage;
begin
  if modo = 'I' then
  begin
    RectRodapeCategoriaCadastro.Visible := false;
    EdtCadCategoria.Text := '';
    SelecionaIcone(Image1);
  end
  else
    begin
      try
        RectRodapeCategoriaCadastro.Visible := true;
        categoria := TCategoria.Create(dm.conn);
        categoria.idCategoria := idCadastro;
        qry := categoria.ListarCategoria(erro);

        EdtCadCategoria.Text := qry.FieldByName('descricao').AsString;

        // Icone
      item := ListBCadCategoria.ItemByIndex(qry.FieldByName('indiceIcone').AsInteger);
      ImgSelecao.Parent := item;

      img := FrmCategoriasCadastro.FindComponent('Image' + (item.Index +1).ToString) as TImage;
      SelecionaIcone(img)  ;

      finally
        qry.DisposeOf;
        categoria.DisposeOf;
      end;
    end;

end;

procedure TFrmCategoriasCadastro.Image1Click(Sender: TObject);
begin
  SelecionaIcone(TImage(Sender));
end;

procedure TFrmCategoriasCadastro.ImgBotaoDelCategoriaClick(Sender: TObject);
var
  cat : TCategoria;
  erro : string;
begin

  TDialogService.MessageDialog('Confirma a exclusão?',
      TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
      TMsgDlgBtn.mbNo, 0,
      procedure (const AResult: TModalResult)
      var
        erro: string;
      begin
        if AResult = mrYes then
        begin
            try
              cat := TCategoria.Create(dm.conn);
              cat.idCategoria := idCadastro;

              if NOT cat.Excluir(erro) then
              begin
                ShowMessage(erro);
                exit
              end;
              FrmCategorias.listarCategoria;
              Close;
            finally
              cat.DisposeOf;
            end;
        end;
      end
      );
end;

procedure TFrmCategoriasCadastro.ImgSalvaCadCategoriaClick(Sender: TObject);
var
  categoria : TCategoria;
  qry : TFDQuery;
  erro : string;
begin

      try
        categoria := TCategoria.Create(dm.conn);
        categoria.descricao := EdtCadCategoria.Text;
        categoria.icone := iconeSelecionado;
        categoria.indiceIcone := indiceSelecionado;

        if modo = 'I' then
          categoria.Inserir(erro)
        else
        begin
          categoria.idCategoria := idCadastro;
          categoria.Alterar(erro);
        end;

        if erro <> '' then
        begin
          ShowMessage(erro);
          exit;
        end;
        FrmCategorias.listarCategoria;
        Close;

      finally
        categoria.DisposeOf;
      end;
end;

procedure TFrmCategoriasCadastro.SelecionaIcone(img: TImage);
begin
  iconeSelecionado := img.Bitmap; // Salva o icone selecionado
  indiceSelecionado := TListBoxItem(img.Parent).Index;

  ImgSelecao.Parent := img.Parent;
end;

procedure TFrmCategoriasCadastro.FormResize(Sender: TObject);
begin
  ListBCadCategoria.Columns := Trunc(ListBCadCategoria.Width / 80);
end;

end.
