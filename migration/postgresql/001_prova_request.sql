-- Prova pratica iDempiere - Solicitacao de Compra
-- Alvo: PostgreSQL / iDempiere 12 ou superior.
-- Execute conectado ao banco do iDempiere com o usuario adempiere.

BEGIN;

CREATE TABLE IF NOT EXISTS PROVA_Request (
    PROVA_Request_ID NUMERIC(10) NOT NULL,
    PROVA_Request_UU VARCHAR(36),
    AD_Client_ID NUMERIC(10) NOT NULL,
    AD_Org_ID NUMERIC(10) NOT NULL,
    IsActive CHAR(1) DEFAULT 'Y' NOT NULL CHECK (IsActive IN ('Y','N')),
    Created TIMESTAMP DEFAULT statement_timestamp() NOT NULL,
    CreatedBy NUMERIC(10) NOT NULL,
    Updated TIMESTAMP DEFAULT statement_timestamp() NOT NULL,
    UpdatedBy NUMERIC(10) NOT NULL,
    DocumentNo VARCHAR(30) NOT NULL,
    DateDoc TIMESTAMP NOT NULL,
    C_BPartner_ID NUMERIC(10) NOT NULL,
    M_Product_ID NUMERIC(10),
    Description VARCHAR(255),
    Qty NUMERIC DEFAULT 1 NOT NULL,
    PriceEntered NUMERIC DEFAULT 0 NOT NULL,
    GrandTotal NUMERIC DEFAULT 0 NOT NULL,
    Status CHAR(1) DEFAULT 'D' NOT NULL CHECK (Status IN ('D','A','R')),
    Processed CHAR(1) DEFAULT 'N' NOT NULL CHECK (Processed IN ('Y','N')),
    Approve CHAR(1) DEFAULT 'N' NOT NULL CHECK (Approve IN ('Y','N')),
    CONSTRAINT PROVA_Request_Key PRIMARY KEY (PROVA_Request_ID),
    CONSTRAINT PROVA_Request_UU_idx UNIQUE (PROVA_Request_UU),
    CONSTRAINT ADClient_PROVARequest FOREIGN KEY (AD_Client_ID)
        REFERENCES AD_Client(AD_Client_ID) DEFERRABLE INITIALLY DEFERRED,
    CONSTRAINT ADOrg_PROVARequest FOREIGN KEY (AD_Org_ID)
        REFERENCES AD_Org(AD_Org_ID) DEFERRABLE INITIALLY DEFERRED,
    CONSTRAINT CBusinessPartner_PROVARequest FOREIGN KEY (C_BPartner_ID)
        REFERENCES C_BPartner(C_BPartner_ID) DEFERRABLE INITIALLY DEFERRED,
    CONSTRAINT MProduct_PROVARequest FOREIGN KEY (M_Product_ID)
        REFERENCES M_Product(M_Product_ID) DEFERRABLE INITIALLY DEFERRED
);

CREATE INDEX IF NOT EXISTS PROVA_Request_ClientDate
    ON PROVA_Request (AD_Client_ID, DateDoc);

DO $migration$
DECLARE
    v_table_id          NUMERIC;
    v_sequence_id       NUMERIC;
    v_reference_id      NUMERIC;
    v_window_id         NUMERIC;
    v_tab_id            NUMERIC;
    v_process_approve   NUMERIC;
    v_report_view_id    NUMERIC;
    v_print_format_id   NUMERIC;
    v_process_native    NUMERIC;
    v_process_jasper    NUMERIC;
    v_model_validator   NUMERIC;
    v_menu_id           NUMERIC;
    v_element_id        NUMERIC;
    v_column_id         NUMERIC;
    v_field_id          NUMERIC;
    v_item_id           NUMERIC;
    v_para_id           NUMERIC;
    v_seq               NUMERIC;
    v_print_seq         NUMERIC := 0;
    r                   RECORD;
