-- Active: 1677438272127@@127.0.0.1@3306
---------------------------------------------------------------------------------------------------
-- DICIONÁRIO DE DADOS
--
-- Objetivo: tabela com coluna de valor histórico do litro da gasolina e outra com o respectivo
--           valor corrigido pela inflação (trazido a valor presente)
--
-- Nível de observação: 1 comprador (coluna não evidenciada no conjunto de dados)
--                      2 id_municipio
--                      3 data_coleta (dd/mm/aaa)
--
---------------------------------------------------------------------------------------------------
-- CONSIDERAÇÕES E DETALHAMENTO
--
--     A query foi estruturada explorando o uso de CTE's através da cláusula WITH; o objetivo foi
-- evitar o uso de subquerys, com o objetivo de facilitar o entendimento do código por possuir uma
-- estrutura de fluxo contínuo e otimizar processamento das consulta.
--
--     Para atingir o objetivo é necessário viabilizar um join entre a tabela de gasolina com a
-- tabela de inflação por meio das datas. Por essa última possuir nível de observação sendo o mês,
-- foi necessário gerar uma coluna na tabela de gasolina que registre 'mm/yyyy'.
--
--     Outra necessidade é identificar qual a data da última venda, pois, para corrigir o preço
-- pela inflação, trazido a valor presente - sendo "presente" o período mais recente de venda -,
-- é necessário identificar o índice de inflação desse momento. É chamado de 'índice base'.
--     
-- Assim, o cálculo para correção é o seguinte:
--     1º passo > fator de correção = (índice base   ) ÷ (índice corrente   )
--     2º passo > correção inflação = (preço de litro) * (fator de correção )
---------------------------------------------------------------------------------------------------

WITH
    -- Tabela com o registro de vendas e valor do litro da gasolina
    -- Obs.: uma coluna foi criada, servirá para cruzamento futuro e para identificar qual é o
    -- índice base da inflação
    fato_gasolina AS (

        SELECT

            -- Coluna para identificar o mês e ano (yyyymm) mais recente em que há registro de venda
            STRFTIME( '%Y%m', data_coleta  ) AS ano_mes,
            data_coleta,
            id_municipio,
            preco_venda

        FROM gasolina
    ),

    -- Tabela com série temporal do índice de inflação
    -- Obs.: uma coluna foi criada, servirá para cruzamento futuro e para identificar qual é o
    -- índice base da inflação
    correcao_inf1 AS (

        SELECT

            -- Desenvolvendo coluna que registra o ano e mês
            STRFTIME(
                '%Y%m',
                -- Colunas originais ano e mês serão concatenadas e transformadas ('dd/mm/yyyy')
                ( ano || '-' || substr( '00'|| mes, -2, 2) || '-' || "01" )

            ) AS ano_mes,

            indice

        FROM inflacao
    ),

    -- Tabela que apenas consulta a CTE anterior e gera o 'fator de correção'
    -- Obs.: para identificar o índice base, fiz uma subquery procurando o índice na CTE anterior
    --       'correcao_inf1' onde na coluna ano_mes seja igual ao ano_mes mais recente da CTE
    --       'fato_gasolina'
    correcao_inf2 AS (
        
        SELECT

            ano_mes,
            (
                
                SELECT indice
                FROM   correcao_inf1
                WHERE  ano_mes = ( SELECT MAX( ano_mes ) FROM fato_gasolina )
            
            ) / indice AS correcao_inflacionaria

        FROM correcao_inf1
    )

-- Tabela final, atingindo o objetivo: coluna com preço do litro e outra com preço corrigido
SELECT
    
    gas.data_coleta,
    gas.preco_venda,
    gas.preco_venda * inf.correcao_inflacionaria AS preco_corrigido,
    geo.id_municipio_completo,
    geo.nome_municipio,
    geo.nome_uf,
    geo.sigla_uf,
    geo.regiao_uf

FROM fato_gasolina AS gas

LEFT JOIN correcao_inf2 AS inf
    ON gas.ano_mes = inf.ano_mes

LEFT JOIN geografia AS geo
    ON gas.id_municipio = geo.id_municipio_completo