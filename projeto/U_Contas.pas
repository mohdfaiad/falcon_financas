unit U_Contas;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Dialogs, uniGUITypes, uniGUIAbstractClasses, uniGUIFrame,
  uniGUIClasses, uniGUIForm, U_Cad_Heranca, FMTBcd, uniImageList, uniScreenMask,
  Provider, DBClient, DB, uniScrollBox, uniPanel, uniPageControl,
  uniToolBar, uniGUIBaseClasses, uniStatusBar, uniCheckBox, uniDBCheckBox,
  uniEdit, ComboboxYeni, uniMultiItem, uniComboBox, uniDBEdit, uniLabel,
  uniButton, uniBitBtn, uniSpeedButton, uniImage, uniBasicGrid,
  uniDBGrid, uniDBImage, uniDateTimePicker, uniDBDateTimePicker, uADStanIntf,
  uADStanOption, uADStanParam, uADStanError, uADDatSManager, uADPhysIntf, uADDAptIntf,
  uADStanAsync, uADDAptManager, uADCompDataSet, uADCompClient;

type
  TFormCad_Contas = class(TFormCad_Heranca)
    UniPanel1: TUniPanel;
    edt_pesq_descricao: TUniEdit;
    UniLabel3: TUniLabel;
    UniDBGrid1: TUniDBGrid;
    ADQuery: TADQuery;
    pn_flags: TUniPanel;
    pn_flag: TUniPanel;
    DB_Ativo: TUniDBCheckBox;
    UniDBCheckBox1: TUniDBCheckBox;
    pn_geral: TUniPanel;
    pn_descricao: TUniPanel;
    UniLabel1: TUniLabel;
    DB_Descricao: TUniDBEdit;
    UniLabel2: TUniLabel;
    cmb_tipo: TUniComboBox;
    img_banco: TUniImage;
    pn_banco: TUniPanel;
    UniLabel4: TUniLabel;
    cmb_banco: TComboBoxYeni;
    pn_saldo: TUniPanel;
    UniLabel6: TUniLabel;
    spb_edita_saldo: TUniSpeedButton;
    edt_saldo: TUniDBEdit;
    ADQueryID_CONTAS: TIntegerField;
    ADQueryID_MASTER: TIntegerField;
    ADQueryID_EMPRESA: TIntegerField;
    ADQueryNOME_CONTA: TWideStringField;
    ADQueryTIPO: TWideStringField;
    ADQueryID_BANCOS: TIntegerField;
    ADQueryNOME_BANCO: TWideStringField;
    ADQuerySALDO: TBCDField;
    ADQueryATIVO: TWideStringField;
    ADQueryLOGO: TGraphicField;
    ADQueryDAT_CADASTRO: TDateTimeField;
    ADQueryID_USUARIO: TIntegerField;
    ADQueryIMG_ATIVO: TStringField;
    ADQueryVISIVEL_GRAFICOS: TWideStringField;
    bt_pesquisa: TUniBitBtn;
    procedure cmb_tipoCloseUp(Sender: TObject);
    procedure DSDataChange(Sender: TObject; Field: TField);
    procedure UniFormCreate(Sender: TObject);
    procedure bt_salvarClick(Sender: TObject);
    procedure bt_pesquisaClick(Sender: TObject);
    procedure edt_pesq_descricaoKeyPress(Sender: TObject; var Key: Char);
    procedure bt_excluirClick(Sender: TObject);
    procedure edt_saldoExit(Sender: TObject);
    procedure spb_edita_saldoClick(Sender: TObject);
    procedure cmb_bancoExit(Sender: TObject);
    procedure DSStateChange(Sender: TObject);
    procedure UniDBGrid1DblClick(Sender: TObject);
    procedure UniQueryBeforePost(DataSet: TDataSet);
    procedure cmb_tipoExit(Sender: TObject);
    procedure ADQueryIMG_ATIVOGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
    procedure UniDBGrid1ColumnSort(Column: TUniDBGridColumn;
      Direction: Boolean);
  private
    { Private declarations }
    Conexao                                                                     :TADConnection;
    Transaction                                                                 :TADTransaction;
    SQLQuery                                                                    :TADQuery;

    pos_cds                                                                     :Integer;
    url_imagem                                                                  :String;
  public
    { Public declarations }
  end;

