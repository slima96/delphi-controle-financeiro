CREATE TABLE [TAB-CATEGORIA] (
    ID_CATEGORIA INTEGER      PRIMARY KEY AUTOINCREMENT,
    DESCRICAO    VARCHAR (50) 
);

CREATE TABLE TAB_LANCAMENTO (
    ID_LANCAMENTO INTEGER        PRIMARY KEY AUTOINCREMENT,
    ID_CATEGORIA  INTEGER        REFERENCES TAB_CATEGORIA (ID_CATEGORIA),
    VALOR         DECIMAL (9, 2),
    DATA          DATE,
    DESCRICAO     VARCHAR (100) 
);

CREATE TABLE TAB_USUARIO (
    ID_USUARIO INTEGER       PRIMARY KEY AUTOINCREMENT,
    NOME       VARCHAR (101),
    EMAIL      VARCHAR (100),
    SENHA      VARCHAR (100),
    IND_LOGIN  CHAR (1) 
);