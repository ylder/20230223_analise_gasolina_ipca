-- Objetivo: consultar dados de vendas de combustíveis de distribuidores
-- Nível de observação: comprador, data_coleta (dd/mm/aaa), id_municipio
SELECT
    data_coleta,
    id_municipio,
    preco_venda

FROM
    `basedosdados.br_anp_precos_combustiveis.microdados`

WHERE
    ( ano BETWEEN 2005 AND 2021 ) AND produto = 'gasolina'