function FormCad_Contas: TFormCad_Contas;

implementation

{$R *.dfm}

uses
  MainModule, uniGUIApplication, U_Sessao, U_Global, U_Verifica_Campo_Null,
  U_Carrega_Combo, ServerModule, U_Imagens, U_JS_Humane, Vcl.Imaging.pngimage,
  U_DM;

function FormCad_Contas: TFormCad_Contas;
begin
  Result := TFormCad_Contas(ID.GetFormInstance(TFormCad_Contas));
end;

procedure TFormCad_Contas.ADQueryIMG_ATIVOGetText(Sender: TField;
  var Text: string; DisplayText: Boolean);
begin
  inherited;
  if DS.DataSet.FieldByName('ATIVO').AsString = 'S' then
    Text:= '<img src="../imagens/16/tick.png" />';
  if DS.DataSet.FieldByName('ATIVO').AsString = 'N' then
    Text:= '<img src="../imagens/16/cross.png" />'
end;

procedure TFormCad_Contas.bt_excluirClick(Sender: TObject);
var
  I:Integer;
begin
//inherited;
   MessageDlg('Deseja realmente excluir?', mtConfirmation, mbYesNo, procedure(Res: Integer)
  begin
    if Res = mrYes then
      begin
        try
          if Not DS.DataSet.IsEmpty then //se nao estiver vazio
           begin
             SQLQuery.SQL.Clear;
             SQLQuery.SQL.Add('DELETE FROM CONTAS                                      '+
                              ' WHERE ID_MASTER                   = :P00               '+
                              '   AND ID_EMPRESA                  = :P01               '+
                              '   AND ID_CONTAS                   = :P02               ');
             SQLQuery.Params[00].AsInteger := ID.id_glo_master;
             SQLQuery.Params[01].AsInteger := ID.id_glo_empresa;
             SQLQuery.Params[02].AsInteger := DS.DataSet.FieldByName('ID_CONTAS').AsInteger;
             SQLQuery.ExecSQL;

             DS.DataSet.Delete;

             UniStatusBar1.Panels.Items[0].Text:= 'Exclus�o efetuada com sucesso.';
             humane.success('<div> <p><img src= imagens/32/empty.png </> '+
                            'Exclus�o efetuada com sucesso.</p> </div>',2500,True);
           end
          else
            UniStatusBar1.Panels.Items[0].Text:= 'N�o existem registros para serem excluidos!';
         except
           on e: Exception  do
             begin
              DS.DataSet.Cancel;
              if Copy(E.Message,0,59) = '[FireDAC][Phys][MySQL] Cannot delete or update a parent row' then
                begin
                  ShowMessage('Aten��o!<br><br> '+
                              '<div> <p><img src="imagens\warning.png" align="left"/> N�o � possivel excluir, o mesmo possui depend�ncias com outros regitros!</p> </div> <br>'+
                              'Voc� Pode Inativar esta Conta, Desmarcando a Op��o " Conta Ativa". ');
                end
               else
                 RelatorioErro(String(TUniFrame(Self).Name),String(TUniFrame(Sender).Name),e.UnitName,e.ClassName,e.Message);

               UniStatusBar1.Panels.Items[0].Text:='Exclus�o Cancelada!';
               Exit;
             end;
         end;
      end;
  end
  );

end;

