---------------------------------------------------------------------------------------------------
-- DICIONÁRIO DE DADOS
--
-- Objetivo: consultar dados de vendas de combustíveis de distribuidores
-- Nível de observação: 1 comprador (coluna não evidenciada no conjunto de dados)
--                      2 data_coleta (dd/mm/aaa)
--                      3 id_municipio
---------------------------------------------------------------------------------------------------

SELECT
    data_coleta,
    id_municipio,
    preco_venda

FROM
    `basedosdados.br_anp_precos_combustiveis.microdados`

WHERE
    ( ano BETWEEN 2005 AND 2021 ) AND produto = 'gasolina'