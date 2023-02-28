---------------------------------------------------------------------------------------------------
-- DICIONÁRIO DE DADOS
--
-- Objetivo: tabela com todas as cidades do Brasil seus estados e região correspondente
---------------------------------------------------------------------------------------------------

SELECT
    id_municipio_completo,
    nome_municipio,
    nome_uf,
    sigla_uf,
    regiao_uf
FROM
    geografia