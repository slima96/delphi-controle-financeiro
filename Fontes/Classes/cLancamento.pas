unit cLancamento;

interface

uses FireDAC.comp.Client, FireDAC.DApt, System.SysUtils, FMX.Graphics;

type
    TLancamento = class
    private
        Fconn: TFDConnection;
        FVALOR: Double;
        FDESCRICAO: string;
        FID_CATEGORIA: Integer;
        FDT_LANCAMENTO: TDateTime;
        FID_LANCAMENTO: Integer;
        FDT_ATE: string;
        FDT_DE: string;

    public
        constructor Create(conn: TFDConnection);
        property ID_LANCAMENTO: Integer read FID_LANCAMENTO write FID_LANCAMENTO;
        property ID_CATEGORIA: Integer read FID_CATEGORIA write FID_CATEGORIA;
        property VALOR: Double read FVALOR write FVALOR;
        property DT_LANCAMENTO: TDateTime read FDT_LANCAMENTO write FDT_LANCAMENTO;
        property DT_DE: string read FDT_DE write FDT_DE;
        property DT_ATE: string read FDT_ATE write FDT_ATE;
        property DESCRICAO: string read FDESCRICAO write FDESCRICAO;

        function ListarLancamento(qtd_result: integer; out erro: string): TFDQuery;
        function ListarResumo(out erro: string): TFDQuery;
        function Inserir(out erro: string): Boolean;
        function Alterar(out erro: string): Boolean;
        function Excluir(out erro: string): Boolean;
end;

implementation

{ TLancamento }

constructor TLancamento.Create(conn: TFDConnection);
begin
    Fconn := conn;
end;

function TLancamento.Inserir(out erro: string): Boolean;
var
    qry : TFDQuery;
begin
    // Validações....
    if ID_CATEGORIA <= 0 then
    begin
        erro := 'Informe o ID da categoria';
        Result := false;
        Exit;
    end;

    if DESCRICAO = '' then
    begin
        erro := 'Informa a descrição do lançamento';
        Result := false;
        Exit;
    end;

    try
        try
            qry := TFDQuery.Create(nil);
            qry.Connection := Fconn;

            with qry do
            begin
                Active := false;
                SQL.Clear;
                SQL.Add('INSERT INTO TAB_LANCAMENTO(ID_CATEGORIA, VALOR, DATA, DESCRICAO)');
                SQL.Add('VALUES(:ID_CATEGORIA, :VALOR, :DATA, :DESCRICAO)');
                ParamByName('ID_CATEGORIA').Value := ID_CATEGORIA;
                ParamByName('VALOR').Value := VALOR;
                ParamByName('DATA').Value := DT_LANCAMENTO;
                ParamByName('DESCRICAO').Value := DESCRICAO;
                ExecSQL;
            end;

            Result := true;
            erro := '';

        except on ex:Exception do
        begin
            Result := false;
            erro := 'Erro ao inserir lançamento: ' + ex.Message;
        end;
        end;
    finally
        qry.DisposeOf;
    end;
end;

function TLancamento.Alterar(out erro: string): Boolean;
var
    qry : TFDQuery;
begin
    // Validações....
    if ID_LANCAMENTO <= 0 then
    begin
        erro := 'Informe o ID do lançamento';
        Result := false;
        Exit;
    end;

    if ID_CATEGORIA <= 0 then
    begin
        erro := 'Informe o ID da categoria';
        Result := false;
        Exit;
    end;

    if DESCRICAO = '' then
    begin
        erro := 'Informa a descrição do lançamento';
        Result := false;
        Exit;
    end;

    try
        try
            qry := TFDQuery.Create(nil);
            qry.Connection := Fconn;

            with qry do
            begin
                Active := false;
                SQL.Clear;
                SQL.Add('UPDATE TAB_LANCAMENTO SET ID_CATEGORIA = :ID_CATEGORIA, VALOR = :VALOR, DATA = :DATA, DESCRICAO = :DESCRICAO');
                SQL.Add('WHERE ID_LANCAMENTO = :ID_LANCAMENTO');
                ParamByName('ID_LANCAMENTO').Value := ID_LANCAMENTO;
                ParamByName('ID_CATEGORIA').Value := ID_CATEGORIA;
                ParamByName('VALOR').Value := VALOR;
                ParamByName('DATA').Value := DT_LANCAMENTO;
                ParamByName('DESCRICAO').Value := DESCRICAO;
                ExecSQL;
            end;

            Result := true;
            erro := '';

        except on ex:Exception do
        begin
            Result := false;
            erro := 'Erro ao alterar lançamento: ' + ex.Message;
        end;
        end;
    finally
        qry.DisposeOf;
    end;
