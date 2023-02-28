---------------------------------------------------------------------------------------------------
-- DICIONÁRIO DE DADOS
--
-- Objetivo: tabela com coluna de valor histórico do litro da gasolina e outra com o respectivo
--           valor corrigido pela inflação (trazido a valor presente)
--
-- Nível de observação: 1 id_municipio
--                      2 data_coleta (dd/mm/aaa)
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
-- é necessário identificar o índice de inflação desse período. É chamado de 'índice base'
--     
-- Assim, o cálculo para correção é o seguinte:
--     1º passo > fator de correção = (índice base   ) ÷ (índice mais antigo)
--     2º passo > correção inflação = (preço de litro) * (fator de correção )
---------------------------------------------------------------------------------------------------

WITH
    -- Tabela com o registro de vendas e valor do litro da gasolina
    -- Obs.: duas colunas de data foram criadas, uma para cruzamento futuro e outra para identificar
    --       qual é o índice base da inflação
    fato_gasolina AS (

        SELECT
            
            -- Desenvolvendo coluna que registra o mês e ano (mm/yyy)
            -- Obs.: coluna para viabilizar join com dados de inflação
            STRFTIME( '%m/%Y', data_coleta ) AS mes_ano,
            
            -- Coluna para identificar o mês e ano (yyyymm) mais recente em que há registro de venda
            STRFTIME( '%Y%m', data_coleta  ) AS ano_mes,
            
            data_coleta,
            id_municipio,
            preco_venda

        FROM gasolina
    ),

    -- Tabela com série temporal do índice de inflação
    -- Obs.: duas colunas de data foram criadas, uma para cruzamento futuro e outra para identificar
    --       qual é o índice base da inflação
    correcao_inf1 AS (

        SELECT
            
            -- Desenvolvendo coluna que registra o mês e o ano
            STRFTIME(
                '%m/%Y',
                -- Colunas originais ano e mês serão concatenadas e transformadas 'dd/mm/yyyy'
                ( ano || '-' || substr( '00'|| mes, -2, 2) || '-' || "01" )

            ) AS mes_ano,

            -- Desenvolvendo coluna que registra o ano e mês
            STRFTIME(
                '%Y%m',
                -- Colunas originais ano e mês serão concatenadas e transformadas 'dd/mm/yyyy'
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
            
            mes_ano,
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
    gas.id_municipio,
    gas.preco_venda,
    gas.preco_venda * inf.correcao_inflacionaria AS preco_corrigido

FROM fato_gasolina AS gas

LEFT JOIN correcao_inf2 AS inf
    ON gas.mes_ano = inf.mes_ano