-- Verificacao somente-leitura apos instalar 001_prova_request.sql.
SELECT 'Tabela AD' AS item, COUNT(*) AS quantidade
  FROM AD_Table WHERE lower(TableName)=lower('PROVA_Request')
UNION ALL
SELECT 'Colunas AD', COUNT(*)
  FROM AD_Column WHERE AD_Table_ID=(SELECT AD_Table_ID FROM AD_Table
                                    WHERE lower(TableName)=lower('PROVA_Request'))
UNION ALL
SELECT 'Janela', COUNT(*) FROM AD_Window WHERE Name='Solicitacoes de Compra'
UNION ALL
SELECT 'Processos', COUNT(*) FROM AD_Process WHERE Value LIKE 'PROVA_Request_%'
                                                  OR Value='PROVA_ApproveRequest'
UNION ALL
SELECT 'Model Validator', COUNT(*) FROM AD_ModelValidator
 WHERE ModelValidationClass='br.com.prova.idempiere.validator.RequestModelValidator'
   AND IsActive='Y'
UNION ALL
SELECT 'Menus', COUNT(*) FROM AD_Menu WHERE Name LIKE 'Solicitacoes de Compra%'
UNION ALL
SELECT 'Botao Aprovar no formulario', COUNT(*)
  FROM AD_Column
 WHERE AD_Table_ID=(SELECT AD_Table_ID FROM AD_Table
                     WHERE lower(TableName)=lower('PROVA_Request'))
   AND ColumnName='Approve'
   AND IsToolbarButton='N';