end;

function TLancamento.Excluir(out erro: string): Boolean;
var
    qry : TFDQuery;
begin
    // Validações....
    if ID_LANCAMENTO <= 0 then
    begin
        erro := 'Informe o ID do lançamento';
        Result := false;
        Exit;
    end;

    try
        try
            qry := TFDQuery.Create(nil);
            qry.Connection := Fconn;

            with qry do
            begin
                Active := false;
                SQL.Clear;
                SQL.Add('DELETE FROM TAB_LANCAMENTO');
                SQL.Add('WHERE ID_LANCAMENTO = :ID_LANCAMENTO');
                ParamByName('ID_LANCAMENTO').Value := ID_LANCAMENTO;
                ExecSQL;
            end;

            Result := true;
            erro := '';

        except on ex:Exception do
        begin
            Result := false;
            erro := 'Erro ao excluir lançamento: ' + ex.Message;
        end;
        end;
    finally
        qry.DisposeOf;
    end;
end;

function TLancamento.ListarLancamento(qtd_result: integer; out erro: string): TFDQuery;
var
    qry : TFDQuery;
begin
    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Fconn;

        with qry do
        begin
            Active := false;
            SQL.Clear;
            SQL.Add('SELECT L.*, C.DESCRICAO AS DESCRICAO_CATEGORIA, C.ICONE');
            SQL.Add('FROM TAB_LANCAMENTO L');
            SQL.Add('JOIN TAB_CATEGORIA C ON (C.ID_CATEGORIA = L.ID_CATEGORIA)');
            SQL.Add('WHERE 1 = 1');

            if ID_LANCAMENTO > 0 then
            begin
                SQL.Add('AND L.ID_LANCAMENTO = :ID_LANCAMENTO');
                ParamByName('ID_LANCAMENTO').Value := ID_LANCAMENTO;
            end;

            if ID_CATEGORIA > 0 then
            begin
                SQL.Add('AND L.ID_CATEGORIA = :ID_CATEGORIA');
                ParamByName('ID_CATEGORIA').Value := ID_CATEGORIA;
            end;

            if (DT_DE <> '') and (DT_ATE <> '') then
            begin
                SQL.Add('AND L.DATA BETWEEN ''' + DT_DE + ''' AND ''' + DT_ATE + '''');
            end;

            SQL.Add('ORDER BY L.DATA DESC');

            if qtd_result > 0 then
                SQL.Add('LIMIT ' + qtd_result.ToString);

            Active := true;
        end;

        Result := qry;
        erro := '';

    except on ex:Exception do
    begin
        Result := nil;
        erro := 'Erro ao consultar categorias: ' + ex.Message;
    end;
    end;
end;

function TLancamento.ListarResumo(out erro: string): TFDQuery;
var
    qry : TFDQuery;
begin
    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Fconn;

        with qry do
        begin
            Active := false;
            SQL.Clear;
            SQL.Add('SELECT C.ICONE, C.DESCRICAO, CAST(SUM(L.VALOR) AS REAL) AS VALOR');
            SQL.Add('FROM TAB_LANCAMENTO L');
            SQL.Add('JOIN TAB_CATEGORIA C ON (C.ID_CATEGORIA = L.ID_CATEGORIA)');
            SQL.Add('WHERE L.DATA BETWEEN ''' + DT_DE + ''' AND ''' + DT_ATE + '''');
            SQL.Add('GROUP BY C.ICONE, C.DESCRICAO');
            SQL.Add('ORDER BY 2');
            Active := true;
        end;

        Result := qry;
        erro := '';

    except on ex:Exception do
    begin
        Result := nil;
        erro := 'Erro ao consultar categorias: ' + ex.Message;
    end;
    end;
end;

end.
