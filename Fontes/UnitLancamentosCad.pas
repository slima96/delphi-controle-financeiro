unit UnitLancamentosCad;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, System.Math.Vectors,
  FMX.Controls3D, FMX.Layers3D, FMX.Edit, FMX.DateTimeCtrls, FMX.ListBox,
  FireDAC.DApt, FireDAC.Comp.Client;

type
  TFrmLancamentosCad = class(TForm)
    Layout1: TLayout;
    Label1: TLabel;
    img_voltar: TImage;
    img_save: TImage;
    Layout3D1: TLayout3D;
    Layout2: TLayout;
    Label2: TLabel;
    edt_descricao: TEdit;
    Line1: TLine;
    Layout3: TLayout;
    Label3: TLabel;
    Line2: TLine;
    Layout4: TLayout;
    Label4: TLabel;
    Layout5: TLayout;
    Label5: TLabel;
    edt_valor: TEdit;
    Line4: TLine;
    img_hoje: TImage;
    dt_lanc: TDateEdit;
    img_ontem: TImage;
    rect_delete: TRectangle;
    img_add: TImage;
    img_tipo_lanc: TImage;
    img_despesa: TImage;
    img_receita: TImage;
    lbl_categoria: TLabel;
    Line3: TLine;
    Image1: TImage;
    procedure img_voltarClick(Sender: TObject);
    procedure img_tipo_lancClick(Sender: TObject);
    procedure img_hojeClick(Sender: TObject);
    procedure img_ontemClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure img_saveClick(Sender: TObject);
    procedure edt_valorTyping(Sender: TObject);
    procedure img_addClick(Sender: TObject);
    procedure lbl_categoriaClick(Sender: TObject);
  private
//    procedure ComboCategoria;
    function TrataValor(str: string): double;
    { Private declarations }
  public
    { Public declarations }
      modo : string;
      id_lanc: Integer;
  end;

var
  FrmLancamentosCad: TFrmLancamentosCad;

implementation

{$R *.fmx}

uses UnitPrincipal, cCategoria, UnitDM, cLancamento, uFormat,
  FMX.DialogService, UnitComboCategoria;
{
procedure TFrmLancamentosCad.ComboCategoria;
var
    c : TCategoria;
    erro : string;
    qry : TFDQuery;
begin
    try
        cmb_categoria.Items.Clear;

        c := TCategoria.Create(dm.conn);
        qry := c.ListarCategoria(erro);

        if erro <> '' then
        begin
            ShowMessage(erro);
            exit;
        end;

        while NOT qry.Eof do
        begin
            cmb_categoria.Items.AddObject(qry.FieldByName('DESCRICAO').AsString,
                                          TObject(qry.FieldByName('ID_CATEGORIA').AsInteger));
            qry.Next;
        end;

    finally
        qry.DisposeOf;
        c.DisposeOf;
    end;
end; }

procedure TFrmLancamentosCad.edt_valorTyping(Sender: TObject);
begin
    Formatar(edt_valor, TFormato.Valor);
end;

procedure TFrmLancamentosCad.FormShow(Sender: TObject);
var
    lanc : TLancamento;
    qry : TFDQuery;
    erro : string;
begin
//    ComboCategoria;

    if modo = 'I' then
    begin
        edt_descricao.Text := '';
        dt_lanc.Date := Date;
        edt_valor.Text := '0,00';
        img_tipo_lanc.Bitmap := img_despesa.Bitmap;
        img_tipo_lanc.Tag := -1;
        rect_delete.Visible := false;
        lbl_categoria.Text := '';
        lbl_categoria.Tag := 0;
    end
    else
    begin
        try
            lanc := TLancamento.Create(dm.conn);
            lanc.ID_LANCAMENTO := id_lanc;
            qry := lanc.ListarLancamento(0, erro);

            if qry.RecordCount = 0 then
            begin
              ShowMessage('Lan?amento n?o encontrado');
              exit;
            end;

            edt_descricao.Text := qry.FieldByName('DESCRICAO').AsString;
            dt_lanc.Date := qry.FieldByName('DATA').AsDateTime;

            if qry.FieldByName('VALOR').AsFloat < 0 then
            begin
                edt_valor.Text := FormatFloat('#,##0.00', qry.FieldByName('VALOR').AsFloat * -1);
                img_tipo_lanc.Bitmap := img_despesa.Bitmap;
                img_tipo_lanc.tag := -1;
            end
            else
            begin
                edt_valor.Text := FormatFloat('#,##0.00', qry.FieldByName('VALOR').AsFloat);
                img_tipo_lanc.Bitmap := img_receita.Bitmap;
                img_tipo_lanc.tag := 1;
            end;

