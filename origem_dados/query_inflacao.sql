---------------------------------------------------------------------------------------------------
-- DICIONÁRIO DE DADOS
--
-- Objetivo: consultar o histórico do índice de inflação mensal
-- Nível de observação: mes, ano
---------------------------------------------------------------------------------------------------
SELECT
    ano,
    mes,
    indice

FROM
    `basedosdados.br_ibge_ipca.mes_brasil`

WHERE
    ano BETWEEN 2005 AND 2021