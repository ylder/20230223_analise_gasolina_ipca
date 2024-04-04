CREATE TABLE IF NOT EXISTS gasoline (
    data_coleta DATE,
    id_municipio VARCHAR,
    preco_venda DOUBLE
);

TRUNCATE gasoline;

CREATE TABLE IF NOT EXISTS inflation (
    ano INTEGER,
    mes INTEGER,
    indice DOUBLE
);

TRUNCATE inflation;

CREATE TABLE IF NOT EXISTS cities (
    municipio_id VARCHAR,
    municipio_nome VARCHAR,
    microrregiao_id VARCHAR,
    microrregiao_nome VARCHAR,
    mesorregiao_id VARCHAR,
    mesorregiao_nome VARCHAR,
    regiao_imediata_id VARCHAR,
    regiao_imediata_nome VARCHAR,
    regiao_intermediaria_id VARCHAR,
    regiao_intermediaria_nome VARCHAR,
    UF_id VARCHAR,
    UF_sigla VARCHAR,
    UF_nome VARCHAR,
    regiao_id VARCHAR,
    regiao_sigla VARCHAR,
    regiao_nome VARCHAR
);

TRUNCATE cities;