//            cmb_categoria.ItemIndex := cmb_categoria.Items.IndexOf(qry.FieldByName('DESCRICAO_CATEGORIA').AsString);
            lbl_categoria.Text := qry.FieldByName('DESCRICAO_CATEGORIA').AsString;
            lbl_categoria.Tag := qry.FieldByName('ID_CATEGORIA').AsInteger;
            rect_delete.Visible := true;

        finally
            qry.DisposeOf;
            lanc.DisposeOf;
        end;
    end;
end;

procedure TFrmLancamentosCad.img_addClick(Sender: TObject);
var
    lanc: TLancamento;
    erro: string;
begin
     TDialogService.MessageDialog('Confirma exclus?o do lan?amento?',
                     TMsgDlgType.mtConfirmation,
                     [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
                     TMsgDlgBtn.mbNo,
                     0,
     procedure(const AResult: TModalResult)
     var
        erro: string;
     begin
        if AResult = mrYes then
        begin
            try
                lanc := TLancamento.Create(dm.conn);
                lanc.ID_LANCAMENTO := id_lanc;

                if NOT lanc.Excluir(erro) then
                begin
                    ShowMessage(erro);
                    exit;
                end;

                Close;

            finally
                lanc.DisposeOf;
            end;
        end;
     end);
end;

procedure TFrmLancamentosCad.img_hojeClick(Sender: TObject);
begin
    dt_lanc.Date := Date;
end;

procedure TFrmLancamentosCad.img_ontemClick(Sender: TObject);
begin
    dt_lanc.Date := Date - 1;
end;

function TFrmLancamentosCad.TrataValor(str: string): double;
begin
    str := StringReplace(str, '.', '', [rfReplaceAll]);
    str := StringReplace(str, ',', '', [rfReplaceAll]);

    try
        Result := StrToFloat(str) / 100;
    except
        Result := 0;
    end;
end;

procedure TFrmLancamentosCad.img_saveClick(Sender: TObject);
var
    lanc : TLancamento;
    erro : string;
begin
    try
        lanc := TLancamento.Create(dm.conn);
        lanc.DESCRICAO := edt_descricao.Text;
        lanc.VALOR := TrataValor(edt_valor.Text) * img_tipo_lanc.Tag;

//        lanc.ID_CATEGORIA := Integer(cmb_categoria.Items.Objects[cmb_categoria.ItemIndex]);
        lanc.ID_CATEGORIA := lbl_categoria.Tag;
        lanc.DT_LANCAMENTO := dt_lanc.Date;

        if modo = 'I' then
        begin
            lanc.Inserir(erro);
        end
        else
        begin
            lanc.ID_LANCAMENTO := id_lanc;
            lanc.Alterar(erro);
        end;

        if erro <> '' then
        begin
            ShowMessage(erro);
            exit;
        end;

        close;

    finally
        lanc.DisposeOf;
    end;
end;

procedure TFrmLancamentosCad.img_tipo_lancClick(Sender: TObject);
begin
    if img_tipo_lanc.Tag = 1 then
    begin
        img_tipo_lanc.Bitmap := img_despesa.Bitmap;
        img_tipo_lanc.Tag := -1;
    end
    else
    begin
        img_tipo_lanc.Bitmap := img_receita.Bitmap;
        img_tipo_lanc.Tag := 1;
    end;
end;

procedure TFrmLancamentosCad.img_voltarClick(Sender: TObject);
begin
    close;
end;

procedure TFrmLancamentosCad.lbl_categoriaClick(Sender: TObject);
begin
    // Abre listagem das categorias....
    if NOT Assigned(FrmComboCategoria) then
        Application.CreateForm(TFrmComboCategoria, FrmComboCategoria);

    FrmComboCategoria.ShowModal(procedure(ModelResult: TModalResult)
    begin
        if FrmComboCategoria.IdCategoriaSelecao > 0 then
        begin
            lbl_categoria.Text := FrmComboCategoria.CategoriaSelecao;
            lbl_categoria.Tag := FrmComboCategoria.IdCategoriaSelecao;
        end;
    end);
end;

end.
