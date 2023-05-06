# Análise do preço do litro da gasolina, ajustado à inflação

## 1 Descrição do projeto
	
	Análise exploratória do preço do litro da gasolina corrigido pela inflação,
	com os dados históricos dessas séries entre o período de jan/2005 e out/2021
	
## 2 Ferramentas e técnicas utilizadas
	
	VS Code
	Jupyter Notebook
	SQL
	Python 3.9.10

## 3 Objetivos do autor

	• Explorar formas de coletar dados (csv, html e data lake);
	
	• evitar o uso de arquivos csv, construindo uma solução simplificada de
      banco de dados do SQLite, centralizando as tabelas;
	
	• explorar o uso do SQl na etapa de tratamento dos dados, integrado com o
	  python.

## 4 Funcionamento do projeto


	4.1 Estrutura do projeto
	------

		O projeto foi desenvolvido dentro do ambiente do Visual Studio Code. O 
		python e as bibliotecas necessárias para funcionamento do projeto
		estão no ambiente virtual gerado pela pasta/repositório 'venv' - o
		detalhamento de todas as bibliotecas e suas versões estão no arquivo
		'requirements.txt'.

		O projeto está dividido em duas etapas:
			1º Coleta de dados;
			2º Análise de dados.
		
		Cada etapa possui sua própria pasta e dentro delas foi seguida a lógica
		de uso de arquivos auxiliares que serão lidos/consultados pelos scripts
		do jupyter notebook.
		
		A seguir, demonstro visualmente a relação de dependências dos arquivos
		por meio de uma matriz onde, nas colunas, há as pastas utilizadas no
		projeto e nas linhas há a natureza do arquivo - se ele é auxiliar ou
		principal (script jupyter); consequentemente, essa visualização
		demonstra o fluxo de trabalho para geração da análise exploratória.
	
![Imagem1](https://user-images.githubusercontent.com/126031404/223586057-3f24e4b2-e865-4410-bff7-b2ba4bbd34f5.png)
  
	4.2 Coleta de dados
	------

		Os dados extraídos são de duas fontes: site IBGE e Data Lake.

			A primeira disponibiliza um arquivo .zip com várias planilhas .xls,
			a respeito de informações geográficas do país onde escolhemos a de
			interesse (cidades) e a transformamos em arquivo .csv.

			O Data Lake é hospedado no Google Cloud, dentro do software BigQuery.
			Ele pertence a iniciativa Base dos dados, que criou uma biblioteca
			python que permite rodar query's em tabelas do DL por código;
			obs.: é necessário que o usuário tenha sua conta Google Cloud.

		Ao executar o primeiro código .ipynb, seja o arquivo de cidades ou as
		consultas no BigQuery, no fim será criado um banco de dados na pasta da
		2º etapa do projeto e os dados resultantes do script serão armazenados
		nele.

		Ao executar o 2º código .ipynb, ele automaticamente irá conectar com o
		banco de dados já criado na 1º execução do script e, por fim, armazenará
		os dados tratados nele.

		Buscou-se evitar o uso de arquivos csv no projeto, centralizando os dados
		em um banco de dados por meio do módulo sqlite3 no python.
	
	4.3 Análise dos dados
	------

		Estando as tabelas armazenadas no banco, uma query foi desenvolvida
		para consultá-las e retornar o Data Frame para início da análise no
		python.

## 5 Considerações

	Cada arquivo do projeto possui comentários e explicações sobre seu próprio
	funcionamento. Necessário esse aprofundamento em cada um para que haja
	completa compreensão do projeto.