procedure TFormCad_Contas.bt_pesquisaClick(Sender: TObject);
begin
  inherited;
  try
    if Not(DS.DataSet.IsEmpty) then
      pos_cds := DS.DataSet.RecNo
    else
      pos_cds := 0;

    With ADQuery do
      begin
        Close;
        SQL.Clear;
        SQL.Add('         SELECT A.ID_CONTAS,                                                    ');
        SQL.Add('                A.ID_MASTER,                                                    ');
        SQL.Add('                A.ID_EMPRESA,                                                   ');
        SQL.Add('                A.NOME_CONTA,                                                   ');
        SQL.Add('                A.TIPO,                                                         ');
        SQL.Add('                A.ID_BANCOS,                                                    ');
        SQL.Add('                B.NOME_BANCO,                                                   ');
        SQL.Add('                A.SALDO,                                                        ');
        SQL.Add('                A.ATIVO,                                                        ');
        SQL.Add('                A.VISIVEL_GRAFICOS,                                             ');
        SQL.Add('                B.LOGO,                                                         ');
        SQL.Add('                A.DAT_CADASTRO,                                                 ');
        SQL.Add('                A.ID_USUARIO                                                    ');
        SQL.Add('           FROM CONTAS       A,                                                 ');
        SQL.Add('                BANCOS       B                                                  ');
        SQL.Add('          WHERE A.ID_BANCOS  =  B.ID_BANCOS                                     ');
        SQL.Add('            AND A.TIPO       = ''BANCO''                                        ');
        SQL.Add('            AND A.ID_MASTER  = '''+IntToStr(ID.id_glo_master)+'''               ');
        SQL.Add('            AND A.ID_EMPRESA = '''+IntToStr(ID.id_glo_empresa)+'''              ');
        if edt_pesq_descricao.Text <> EmptyStr then
        SQL.Add('            AND UPPER(A.NOME_CONTA) LIKE UPPER(''%'+edt_pesq_descricao.Text+'%'')');
        SQL.Add('          UNION                                                                 ');
        SQL.Add('         SELECT A.ID_CONTAS,                                                    ');
        SQL.Add('                A.ID_MASTER,                                                    ');
        SQL.Add('                A.ID_EMPRESA,                                                   ');
        SQL.Add('                A.NOME_CONTA,                                                   ');
        SQL.Add('                A.TIPO,                                                         ');
        SQL.Add('                A.ID_BANCOS,                                                    ');
        SQL.Add('                '''' NOME_BANCO,                                                ');
        SQL.Add('                A.SALDO,                                                        ');
        SQL.Add('                A.ATIVO,                                                        ');
        SQL.Add('                A.VISIVEL_GRAFICOS,                                             ');
        SQL.Add('                B.PARAMETRO_BLOB,                                               ');
        SQL.Add('                A.DAT_CADASTRO,                                                 ');
        SQL.Add('                A.ID_USUARIO                                                    ');
        SQL.Add('          FROM CONTAS       A,                                                  ');
        SQL.Add('               PARAMETROS   B                                                   ');
        SQL.Add('         WHERE A.TIPO       = ''CARTEIRA''                                      ');
        SQL.Add('           AND B.MODULO     = ''CONTAS''                                        ');
        SQL.Add('           AND B.TITULO     = ''IMAGEM PADRAO CARTEIRA''                        ');
        SQL.Add('           AND A.ID_MASTER  = '''+IntToStr(ID.id_glo_master)+'''                ');
        SQL.Add('           AND A.ID_EMPRESA = '''+IntToStr(ID.id_glo_empresa)+'''               ');
        if edt_pesq_descricao.Text <> EmptyStr then
        SQL.Add('           AND UPPER(A.NOME_CONTA) LIKE UPPER(''%'+edt_pesq_descricao.Text+'%'')');
        //SaveClipboard(Text);

        Open;
      end;

    if pos_cds <> 0 then
      DS.DataSet.RecNo := pos_cds;
  except
    on e:exception do
      begin
        RelatorioErro(String(TUniFrame(Self).Name),String(TUniFrame(Sender).Name),e.UnitName,e.ClassName,e.Message);
      end;

  end;
end;

procedure TFormCad_Contas.bt_salvarClick(Sender: TObject);
var
  id_bancos : String;
begin
  //inherited;
  id_bancos := '0';

  if (cmb_tipo.Text = 'BANCO') or (cmb_tipo.Text = 'POUPAN�A') or (cmb_tipo.Text = 'CART�O DE CR�DITO') then
    begin
      if cmb_banco.Text = EmptyStr then
        begin
          ShowMessage('Banco n�o informado.');
          Exit;
        end;
      id_bancos := cmb_banco.Value;
    end;

  if Verifica_Edit(TUniForm(Self)) then
    begin
      try
        if Not(Transaction.Active) then
          Transaction.StartTransaction;

        RemoveAspas(TUniForm(Self));

        if DS.DataSet.State in [dsInsert] then
          begin
            SQLQuery.SQL.Clear;
            SQLQuery.SQL.Add('SELECT COUNT(*) FROM CONTAS                             '+
                             ' WHERE ID_MASTER        = :P00                          '+
                             '   AND ID_EMPRESA       = :P01                          '+
                             '   AND UPPER(TIPO)      = UPPER(:P02)                   '+
                             '   AND UPPER(NOME_CONTA)= UPPER(:P03)                   ');
            SQLQuery.Params[00].AsInteger := ID.id_glo_master;
            SQLQuery.Params[01].AsInteger := ID.id_glo_empresa;
            SQLQuery.Params[02].AsString  := cmb_tipo.Text;
            SQLQuery.Params[03].AsString  := DB_Descricao.Text;
            SQLQuery.Open;
            if SQLQuery.Fields[0].AsInteger > 0 then
              begin
                ShowMessage('Esta conta j� est� cadastrada!');
                Exit;
              end;

            {Simulando DataSet}
            DS.DataSet.FieldByName('ID_CONTAS').AsInteger     := gen_id('CONTAS',Conexao);
            if (cmb_tipo.Text = 'BANCO') or (cmb_tipo.Text = 'POUPAN�A') or (cmb_tipo.Text = 'CART�O DE CR�DITO') then
              begin
                DS.DataSet.FieldByName('ID_BANCOS').AsString      := id_bancos;
                DS.DataSet.FieldByName('NOME_BANCO').AsString     :=  cmb_banco.Text;
              end;
            if (cmb_tipo.Text = 'CARTEIRA') or (cmb_tipo.Text = 'OUTROS') or (cmb_tipo.Text = 'INVESTIMENTO') then
            DS.DataSet.FieldByName('ID_BANCOS').AsString      := '0';
            DS.DataSet.FieldByName('TIPO').AsString           :=  cmb_tipo.Text;
            DS.DataSet.FieldByName('ID_MASTER').AsInteger     := ID.id_glo_master;
            DS.DataSet.FieldByName('ID_EMPRESA').AsInteger    := ID.id_glo_empresa;
            DS.DataSet.FieldByName('TIPO').AsString           := cmb_tipo.Text;
            DS.DataSet.FieldByName('ID_USUARIO').AsInteger    := ID.id_glo_usuario;
            DS.DataSet.FieldByName('DAT_CADASTRO').AsDateTime := data_atual_bd;

            SQLQuery.SQL.Clear;
            SQLQuery.SQL.Add('INSERT INTO CONTAS                                      '+
                             '          ( ID_MASTER,                                  '+
                             '            ID_EMPRESA,                                 '+
                             '            NOME_CONTA,                                 '+
                             '            TIPO,                                       '+
                             '            ID_BANCOS,                                  '+
                             '            SALDO,                                      '+
                             '            ATIVO,                                      '+
                             '            VISIVEL_GRAFICOS,                           '+
                             '            DAT_CADASTRO,                               '+
                             '            ID_USUARIO )                                '+
                             '     VALUES                                             '+
                             '          ( :P00, :P01, :P02, :P03, :P04, :P05, :P06,   '+
                             '            :P07, SYSDATE(), :P08 )                     ');
            SQLQuery.Params[00].AsInteger := ID.id_glo_master;
            SQLQuery.Params[01].AsInteger := ID.id_glo_empresa;
            SQLQuery.Params[02].AsString  := DB_Descricao.Text;
            SQLQuery.Params[03].AsString  := cmb_tipo.Text;
            if (cmb_tipo.Text = 'BANCO') or (cmb_tipo.Text = 'POUPAN�A') or (cmb_tipo.Text = 'CART�O DE CR�DITO') then
            SQLQuery.Params[04].AsString  := id_bancos;
            if (cmb_tipo.Text = 'CARTEIRA') or (cmb_tipo.Text = 'OUTROS') or (cmb_tipo.Text = 'INVESTIMENTO') then
            SQLQuery.Params[04].AsString  := '0';
            SQLQuery.Params[05].AsFloat   := DS.DataSet.FieldByName('SALDO').AsFloat;
            SQLQuery.Params[06].AsString  := DS.DataSet.FieldByName('ATIVO').AsString;
            SQLQuery.Params[07].AsString  := DS.DataSet.FieldByName('VISIVEL_GRAFICOS').AsString;
            SQLQuery.Params[08].AsInteger := ID.id_glo_usuario;
            SQLQuery.ExecSQL;

            DS.DataSet.Post;

            Transaction.Commit;

            humane.success('<div> <img src= imagens/32/tick_blue.png </> '+
                           'Registro inclu�do com Sucesso. </div>',2500,True);
            UniStatusBar1.Panels.Items[0].Text := 'Registro incluido com Sucesso.';
          end;

        if DS.DataSet.State in [dsEdit] then
          begin
            SQLQuery.SQL.Clear;
            SQLQuery.SQL.Add('UPDATE CONTAS SET NOME_CONTA       = :P00,              '+
                             '                  ATIVO            = :P01,              '+
                             '                  VISIVEL_GRAFICOS = :P02,              '+
                             '                  SALDO            = :P03               '+
                             ' WHERE ID_MASTER                   = :P04               '+
                             '   AND ID_EMPRESA                  = :P05               '+
                             '   AND ID_CONTAS                   = :P06               ');
            SQLQuery.Params[00].AsString  := DS.DataSet.FieldByName('NOME_CONTA').AsString;
            SQLQuery.Params[01].AsString  := DS.DataSet.FieldByName('ATIVO').AsString;
            SQLQuery.Params[02].AsString  := DS.DataSet.FieldByName('VISIVEL_GRAFICOS').AsString;
            SQLQuery.Params[03].AsFloat   := DS.DataSet.FieldByName('SALDO').AsFloat;
            SQLQuery.Params[04].AsInteger := ID.id_glo_master;
            SQLQuery.Params[05].AsInteger := ID.id_glo_empresa;
            SQLQuery.Params[06].AsString  := DS.DataSet.FieldByName('ID_CONTAS').AsString;
            SQLQuery.ExecSQL;

            {Simulando DataSet}
            if (cmb_tipo.Text = 'BANCO') or (cmb_tipo.Text = 'POUPAN�A') or (cmb_tipo.Text = 'CART�O DE CR�DITO') then
            DS.DataSet.FieldByName('NOME_BANCO').AsString  :=  cmb_banco.Text;
            DS.DataSet.FieldByName('TIPO').AsString        :=  cmb_tipo.Text;

            DS.DataSet.Post;

            Transaction.Commit;

            humane.success('<div> <img src= imagens/32/tick_blue.png </> '+
                           'Registro alterado com Sucesso. </div>',2500,True);
            UniStatusBar1.Panels.Items[0].Text := 'Registro alterado com Sucesso.';
          end;
      except
        on e: exception do
          begin
            Transaction.Rollback;
            DS.DataSet.Cancel;
            RelatorioErro(String(TUniFrame(Self).Name),String(TUniFrame(Sender).Name),e.UnitName,e.ClassName,e.Message);
          end;
      end;
    end;

end;

procedure TFormCad_Contas.cmb_bancoExit(Sender: TObject);
var
  BField: TBlobField;
  Stream: TStream;
  Png   : TPNGImage;
begin
  inherited;
  SQLQuery.SQL.Clear;
  SQLQuery.SQL.Add('SELECT LOGO, NOME_BANCO FROM BANCOS   '+
                   ' WHERE ATIVO     = ''S''  '+
                   '   AND ID_BANCOS = :P00   ');
  SQLQuery.Params[00].AsString  := cmb_banco.Value;
  SQLQuery.Open;

//  BField  := TBlobField(SQLQuery.FieldByName('LOGO'));
//  Stream  := SQLQuery.CreateBlobStream(BField, bmRead);
//  Png     := TPNGImage.Create;
//  try
//    Png.LoadFromStream(Stream);
//    img_banco.Picture.Graphic := Png;
//  finally
//    Stream.Free;
//    FreeAndNil(Png);
//  end;
end;

procedure TFormCad_Contas.cmb_tipoCloseUp(Sender: TObject);
begin
  inherited;
  if (cmb_tipo.Text = 'BANCO') or (cmb_tipo.Text = 'POUPAN�A') or (cmb_tipo.Text = 'CART�O DE CR�DITO') then
    begin
      pn_banco.Visible  := True;
      cmb_banco.Tag     := 1;
    end;

  if (cmb_tipo.Text = 'CARTEIRA') or (cmb_tipo.Text = 'OUTROS') or (cmb_tipo.Text = 'INVESTIMENTO') then
    begin
      pn_banco.Visible := False;
      cmb_banco.Tag     := 0;
    end;
end;

procedure TFormCad_Contas.cmb_tipoExit(Sender: TObject);
var
  BField: TBlobField;
  Stream: TStream;
  Png   : TPNGImage;
begin
  inherited;
  if (cmb_tipo.Text = 'CARTEIRA') or (cmb_tipo.Text = 'OUTROS') or (cmb_tipo.Text = 'INVESTIMENTO') then
    begin
      pn_banco.Visible := False;
      cmb_banco.Tag     := 0;

      SQLQuery.SQL.Clear;
      SQLQuery.SQL.Add('SELECT PARAMETRO_BLOB FROM PARAMETROS        '+
                       ' WHERE MODULO = ''CONTAS''                   '+
                       '   AND TITULO = ''IMAGEM PADRAO CARTEIRA''   ');
      SQLQuery.Open;

//      BField  := TBlobField(SQLQuery.FieldByName('PARAMETRO_BLOB'));
//      Stream  := SQLQuery.CreateBlobStream(BField, bmRead);
//      Png     := TPNGImage.Create;
//      try
//        Png.LoadFromStream(Stream);
//        img_banco.Picture.Graphic := Png;
//        UniQueryLOGO.LoadFromStream(Stream);
//      finally
//        Stream.Free;
//        FreeAndNil(Png);
//      end;
    end;
end;

procedure TFormCad_Contas.DSDataChange(Sender: TObject; Field: TField);
var
  BField: TBlobField;
  Stream: TStream;
  Png   : TPNGImage;
begin
  inherited;

  if Not(DS.DataSet.State in [dsInsert, dsEdit]) then
    begin
      cmb_tipo.Text           := DS.DataSet.FieldByName('TIPO').AsString;
      cmb_banco.Text          := DS.DataSet.FieldByName('NOME_BANCO').AsString;
      edt_saldo.Text          := DS.DataSet.FieldByName('SALDO').AsString;

      if (cmb_tipo.Text = 'BANCO') or (cmb_tipo.Text = 'POUPAN�A') or (cmb_tipo.Text = 'CART�O DE CR�DITO') then
          pn_banco.Visible  := True;

      if (cmb_tipo.Text = 'CARTEIRA') or (cmb_tipo.Text = 'OUTROS') or (cmb_tipo.Text = 'INVESTIMENTO') then
          pn_banco.Visible := False;

//      BField  := TBlobField(UniQuery.FieldByName('LOGO'));
//      Stream  := UniQuery.CreateBlobStream(BField, bmRead);
//      Png     := TPNGImage.Create;
//      try
//        Png.LoadFromStream(Stream);
//        img_banco.Picture.Graphic := Png;
//      finally
//        Stream.Free;
//        FreeAndNil(Png);
//      end;

    end;

end;

procedure TFormCad_Contas.DSStateChange(Sender: TObject);
var
  BField: TBlobField;
  Stream: TStream;
  Png   : TPNGImage;
begin
  inherited;
  if DS.DataSet.State in [dsInsert] then
    begin
      cmb_tipo.Enabled                          := True;
      cmb_banco.Enabled                         := True;
      edt_saldo.Enabled                         := True;
      spb_edita_saldo.Enabled                   := False;
      edt_saldo.Text                            := EmptyStr;
      DS.DataSet.FieldByName('ATIVO').AsString  := 'S';
      DS.DataSet.FieldByName('VISIVEL_GRAFICOS').AsString  := 'S';

      cmb_tipo.ItemIndex  := 0;

      if (cmb_tipo.Text = 'BANCO') or (cmb_tipo.Text = 'POUPAN�A') or (cmb_tipo.Text = 'CART�O DE CR�DITO') then
        begin
          pn_banco.Visible  := True;
          cmb_banco.Tag     := 1;
        end;

      if (cmb_tipo.Text = 'CARTEIRA') or (cmb_tipo.Text = 'OUTROS') or (cmb_tipo.Text = 'INVESTIMENTO') then
        begin
          pn_banco.Visible := False;
          cmb_banco.Tag     := 0;

          SQLQuery.SQL.Clear;
          SQLQuery.SQL.Add('SELECT PARAMETRO_BLOB FROM PARAMETROS        '+
                           ' WHERE MODULO = ''CONTAS''                   '+
                           '   AND TITULO = ''IMAGEM PADRAO CARTEIRA''   ');
          SQLQuery.Open;

//          BField  := TBlobField(SQLQuery.FieldByName('PARAMETRO_BLOB'));
//          Stream  := SQLQuery.CreateBlobStream(BField, bmRead);
//          Png     := TPNGImage.Create;
//          try
//            Png.LoadFromStream(Stream);
//            img_banco.Picture.Graphic := Png;
//          finally
//            Stream.Free;
//            FreeAndNil(Png);
//          end;

        end;

      DB_Descricao.SetFocus;
    end;

  if DS.DataSet.State in [dsEdit] then
    begin
      cmb_tipo.Enabled                  := False;
      cmb_banco.Enabled                 := False;
      edt_saldo.Enabled                 := False;
      spb_edita_saldo.Enabled           := True;

      cmb_banco.Value                   := DS.DataSet.FieldByName('ID_BANCOS').AsString;

      (DS.DataSet.FieldByName('SALDO') as TBCDField).DisplayFormat  := '';

      UniPageControl1.ActivePage        := Tab_Cadastro;
    end;

  if DS.DataSet.State in [dsBrowse] then
    begin
      (DS.DataSet.FieldByName('SALDO') as TBCDField).DisplayFormat  := 'R$ ###,##,0.00';
    end;
end;

procedure TFormCad_Contas.edt_pesq_descricaoKeyPress(Sender: TObject;
  var Key: Char);
begin
  inherited;
  if Key = '#13' then
    bt_pesquisa.Click;
end;

procedure TFormCad_Contas.edt_saldoExit(Sender: TObject);
begin
  inherited;
  FormataValor(TUniEdit(Sender));
end;

procedure TFormCad_Contas.spb_edita_saldoClick(Sender: TObject);
begin
  inherited;
  edt_saldo.Enabled := True;
end;

procedure TFormCad_Contas.UniDBGrid1ColumnSort(Column: TUniDBGridColumn;
  Direction: Boolean);
begin
  inherited;
  if Direction then
    (DS.DataSet as TADQuery).IndexFieldNames  := Column.FieldName+':A'
  else
    (DS.DataSet as TADQuery).IndexFieldNames  := Column.FieldName+':D';
end;

procedure TFormCad_Contas.UniDBGrid1DblClick(Sender: TObject);
begin
  inherited;
  DS.DataSet.Edit;
end;

procedure TFormCad_Contas.UniFormCreate(Sender: TObject);
begin
  inherited;
  {Cria uma Nova Sess�o no Banco de Dados (Utilizado pelas Transa��es)}
  Conexao := TADConnection.Create(Self);
  SessaoFireDac(TUniFrame(Self),Conexao,'utf8');

  Transaction         := TADTransaction.Create(Self);
  SQLQuery            := TADQuery.Create(Self);

  Seta_Conexao_FireDac(TUniFrame(Self), Conexao);

  ADQuery.Params[00].AsInteger  := ID.id_glo_master;
  ADQuery.Params[01].AsInteger  := ID.id_glo_empresa;

  {Carrega Todos os Bancos}
  combo(TUniForm(Self),cmb_banco,'BANCOS',Conexao);

end;

procedure TFormCad_Contas.UniQueryBeforePost(DataSet: TDataSet);
begin
  inherited;
  ShowMessage(ds.DataSet.FieldByName('id_contas').AsString);
end;

end.
