-- Active: 1677438272127@@127.0.0.1@3306

WITH
    fato_gasolina AS (

        SELECT
            -- Coluna criada para viabilizar join com dados de inflacao
            STRFTIME( '%m/%Y', data_coleta ) AS mes_ano,
            -- Coluna criada para identificar o mês e ano mais recente em que há registro de venda
            STRFTIME( '%Y%m', data_coleta  ) AS ano_mes,
            data_coleta,
            id_municipio,
            preco_venda

        FROM gasolina
    ),

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

SELECT
    gas.data_coleta,
    gas.id_municipio,
    gas.preco_venda,
    gas.preco_venda * inf.correcao_inflacionaria AS preco_corrigido

FROM fato_gasolina AS gas

LEFT JOIN correcao_inf2 AS inf
    ON gas.mes_ano = inf.mes_ano