BEGIN
    -- Tabela e sequencia ----------------------------------------------------
    SELECT AD_Table_ID INTO v_table_id
      FROM AD_Table WHERE lower(TableName) = lower('PROVA_Request');

    IF v_table_id IS NULL THEN
        SELECT nextid(AD_Sequence_ID::integer, 'N') INTO v_table_id
          FROM AD_Sequence WHERE Name = 'AD_Table';
        INSERT INTO AD_Table
            (AD_Table_ID, Name, TableName, LoadSeq, AccessLevel,
             AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy, Updated, UpdatedBy,
             IsSecurityEnabled, IsDeleteable, IsHighVolume, IsView, EntityType,
             ImportTable, IsChangeLog, ReplicationType, CopyColumnsFromTable,
             IsCentrallyMaintained, AD_Table_UU, Processing)
        VALUES
            (v_table_id, 'Solicitacao de Compra', 'PROVA_Request', 0, '3',
             0, 0, 'Y', statement_timestamp(), 100, statement_timestamp(), 100,
             'N', 'Y', 'N', 'N', 'U',
             'N', 'Y', 'L', 'N', 'Y', generate_uuid(statement_timestamp()), 'N');
    END IF;

    SELECT AD_Sequence_ID INTO v_sequence_id
      FROM AD_Sequence WHERE Name = 'PROVA_Request';
    IF v_sequence_id IS NULL THEN
        SELECT nextid(AD_Sequence_ID::integer, 'N') INTO v_sequence_id
          FROM AD_Sequence WHERE Name = 'AD_Sequence';
        INSERT INTO AD_Sequence
            (AD_Sequence_ID, Name, Description, CurrentNext, CurrentNextSys,
             IncrementNo, StartNo, IsAudited, StartNewYear, IsActive, IsTableID,
             IsAutoSequence, AD_Client_ID, AD_Org_ID, Created, CreatedBy, Updated,
             UpdatedBy, AD_Sequence_UU)
        VALUES
            (v_sequence_id, 'PROVA_Request', 'Sequencia da tabela PROVA_Request',
             1000000, 200000, 1, 1000000, 'N', 'N', 'Y', 'Y', 'Y',
             0, 0, statement_timestamp(), 100, statement_timestamp(), 100,
             generate_uuid(statement_timestamp()));
    END IF;

    -- Lista de status -------------------------------------------------------
    SELECT AD_Reference_ID INTO v_reference_id
      FROM AD_Reference WHERE Name = 'PROVA Request Status';
    IF v_reference_id IS NULL THEN
        SELECT nextid(AD_Sequence_ID::integer, 'N') INTO v_reference_id
          FROM AD_Sequence WHERE Name = 'AD_Reference';
        INSERT INTO AD_Reference
            (AD_Reference_ID, Name, ValidationType, AD_Client_ID, AD_Org_ID,
             IsActive, Created, CreatedBy, Updated, UpdatedBy, EntityType,
             IsOrderByValue, AD_Reference_UU)
        VALUES
            (v_reference_id, 'PROVA Request Status', 'L', 0, 0,
             'Y', statement_timestamp(), 100, statement_timestamp(), 100, 'U',
             'N', generate_uuid(statement_timestamp()));

        FOR r IN SELECT * FROM (VALUES
            ('Rascunho', 'D'), ('Aprovado', 'A'), ('Rejeitado', 'R')
        ) AS x(name, value)
        LOOP
            SELECT nextid(AD_Sequence_ID::integer, 'N') INTO v_seq
              FROM AD_Sequence WHERE Name = 'AD_Ref_List';
            INSERT INTO AD_Ref_List
                (AD_Ref_List_ID, Name, AD_Reference_ID, Value, AD_Client_ID,
                 AD_Org_ID, IsActive, Created, CreatedBy, Updated, UpdatedBy,
                 EntityType, AD_Ref_List_UU)
            VALUES
                (v_seq, r.name, v_reference_id, r.value, 0,
                 0, 'Y', statement_timestamp(), 100, statement_timestamp(), 100,
                 'U', generate_uuid(statement_timestamp()));
        END LOOP;
    END IF;

    -- Processo Java ---------------------------------------------------------
    SELECT AD_Process_ID INTO v_process_approve
      FROM AD_Process WHERE Value = 'PROVA_ApproveRequest';
    IF v_process_approve IS NULL THEN
        SELECT nextid(AD_Sequence_ID::integer, 'N') INTO v_process_approve
          FROM AD_Sequence WHERE Name = 'AD_Process';
        INSERT INTO AD_Process
            (AD_Process_ID, AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy,
             Updated, UpdatedBy, Name, Description, IsReport, Value, IsDirectPrint,
             AccessLevel, ClassName, EntityType, Statistic_Count, Statistic_Seconds,
             IsBetaFunctionality, ShowHelp, CopyFromProcess, AD_Process_UU)
        VALUES
            (v_process_approve, 0, 0, 'Y', statement_timestamp(), 100,
             statement_timestamp(), 100, 'Aprovar Solicitacao',
             'Valida, calcula o total e aprova a solicitacao selecionada.',
             'N', 'PROVA_ApproveRequest', 'N', '3',
             'br.com.prova.idempiere.process.ApproveRequest', 'U', 0, 0,
             'N', 'Y', 'N', generate_uuid(statement_timestamp()));
    END IF;

    -- Janela e aba ----------------------------------------------------------
    SELECT AD_Window_ID INTO v_window_id
      FROM AD_Window WHERE Name = 'Solicitacoes de Compra';
    IF v_window_id IS NULL THEN
        SELECT nextid(AD_Sequence_ID::integer, 'N') INTO v_window_id
          FROM AD_Sequence WHERE Name = 'AD_Window';
        INSERT INTO AD_Window
            (AD_Window_ID, Name, Description, AD_Client_ID, AD_Org_ID, IsActive,
             Created, CreatedBy, Updated, UpdatedBy, WindowType, Processing,
             EntityType, IsSOTrx, IsDefault, IsBetaFunctionality, AD_Window_UU)
        VALUES
            (v_window_id, 'Solicitacoes de Compra',
             'Cadastro e aprovacao de solicitacoes de compra.', 0, 0, 'Y',
             statement_timestamp(), 100, statement_timestamp(), 100, 'M', 'N',
             'U', 'N', 'N', 'N', generate_uuid(statement_timestamp()));
    END IF;

    SELECT AD_Tab_ID INTO v_tab_id
      FROM AD_Tab WHERE AD_Window_ID = v_window_id AND AD_Table_ID = v_table_id;
    IF v_tab_id IS NULL THEN
        SELECT nextid(AD_Sequence_ID::integer, 'N') INTO v_tab_id
          FROM AD_Sequence WHERE Name = 'AD_Tab';
        INSERT INTO AD_Tab
            (AD_Tab_ID, Name, Description, AD_Window_ID, SeqNo, IsSingleRow,
             AD_Table_ID, AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy,
             Updated, UpdatedBy, HasTree, IsTranslationTab, IsReadOnly,
             OrderByClause, Processing, TabLevel, IsSortTab, EntityType,
             IsInsertRecord, IsAdvancedTab, AD_Tab_UU)
        VALUES
            (v_tab_id, 'Solicitacao', 'Solicitacao de compra', v_window_id, 10, 'Y',
             v_table_id, 0, 0, 'Y', statement_timestamp(), 100,
             statement_timestamp(), 100, 'N', 'N', 'N',
             'PROVA_Request.DateDoc DESC, PROVA_Request.DocumentNo DESC',
             'N', 0, 'N', 'U', 'Y', 'N', generate_uuid(statement_timestamp()));
    END IF;

    -- Colunas e campos. A tabela VALUES tambem documenta o desenho da janela.
    FOR r IN SELECT * FROM (VALUES
      -- coluna, rotulo, ref, ref-valor, tamanho, obrig, default, chave, atualizavel,
      -- selecao, seq campo, grid, exibido, mesma linha, x, span, process
      ('PROVA_Request_ID','Solicitacao de Compra',13,NULL::NUMERIC,22,'Y',NULL,'Y','N','N',0,0,'N','N',1,2,NULL::NUMERIC),
      ('PROVA_Request_UU','PROVA_Request_UU',10,NULL::NUMERIC,36,'N',NULL,'N','N','N',0,0,'N','N',1,2,NULL::NUMERIC),
      ('AD_Client_ID','Tenant',19,NULL::NUMERIC,22,'Y','@#AD_Client_ID@','N','N','N',10,10,'Y','N',1,2,NULL::NUMERIC),
      ('AD_Org_ID','Organizacao',19,NULL::NUMERIC,22,'Y','@#AD_Org_ID@','N','Y','Y',20,20,'Y','Y',4,2,NULL::NUMERIC),
      ('DocumentNo','Documento',10,NULL::NUMERIC,30,'Y',NULL,'N','Y','Y',30,30,'Y','N',1,2,NULL::NUMERIC),
      ('DateDoc','Data da Solicitacao',15,NULL::NUMERIC,7,'Y','@#Date@','N','Y','Y',40,40,'Y','Y',4,2,NULL::NUMERIC),
      ('C_BPartner_ID','Parceiro de Negocio',19,NULL::NUMERIC,22,'Y',NULL,'N','Y','Y',50,50,'Y','N',1,2,NULL::NUMERIC),
      ('M_Product_ID','Produto',19,NULL::NUMERIC,22,'N',NULL,'N','Y','Y',60,60,'Y','Y',4,2,NULL::NUMERIC),
      ('Description','Descricao',14,NULL::NUMERIC,255,'N',NULL,'N','Y','N',70,70,'Y','N',1,5,NULL::NUMERIC),
      ('Qty','Quantidade',29,NULL::NUMERIC,22,'Y','1','N','Y','N',80,80,'Y','N',1,2,NULL::NUMERIC),
      ('PriceEntered','Preco Unitario',12,NULL::NUMERIC,22,'Y','0','N','Y','N',90,90,'Y','Y',4,2,NULL::NUMERIC),
      ('GrandTotal','Valor Total',12,NULL::NUMERIC,22,'Y','0','N','N','N',100,100,'Y','N',1,2,NULL::NUMERIC),
      ('Status','Status',17,v_reference_id,1,'Y','D','N','N','Y',110,110,'Y','Y',4,2,NULL::NUMERIC),
      ('Processed','Processado',20,NULL::NUMERIC,1,'Y','N','N','N','N',120,120,'Y','N',1,2,NULL::NUMERIC),
      ('Approve','Aprovar',28,NULL::NUMERIC,1,'Y','N','N','Y','N',130,130,'Y','Y',4,2,v_process_approve),
      ('IsActive','Ativo',20,NULL::NUMERIC,1,'Y','Y','N','Y','N',140,140,'Y','N',1,2,NULL::NUMERIC),
      ('Created','Criado em',16,NULL::NUMERIC,7,'Y','SYSDATE','N','N','N',0,0,'N','N',1,2,NULL::NUMERIC),
      ('CreatedBy','Criado por',18,110::NUMERIC,22,'Y',NULL,'N','N','N',0,0,'N','N',1,2,NULL::NUMERIC),
      ('Updated','Atualizado em',16,NULL::NUMERIC,7,'Y','SYSDATE','N','N','N',0,0,'N','N',1,2,NULL::NUMERIC),
      ('UpdatedBy','Atualizado por',18,110::NUMERIC,22,'Y',NULL,'N','N','N',0,0,'N','N',1,2,NULL::NUMERIC)
    ) AS c(column_name, label, reference_id, reference_value_id, field_length,
           mandatory, default_value, is_key, updateable, selection_column,
           field_seq, grid_seq, displayed, same_line, xpos, column_span, process_id)
    LOOP
        SELECT AD_Element_ID INTO v_element_id
          FROM AD_Element
         WHERE lower(ColumnName) = lower(r.column_name)
         ORDER BY CASE WHEN EntityType IN ('D','A') THEN 0 ELSE 1 END, AD_Element_ID
         LIMIT 1;

        IF v_element_id IS NULL THEN
            SELECT nextid(AD_Sequence_ID::integer, 'N') INTO v_element_id
              FROM AD_Sequence WHERE Name = 'AD_Element';
            INSERT INTO AD_Element
                (AD_Element_ID, AD_Client_ID, AD_Org_ID, IsActive, Created,
                 CreatedBy, Updated, UpdatedBy, ColumnName, Name, PrintName,
                 EntityType, AD_Element_UU)
            VALUES
                (v_element_id, 0, 0, 'Y', statement_timestamp(),
                 100, statement_timestamp(), 100, r.column_name, r.label, r.label,
                 'U', generate_uuid(statement_timestamp()));
        END IF;

        SELECT AD_Column_ID INTO v_column_id
          FROM AD_Column
         WHERE AD_Table_ID = v_table_id AND lower(ColumnName) = lower(r.column_name);

        IF v_column_id IS NULL THEN
            SELECT nextid(AD_Sequence_ID::integer, 'N') INTO v_column_id
              FROM AD_Sequence WHERE Name = 'AD_Column';
            INSERT INTO AD_Column
                (AD_Column_ID, Version, Name, AD_Table_ID, ColumnName, DefaultValue,
                 FieldLength, IsKey, IsParent, IsMandatory, IsTranslated,
                 IsIdentifier, SeqNo, IsEncrypted, AD_Reference_ID,
                 AD_Reference_Value_ID, AD_Client_ID, AD_Org_ID, IsActive,
                 Created, CreatedBy, Updated, UpdatedBy, AD_Element_ID,
                 IsUpdateable, IsSelectionColumn, EntityType, IsSyncDatabase,
                 IsAlwaysUpdateable, IsAutocomplete, IsAllowLogging, AD_Column_UU,
                 IsAllowCopy, SeqNoSelection, IsToolbarButton, IsSecure,
                 FKConstraintType, IsHtml, AD_Process_ID)
            VALUES
                (v_column_id, 0, r.label, v_table_id, r.column_name, r.default_value,
                 r.field_length, r.is_key, 'N', r.mandatory, 'N',
                 CASE WHEN r.column_name = 'DocumentNo' THEN 'Y' ELSE 'N' END,
                 CASE WHEN r.column_name = 'DocumentNo' THEN 1 ELSE 0 END,
                 'N', r.reference_id, r.reference_value_id, 0, 0, 'Y',
                 statement_timestamp(), 100, statement_timestamp(), 100, v_element_id,
                 r.updateable, r.selection_column, 'U', 'N',
                 'N', 'N', 'Y', generate_uuid(statement_timestamp()),
                 'Y', CASE WHEN r.selection_column='Y' THEN r.field_seq ELSE 0 END,
                 'N', 'N',
                 'N', 'N', r.process_id);
        END IF;

        SELECT AD_Field_ID INTO v_field_id
          FROM AD_Field WHERE AD_Tab_ID = v_tab_id AND AD_Column_ID = v_column_id;
        IF v_field_id IS NULL THEN
            SELECT nextid(AD_Sequence_ID::integer, 'N') INTO v_field_id
              FROM AD_Sequence WHERE Name = 'AD_Field';
            INSERT INTO AD_Field
                (AD_Field_ID, Name, AD_Tab_ID, AD_Column_ID,
                 IsDisplayed, DisplayLength, SeqNo, IsSameLine, IsHeading,
                 IsFieldOnly, IsEncrypted, AD_Client_ID, AD_Org_ID, IsActive,
                 Created, CreatedBy, Updated, UpdatedBy, IsReadOnly,
                 IsCentrallyMaintained, EntityType, AD_Field_UU, IsDisplayedGrid,
                 SeqNoGrid, XPosition, ColumnSpan)
            VALUES
                (v_field_id, r.label, v_tab_id, v_column_id,
                 r.displayed, r.field_length, r.field_seq, r.same_line, 'N',
                 'N', 'N', 0, 0, 'Y', statement_timestamp(), 100,
                 statement_timestamp(), 100,
                 CASE WHEN r.updateable='N' THEN 'Y' ELSE 'N' END,
                 'Y', 'U', generate_uuid(statement_timestamp()), r.displayed,
                 r.grid_seq, r.xpos, r.column_span);
        END IF;
    END LOOP;

    UPDATE AD_Field f
       SET ReadOnlyLogic='@Processed@=Y', Updated=statement_timestamp(), UpdatedBy=100
      FROM AD_Column c
     WHERE f.AD_Column_ID=c.AD_Column_ID AND f.AD_Tab_ID=v_tab_id
       AND c.ColumnName IN ('DocumentNo','DateDoc','C_BPartner_ID','M_Product_ID',
                            'Description','Qty','PriceEntered');
    UPDATE AD_Field f
       SET DisplayLogic='@Processed@=N', Updated=statement_timestamp(), UpdatedBy=100
      FROM AD_Column c
     WHERE f.AD_Column_ID=c.AD_Column_ID AND f.AD_Tab_ID=v_tab_id
       AND c.ColumnName='Approve';
    -- O botao deve aparecer dentro da janela.  "Y" significa somente toolbar
    -- e, sem uma configuracao de toolbar dedicada, torna o processo invisivel.
    UPDATE AD_Column
       SET IsToolbarButton='N', Updated=statement_timestamp(), UpdatedBy=100
     WHERE AD_Table_ID=v_table_id AND ColumnName='Approve';

    -- Report View e formato nativo -----------------------------------------
    SELECT AD_ReportView_ID INTO v_report_view_id
      FROM AD_ReportView WHERE Name = 'PROVA Request Report View';
    IF v_report_view_id IS NULL THEN
        SELECT nextid(AD_Sequence_ID::integer, 'N') INTO v_report_view_id
          FROM AD_Sequence WHERE Name = 'AD_ReportView';
        INSERT INTO AD_ReportView
            (AD_ReportView_ID, Name, Description, AD_Table_ID, AD_Client_ID,
             AD_Org_ID, IsActive, Created, CreatedBy, Updated, UpdatedBy,
             EntityType, OrderByClause, AD_ReportView_UU)
        VALUES
            (v_report_view_id, 'PROVA Request Report View',
             'Visao nativa das solicitacoes de compra.', v_table_id, 0,
             0, 'Y', statement_timestamp(), 100, statement_timestamp(), 100,
             'U', 'PROVA_Request.DateDoc, PROVA_Request.DocumentNo', generate_uuid(statement_timestamp()));
    END IF;

    SELECT AD_PrintFormat_ID INTO v_print_format_id
      FROM AD_PrintFormat WHERE Name = 'PROVA Solicitacoes de Compra';
    IF v_print_format_id IS NULL THEN
        SELECT nextid(AD_Sequence_ID::integer, 'N') INTO v_print_format_id
          FROM AD_Sequence WHERE Name = 'AD_PrintFormat';
        INSERT INTO AD_PrintFormat
            (AD_PrintFormat_ID, Name, IsTableBased, IsActive,
             IsStandardHeaderFooter, AD_PrintFont_ID, AD_PrintColor_ID,
             AD_PrintPaper_ID, AD_Table_ID, AD_ReportView_ID, IsForm,
             HeaderMargin, FooterMargin, IsDefault, AD_Client_ID, AD_Org_ID,
             Created, CreatedBy, Updated, UpdatedBy, AD_PrintFormat_UU)
        VALUES
            (v_print_format_id, 'PROVA Solicitacoes de Compra', 'Y', 'Y',
             'Y', 130, 100, 100, v_table_id, v_report_view_id, 'N',
             0, 0, 'Y', 0, 0, statement_timestamp(), 100,
             statement_timestamp(), 100, generate_uuid(statement_timestamp()));

        FOR r IN
          SELECT c.AD_Column_ID, c.Name, c.ColumnName
            FROM AD_Column c
           WHERE c.AD_Table_ID=v_table_id
             AND c.ColumnName IN ('DocumentNo','DateDoc','C_BPartner_ID',
                                  'M_Product_ID','Qty','PriceEntered','GrandTotal','Status')
           ORDER BY CASE c.ColumnName
             WHEN 'DocumentNo' THEN 1 WHEN 'DateDoc' THEN 2
             WHEN 'C_BPartner_ID' THEN 3 WHEN 'M_Product_ID' THEN 4
             WHEN 'Qty' THEN 5 WHEN 'PriceEntered' THEN 6
             WHEN 'GrandTotal' THEN 7 WHEN 'Status' THEN 8 END
        LOOP
            v_print_seq := v_print_seq + 10;
            SELECT nextid(AD_Sequence_ID::integer, 'N') INTO v_item_id
              FROM AD_Sequence WHERE Name = 'AD_PrintFormatItem';
            INSERT INTO AD_PrintFormatItem
                (AD_PrintFormatItem_ID, AD_PrintFormat_ID, AD_Column_ID, SeqNo,
                 Name, PrintName, IsNextLine, YSpace, SortNo, IsPageBreak,
                 IsRelativePosition, MaxWidth, IsSummarized, YPosition, XSpace,
                 IsActive, IsHeightOneLine, MaxHeight, XPosition,
                 FieldAlignmentType, IsPrinted, IsOrderBy, IsGroupBy,
                 LineAlignmentType, PrintFormatType, PrintAreaType,
                 ImageIsAttached, IsCounted, IsAveraged, IsSuppressNull,
                 IsSetNLPosition, IsNextPage, IsFixedWidth, IsMaxCalc,
                 IsRunningTotal, IsMinCalc, IsVarianceCalc, IsDeviationCalc,
                 IsFilledRectangle, LineWidth, ArcDiameter, ShapeType,
                 IsCentrallyMaintained, IsImageField, AD_Client_ID, AD_Org_ID,
                 Created, CreatedBy, Updated, UpdatedBy, AD_PrintFormatItem_UU)
            VALUES
                (v_item_id, v_print_format_id, r.AD_Column_ID, v_print_seq,
                 r.Name, r.Name, 'N', 0,
                 CASE WHEN r.ColumnName IN ('DateDoc','DocumentNo') THEN v_print_seq ELSE 0 END,
                 'N', 'Y', 0,
                 CASE WHEN r.ColumnName='GrandTotal' THEN 'Y' ELSE 'N' END,
                 0, 0, 'Y', 'N', 0, 0,
                 CASE WHEN r.ColumnName IN ('Qty','PriceEntered','GrandTotal') THEN 'T' ELSE 'L' END,
                 'Y',
                 CASE WHEN r.ColumnName IN ('DateDoc','DocumentNo') THEN 'Y' ELSE 'N' END,
                 'N', 'X', 'F', 'C', 'N', 'N', 'N', 'N', 'N', 'N', 'N',
                 'N', 'N', 'N', 'N', 'N', 'N', 1, 0, 'N', 'Y', 'N',
                 0, 0, statement_timestamp(), 100, statement_timestamp(), 100,
                 generate_uuid(statement_timestamp()));
        END LOOP;
    END IF;

    -- Processos de relatorio -----------------------------------------------
    SELECT AD_Process_ID INTO v_process_native
      FROM AD_Process WHERE Value = 'PROVA_Request_NativeReport';
    IF v_process_native IS NULL THEN
        SELECT nextid(AD_Sequence_ID::integer, 'N') INTO v_process_native
          FROM AD_Sequence WHERE Name = 'AD_Process';
        INSERT INTO AD_Process
            (AD_Process_ID, AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy,
             Updated, UpdatedBy, Name, Description, IsReport, Value, IsDirectPrint,
             AccessLevel, AD_ReportView_ID, AD_PrintFormat_ID, EntityType,
             Statistic_Count, Statistic_Seconds, IsBetaFunctionality, ShowHelp,
             CopyFromProcess, AD_Process_UU)
        VALUES
            (v_process_native, 0, 0, 'Y', statement_timestamp(), 100,
             statement_timestamp(), 100, 'Solicitacoes de Compra - Nativo',
             'Relatorio parametrizado no motor nativo do iDempiere.',
             'Y', 'PROVA_Request_NativeReport', 'N', '3', v_report_view_id,
             v_print_format_id, 'U', 0, 0, 'N', 'Y', 'N', generate_uuid(statement_timestamp()));
    END IF;

    SELECT AD_Process_ID INTO v_process_jasper
      FROM AD_Process WHERE Value = 'PROVA_Request_JasperReport';
    IF v_process_jasper IS NULL THEN
        SELECT nextid(AD_Sequence_ID::integer, 'N') INTO v_process_jasper
          FROM AD_Sequence WHERE Name = 'AD_Process';
        INSERT INTO AD_Process
            (AD_Process_ID, AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy,
             Updated, UpdatedBy, Name, Description, IsReport, Value, IsDirectPrint,
             AccessLevel, ClassName, JasperReport, EntityType, Statistic_Count,
             Statistic_Seconds, IsBetaFunctionality, ShowHelp, CopyFromProcess,
             AD_Process_UU)
        VALUES
            (v_process_jasper, 0, 0, 'Y', statement_timestamp(), 100,
             statement_timestamp(), 100, 'Solicitacoes de Compra - Jasper',
             'Relatorio Jasper parametrizado por periodo e status.',
             'Y', 'PROVA_Request_JasperReport', 'N', '3',
             'org.adempiere.report.jasper.ReportStarter',
             'resource:br.com.prova.idempiere:reports/PROVA_Request.jrxml',
             'U', 0, 0, 'N', 'Y', 'N', generate_uuid(statement_timestamp()));
    END IF;

    -- Mesmos parametros nos dois motores: periodo (range) e status.
    FOR r IN SELECT * FROM (VALUES
        (v_process_native), (v_process_jasper)
    ) AS p(process_id)
    LOOP
        IF NOT EXISTS (SELECT 1 FROM AD_Process_Para
                        WHERE AD_Process_ID=r.process_id AND ColumnName='DateDoc') THEN
            SELECT nextid(AD_Sequence_ID::integer, 'N') INTO v_para_id
              FROM AD_Sequence WHERE Name = 'AD_Process_Para';
            SELECT AD_Element_ID INTO v_element_id FROM AD_Element
             WHERE ColumnName='DateDoc' ORDER BY AD_Element_ID LIMIT 1;
            INSERT INTO AD_Process_Para
                (AD_Process_Para_ID, AD_Client_ID, AD_Org_ID, IsActive, Created,
                 CreatedBy, Updated, UpdatedBy, Name, Description, AD_Process_ID,
                 SeqNo, AD_Reference_ID, IsRange, FieldLength, IsMandatory,
                 ColumnName, IsCentrallyMaintained, EntityType, AD_Element_ID,
                 AD_Process_Para_UU, IsEncrypted, IsAutocomplete, DateRangeOption)
            VALUES
                (v_para_id, 0, 0, 'Y', statement_timestamp(), 100,
                 statement_timestamp(), 100, 'Periodo', 'Periodo da solicitacao.',
                 r.process_id, 10, 15, 'Y', 7, 'N', 'DateDoc', 'Y', 'U',
                 v_element_id, generate_uuid(statement_timestamp()), 'N', 'N', 'D');
        END IF;

        IF NOT EXISTS (SELECT 1 FROM AD_Process_Para
                        WHERE AD_Process_ID=r.process_id AND ColumnName='Status') THEN
            SELECT nextid(AD_Sequence_ID::integer, 'N') INTO v_para_id
              FROM AD_Sequence WHERE Name = 'AD_Process_Para';
            SELECT AD_Element_ID INTO v_element_id FROM AD_Element
             WHERE lower(ColumnName)=lower('Status') ORDER BY AD_Element_ID LIMIT 1;
            INSERT INTO AD_Process_Para
                (AD_Process_Para_ID, AD_Client_ID, AD_Org_ID, IsActive, Created,
                 CreatedBy, Updated, UpdatedBy, Name, Description, AD_Process_ID,
                 SeqNo, AD_Reference_ID, AD_Reference_Value_ID, IsRange,
                 FieldLength, IsMandatory, ColumnName, IsCentrallyMaintained,
                 EntityType, AD_Element_ID, AD_Process_Para_UU, IsEncrypted,
                 IsAutocomplete)
            VALUES
                (v_para_id, 0, 0, 'Y', statement_timestamp(), 100,
                 statement_timestamp(), 100, 'Status', 'Status da solicitacao.',
                 r.process_id, 20, 17, v_reference_id, 'N', 1, 'N', 'Status',
                 'Y', 'U', v_element_id, generate_uuid(statement_timestamp()), 'N', 'N');
        END IF;
    END LOOP;

    -- Model Validator global -----------------------------------------------
    SELECT AD_ModelValidator_ID INTO v_model_validator
      FROM AD_ModelValidator
     WHERE ModelValidationClass='br.com.prova.idempiere.validator.RequestModelValidator';
    IF v_model_validator IS NULL THEN
        SELECT nextid(AD_Sequence_ID::integer, 'N') INTO v_model_validator
          FROM AD_Sequence WHERE Name = 'AD_ModelValidator';
        INSERT INTO AD_ModelValidator
            (AD_ModelValidator_ID, AD_Client_ID, AD_Org_ID, IsActive, Created,
             CreatedBy, Updated, UpdatedBy, Name, Description,
             ModelValidationClass, SeqNo, EntityType, AD_ModelValidator_UU)
        VALUES
            (v_model_validator, 0, 0, 'Y', statement_timestamp(), 100,
             statement_timestamp(), 100, 'PROVA Request Validator',
             'Valida valores e bloqueia alteracoes depois da aprovacao.',
             'br.com.prova.idempiere.validator.RequestModelValidator', 100, 'U', generate_uuid(statement_timestamp()));
    END IF;

    -- Menus ----------------------------------------------------------------
    FOR r IN SELECT * FROM (VALUES
        ('Solicitacoes de Compra', 'W', v_window_id, NULL::NUMERIC),
        ('Solicitacoes de Compra - Relatorio Nativo', 'P', NULL::NUMERIC, v_process_native),
        ('Solicitacoes de Compra - Jasper', 'P', NULL::NUMERIC, v_process_jasper)
    ) AS m(name, action, window_id, process_id)
    LOOP
        SELECT AD_Menu_ID INTO v_menu_id FROM AD_Menu WHERE Name=r.name;
        IF v_menu_id IS NULL THEN
            SELECT nextid(AD_Sequence_ID::integer, 'N') INTO v_menu_id
              FROM AD_Sequence WHERE Name = 'AD_Menu';
            INSERT INTO AD_Menu
                (AD_Menu_ID, Name, Action, AD_Window_ID, AD_Process_ID,
                 AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy, Updated,
                 UpdatedBy, IsSummary, IsSOTrx, IsReadOnly, EntityType,
                 IsCentrallyMaintained, AD_Menu_UU)
            VALUES
                (v_menu_id, r.name, r.action, r.window_id, r.process_id,
                 0, 0, 'Y', statement_timestamp(), 100, statement_timestamp(),
                 100, 'N', 'N', 'N', 'U', 'Y', generate_uuid(statement_timestamp()));

            INSERT INTO AD_TreeNodeMM
                (AD_Client_ID, AD_Org_ID, IsActive, Created, CreatedBy, Updated,
                 UpdatedBy, AD_Tree_ID, Node_ID, Parent_ID, SeqNo, AD_TreeNodeMM_UU)
            SELECT t.AD_Client_ID, 0, 'Y', statement_timestamp(), 100,
                   statement_timestamp(), 100, t.AD_Tree_ID, v_menu_id, 0, 999,
                   generate_uuid(statement_timestamp())
              FROM AD_Tree t
             WHERE t.AD_Client_ID=0 AND t.IsActive='Y' AND t.IsAllNodes='Y'
               AND t.TreeType='MM'
               AND NOT EXISTS (SELECT 1 FROM AD_TreeNodeMM n
                                WHERE n.AD_Tree_ID=t.AD_Tree_ID
                                  AND n.Node_ID=v_menu_id);
        END IF;
    END LOOP;

END
$migration$;

COMMIT;

