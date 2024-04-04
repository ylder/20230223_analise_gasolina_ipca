# Análise do preço do litro da gasolina, ajustado à inflação

## 1 Descrição do projeto
	
	Demonstrativo da evolução do preço do litro da gasolina corrigido pela
	inflação, com dados históricos do período de jan/2005 até dez/2022.

	Dados coletados por meio de consulta ao Data Lake público da iniciativa
	base dos dados (Google BigQuery) e requisição de API públicade do IBGE
	de localidades localidades brasileiras.

	
## 2 Ferramentas e técnicas utilizadas
	
	VS Code
	Google Big Query
	Duckdb
	Python 3.10.5

## 3 Objetivos do autor

	• desenvolver solução completa, desde a etapa de ETL até a visualização;

	• utlizar dados públicos e conceitos da economia;

	• evitar o uso de arquivos csv, construindo uma solução simplificada de
      banco de dados com duckdb, centralizando as tabelas;
	
	• explorar o uso do SQl na etapa de tratamento dos dados, integrado com o
	  python.

## 4 Funcionamento do projeto


	4.1 Estrutura do projeto
	------

		O projeto foi desenvolvido dentro do ambiente do Visual Studio
		Code e posteriormente no Power BI.

		O ETL será realizada com a excecução do arquivo './src/etl.py'.
		Ele inicia o processo de extração e inserção dos dados no banco,
		posteriormente ativa a etapa de transformação e carregamento.

		O resultado é a criação de 3 tabelas no banco e uma view. Sendo as
		primeiras as tabelas advindas do data lake e 1 da API IBGE. A view é a
		tabela tratada que será usada para consumo.

		As tabelas hospedadas no Data Lake da Base dos dados, exige procedimento
		prévio para sua coleta:

		Para realizar consulta, é necessário uma conta no Google Cloud, para ter
		acesso ao Google BigQuery. Após isso, com a criação de um projeto no
		Google Cloud, deverá registrar o ID do projeto em um arquivo '.env', no
		diretório principal do projeto.

		Dentro do arquivo '.env' deve conter apenas:
			
			PROJECT_ID_GOOGLE_CLOUD = <seu_ID_projeto_aqui-00000000>

		Após isso, basta executar o script e realizar o etl.
