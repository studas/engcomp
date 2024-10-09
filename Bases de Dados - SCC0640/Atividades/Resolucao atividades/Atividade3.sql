--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------                                                                                                                                               --
-- Exercicio Individual 3                       Bases de dados (SCC0640)                                                                                                                                          --
-- Obs: Foi usado ORDER BY em todos exercicios apenas para facilitar a compreensao. Ele nao eh necessario para o funcionamento de nenhum dos exercicios e poderia ser retirado por questoes de performance        --
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
select 'drop table '||table_name||' cascade constraints;' from user_tables;

-- Truco_esquema
CREATE TABLE JOGADOR (
   NOME VARCHAR2(40) NOT NULL,
   DATA_NASC DATE,
   CURSO VARCHAR2(30) NOT NULL,
   CONSTRAINT PK_JOGADOR PRIMARY KEY(NOME)
);

CREATE TABLE DUPLA (
   JOGADOR1 VARCHAR2(40) NOT NULL,
   JOGADOR2 VARCHAR2(40) NOT NULL,
   NOME VARCHAR2(20) NOT NULL,
   CONSTRAINT PK_DUPLA PRIMARY KEY(JOGADOR1,JOGADOR2),
   CONSTRAINT UN_DUPLA UNIQUE(NOME),
   CONSTRAINT FK_DUPLA_JOG1 FOREIGN KEY(JOGADOR1) REFERENCES JOGADOR(NOME) ON DELETE CASCADE,
   CONSTRAINT FK_DUPLA_JOG2 FOREIGN KEY(JOGADOR2) REFERENCES JOGADOR(NOME) ON DELETE CASCADE,
   CONSTRAINT CK_DUPLA CHECK(UPPER(JOGADOR1)!= UPPER(JOGADOR2))
);

CREATE TABLE CAMPEONATO (
   NOME VARCHAR2(20) NOT NULL,
   DATA_INICIO DATE NOT NULL,
   DATA_FIM DATE,
   CONSTRAINT PK_CAMPEONATO PRIMARY KEY(NOME, DATA_INICIO), 
   CONSTRAINT CK_CAMPEONATO CHECK(DATA_INICIO <= DATA_FIM)
);

CREATE TABLE PARTIDA (
   ID NUMBER,
   DUP1_JOG1 VARCHAR2(40) NOT NULL,
   DUP1_JOG2 VARCHAR2(40) NOT NULL,
   DUP2_JOG1 VARCHAR2(40) NOT NULL,
   DUP2_JOG2 VARCHAR2(40) NOT NULL,
   DATA DATE NOT NULL,
   CAMPEONATO VARCHAR2(20) NOT NULL, 
   DATA_CAMPEONATO DATE NOT NULL, 
   PONTUACAO CHAR(5) DEFAULT '0X0',
   CONSTRAINT PK_PARTIDA PRIMARY KEY(ID),
   CONSTRAINT UN_PARTIDA UNIQUE(DUP1_JOG1, DUP1_JOG2, DUP2_JOG1, DUP2_JOG2,DATA),
   CONSTRAINT FK_PARTIDA_DUPLA1 FOREIGN KEY(DUP1_JOG1, DUP1_JOG2) REFERENCES DUPLA (JOGADOR1, JOGADOR2) ON DELETE CASCADE,
   CONSTRAINT FK_PARTIDA_DUPLA2 FOREIGN KEY(DUP2_JOG1, DUP2_JOG2) REFERENCES DUPLA (JOGADOR1, JOGADOR2) ON DELETE CASCADE,
   CONSTRAINT FK_PARTIDA_CAMPEONATO FOREIGN KEY(CAMPEONATO, DATA_CAMPEONATO) REFERENCES CAMPEONATO (NOME, DATA_INICIO) ON DELETE CASCADE,
   CONSTRAINT CK_PARTIDA_DUPLAS CHECK((UPPER(DUP1_JOG1)!= UPPER(DUP2_JOG1)) AND (UPPER(DUP1_JOG2)!= UPPER(DUP2_JOG2))AND (UPPER(DUP1_JOG1)!= UPPER(DUP2_JOG2)) AND (UPPER(DUP1_JOG2)!= UPPER(DUP2_JOG1))),
   CONSTRAINT CK_PARTIDA_PONTUACAO CHECK(REGEXP_LIKE(PONTUACAO,'[[:digit:]]{1,2}\X[[:digit:]]{1,2}', 'i' ))
);
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------
-- Truco_Dados
INSERT INTO JOGADOR (NOME, DATA_NASC, CURSO) VALUES ('ANA', TO_DATE('2000/09/02', 'YYYY/MM/DD'), 'BCC');
INSERT INTO JOGADOR (NOME, DATA_NASC, CURSO) VALUES ('RAFAEL', TO_DATE('2001/10/10', 'YYYY/MM/DD'), 'BSI'); 
INSERT INTO JOGADOR (NOME, DATA_NASC, CURSO) VALUES ('TAMIRES', NULL, 'EC');  
INSERT INTO JOGADOR (NOME, DATA_NASC, CURSO) VALUES ('DIEGO', TO_DATE('2001/04/03', 'YYYY/MM/DD'), 'EC');

INSERT INTO DUPLA (JOGADOR1, JOGADOR2, NOME) VALUES ('DIEGO', 'TAMIRES', 'EC2018');
INSERT INTO DUPLA (JOGADOR1, JOGADOR2, NOME) VALUES ('ANA', 'RAFAEL', 'BIT');
INSERT INTO DUPLA (JOGADOR1, JOGADOR2, NOME) VALUES ('ANA', 'TAMIRES', 'ELAS');
INSERT INTO DUPLA (JOGADOR1, JOGADOR2, NOME) VALUES ('DIEGO', 'RAFAEL', 'JOKER');    
    
INSERT INTO CAMPEONATO (NOME, DATA_INICIO, DATA_FIM) VALUES ('TRUCOICMC', TO_DATE('2019/10/05', 'YYYY/MM/DD'), TO_DATE('2019/10/15', 'YYYY/MM/DD'));  
INSERT INTO CAMPEONATO (NOME, DATA_INICIO, DATA_FIM) VALUES ('TRUCOICMC', TO_DATE('2018/04/03', 'YYYY/MM/DD'), TO_DATE('2018/04/13', 'YYYY/MM/DD'));  
 
INSERT INTO PARTIDA (ID, DUP1_JOG1, DUP1_JOG2, DUP2_JOG1, DUP2_JOG2, DATA, CAMPEONATO, DATA_CAMPEONATO, PONTUACAO)
    VALUES (1, 'DIEGO', 'TAMIRES', 'ANA', 'RAFAEL', TO_DATE('2018/04/05 20:00:00', 'YYYY/MM/DD HH24:MI:SS'), 'TRUCOICMC', TO_DATE('2018/04/03', 'YYYY/MM/DD'), DEFAULT); 
INSERT INTO PARTIDA (ID, DUP1_JOG1, DUP1_JOG2, DUP2_JOG1, DUP2_JOG2, DATA, CAMPEONATO, DATA_CAMPEONATO, PONTUACAO)
    VALUES (2, 'ANA', 'TAMIRES', 'DIEGO', 'RAFAEL', TO_DATE('2018/04/04 20:00:00', 'YYYY/MM/DD HH24:MI:SS'), 'TRUCOICMC', TO_DATE('2018/04/03', 'YYYY/MM/DD'), '2X1'); 
INSERT INTO PARTIDA (ID, DUP1_JOG1, DUP1_JOG2, DUP2_JOG1, DUP2_JOG2, DATA, CAMPEONATO, DATA_CAMPEONATO, PONTUACAO)
    VALUES (3, 'DIEGO', 'TAMIRES', 'ANA', 'RAFAEL', TO_DATE('2019/10/06 20:00:00', 'YYYY/MM/DD HH24:MI:SS'), 'TRUCOICMC', TO_DATE('2019/10/05', 'YYYY/MM/DD'), '2X5'); 
INSERT INTO PARTIDA (ID, DUP1_JOG1, DUP1_JOG2, DUP2_JOG1, DUP2_JOG2, DATA, CAMPEONATO, DATA_CAMPEONATO, PONTUACAO)
    VALUES (4, 'ANA', 'TAMIRES', 'DIEGO', 'RAFAEL', TO_DATE('2019/10/10 20:00:00', 'YYYY/MM/DD HH24:MI:SS'), 'TRUCOICMC', TO_DATE('2019/10/05', 'YYYY/MM/DD'), NULL); 

-------------------------
-- Alimentacao generica

INSERT INTO JOGADOR VALUES ('A', '01-01-01', 'EC');
INSERT INTO JOGADOR VALUES ('B', '02-07-00', 'EC');
INSERT INTO JOGADOR VALUES ('C', '03-05-02', 'EC');
INSERT INTO JOGADOR VALUES ('D', '05-04-03', 'EC');
INSERT INTO JOGADOR VALUES ('E', '10-03-04', 'EC');
INSERT INTO JOGADOR VALUES ('F', '15-02-99', 'EC');
INSERT INTO JOGADOR VALUES ('G', '20-12-98', 'EC');
INSERT INTO JOGADOR VALUES ('H', '25-10-97', 'EC');
INSERT INTO JOGADOR VALUES ('I', '22-09-96', 'EC');
INSERT INTO JOGADOR VALUES ('J', '14-08-70', 'EC');
INSERT INTO JOGADOR VALUES ('K', '13-06-35', 'EC');
INSERT INTO JOGADOR VALUES ('L', '17-02-20', 'EC');

INSERT INTO DUPLA VALUES ('A', 'B', 'AB');
INSERT INTO DUPLA VALUES ('A', 'C', 'AC');
INSERT INTO DUPLA VALUES ('B', 'C', 'BC');
INSERT INTO DUPLA VALUES ('D', 'E', 'DE');
INSERT INTO DUPLA VALUES ('F', 'G', 'FG');
INSERT INTO DUPLA VALUES ('G', 'H', 'GH');
INSERT INTO DUPLA VALUES ('I', 'J', 'IJ');
INSERT INTO DUPLA VALUES ('K', 'L', 'KL');
INSERT INTO DUPLA VALUES ('A', 'L', 'AL');
INSERT INTO DUPLA VALUES ('B', 'L', 'BL');

INSERT INTO CAMPEONATO VALUES ('Campeonato2017', TO_DATE('2017/07/01', 'YYYY/MM/DD'), TO_DATE('2017/08/11', 'YYYY/MM/DD'));
INSERT INTO CAMPEONATO VALUES ('Campeonato2018', TO_DATE('2018/08/02', 'YYYY/MM/DD'), TO_DATE('2018/09/12', 'YYYY/MM/DD'));
INSERT INTO CAMPEONATO VALUES ('Campeonato2019', TO_DATE('2019/09/03', 'YYYY/MM/DD'), TO_DATE('2019/10/13', 'YYYY/MM/DD'));
INSERT INTO CAMPEONATO VALUES ('Campeonato2020', TO_DATE('2020/02/04', 'YYYY/MM/DD'), TO_DATE('2020/03/14', 'YYYY/MM/DD'));
INSERT INTO CAMPEONATO VALUES ('Campeonato2021', TO_DATE('2021/12/05', 'YYYY/MM/DD'), NULL);

--2021: ABCDEFGHIJKL (EC19 jogou) -> Duplas que jogaram com EC19 = Todas
INSERT INTO PARTIDA VALUES (05, 'A', 'B', 'D', 'E', TO_DATE('2021/12/05 20:20:00', 'YYYY/MM/DD HH24:MI:SS'), 'Campeonato2021', TO_DATE('2021/12/05', 'YYYY/MM/DD'), '0X0'); -- 1
INSERT INTO PARTIDA VALUES (06, 'A', 'C', 'F', 'G', TO_DATE('2021/12/06 14:20:00', 'YYYY/MM/DD HH24:MI:SS'), 'Campeonato2021', TO_DATE('2021/12/05', 'YYYY/MM/DD'), '0X2'); -- 2
INSERT INTO PARTIDA VALUES (07, 'B', 'C', 'G', 'H', TO_DATE('2021/12/05 15:05:00', 'YYYY/MM/DD HH24:MI:SS'), 'Campeonato2021', TO_DATE('2021/12/05', 'YYYY/MM/DD'), '3X4');
INSERT INTO PARTIDA VALUES (08, 'I', 'J', 'K', 'L', TO_DATE('2021/12/15 04:10:00', 'YYYY/MM/DD HH24:MI:SS'), 'Campeonato2021', TO_DATE('2021/12/05', 'YYYY/MM/DD'), '1X5');
INSERT INTO PARTIDA VALUES (09, 'A', 'L', 'B', 'C', TO_DATE('2021/12/12 05:30:00', 'YYYY/MM/DD HH24:MI:SS'), 'Campeonato2021', TO_DATE('2021/12/05', 'YYYY/MM/DD'), '0X0'); -- 3
INSERT INTO PARTIDA VALUES (10, 'B', 'L', 'A', 'C', TO_DATE('2021/12/13 06:40:00', 'YYYY/MM/DD HH24:MI:SS'), 'Campeonato2021', TO_DATE('2021/12/05', 'YYYY/MM/DD'), '1X0'); -- 4
INSERT INTO PARTIDA VALUES (11, 'G', 'H', 'K', 'L', TO_DATE('2021/12/14 07:15:00', 'YYYY/MM/DD HH24:MI:SS'), 'Campeonato2021', TO_DATE('2021/12/05', 'YYYY/MM/DD'), '0X4'); -- 5
INSERT INTO PARTIDA VALUES (12, 'D', 'E', 'B', 'C', TO_DATE('2021/12/30 08:10:00', 'YYYY/MM/DD HH24:MI:SS'), 'Campeonato2021', TO_DATE('2021/12/05', 'YYYY/MM/DD'), '0X3'); -- 6
INSERT INTO PARTIDA VALUES (13, 'A', 'C', 'B', 'L', TO_DATE('2021/12/25 09:06:00', 'YYYY/MM/DD HH24:MI:SS'), 'Campeonato2021', TO_DATE('2021/12/05', 'YYYY/MM/DD'), NULL);
INSERT INTO PARTIDA VALUES (14, 'D', 'E', 'A', 'B', TO_DATE('2021/12/12 15:15:00', 'YYYY/MM/DD HH24:MI:SS'), 'Campeonato2021', TO_DATE('2021/12/05', 'YYYY/MM/DD'), NULL);

--2020: ABCDE (EC19 jogou) -> Duplas que jogaram com EC19 = AB, AC, DE (contando com 2021)
INSERT INTO PARTIDA VALUES (15, 'A', 'B', 'D', 'E', TO_DATE('2020/02/12 00:32:00', 'YYYY/MM/DD HH24:MI:SS'), 'Campeonato2020', TO_DATE('2020/02/04', 'YYYY/MM/DD'), '1X4');
INSERT INTO PARTIDA VALUES (16, 'A', 'C', 'D', 'E', TO_DATE('2020/02/25 12:04:00', 'YYYY/MM/DD HH24:MI:SS'), 'Campeonato2020', TO_DATE('2020/02/04', 'YYYY/MM/DD'), '1X2');
INSERT INTO PARTIDA VALUES (17, 'D', 'E', 'A', 'B', TO_DATE('2020/02/27 13:27:00', 'YYYY/MM/DD HH24:MI:SS'), 'Campeonato2020', TO_DATE('2020/02/04', 'YYYY/MM/DD'), '0X7'); -- 1
INSERT INTO PARTIDA VALUES (18, 'D', 'E', 'A', 'C', TO_DATE('2020/02/28 15:35:00', 'YYYY/MM/DD HH24:MI:SS'), 'Campeonato2020', TO_DATE('2020/02/04', 'YYYY/MM/DD'), NULL);

--2019 (sem nenhuma partida com um dos times nao pontuando): AIJKL
INSERT INTO PARTIDA VALUES (19, 'K', 'L', 'I', 'J', TO_DATE('2019/09/03 11:00:00', 'YYYY/MM/DD HH24:MI:SS'), 'Campeonato2019', TO_DATE('2019/09/03', 'YYYY/MM/DD'), '1X14');
INSERT INTO PARTIDA VALUES (20, 'I', 'J', 'A', 'L', TO_DATE('2019/09/17 12:45:00', 'YYYY/MM/DD HH24:MI:SS'), 'Campeonato2019', TO_DATE('2019/09/03', 'YYYY/MM/DD'), '8X3');
INSERT INTO PARTIDA VALUES (21, 'A', 'L', 'I', 'J', TO_DATE('2019/09/10 00:30:00', 'YYYY/MM/DD HH24:MI:SS'), 'Campeonato2019', TO_DATE('2019/09/03', 'YYYY/MM/DD'), '2X7');

--2018: BCDEFGHIJKL (EC19 jogou) -> Duplas que jogaram com EC19 = DE (contando com 2021 e 2020)
INSERT INTO PARTIDA VALUES (22, 'D', 'E', 'F', 'G', TO_DATE('2018/08/02 12:10:00', 'YYYY/MM/DD HH24:MI:SS'), 'Campeonato2018', TO_DATE('2018/08/02', 'YYYY/MM/DD'), '5X4');
INSERT INTO PARTIDA VALUES (23, 'G', 'H', 'I', 'J', TO_DATE('2018/08/05 11:24:00', 'YYYY/MM/DD HH24:MI:SS'), 'Campeonato2018', TO_DATE('2018/08/02', 'YYYY/MM/DD'), '9X15');
INSERT INTO PARTIDA VALUES (24, 'K', 'L', 'I', 'J', TO_DATE('2018/08/07 14:00:30', 'YYYY/MM/DD HH24:MI:SS'), 'Campeonato2018', TO_DATE('2018/08/02', 'YYYY/MM/DD'), '99X0'); -- 1
INSERT INTO PARTIDA VALUES (25, 'D', 'E', 'K', 'L', TO_DATE('2018/08/09 03:00:00', 'YYYY/MM/DD HH24:MI:SS'), 'Campeonato2018', TO_DATE('2018/08/02', 'YYYY/MM/DD'), '0X98'); -- 2
INSERT INTO PARTIDA VALUES (26, 'B', 'C', 'K', 'L', TO_DATE('2018/08/08 11:29:00', 'YYYY/MM/DD HH24:MI:SS'), 'Campeonato2018', TO_DATE('2018/08/02', 'YYYY/MM/DD'), '3X3');
INSERT INTO PARTIDA VALUES (27, 'I', 'J', 'D', 'E', TO_DATE('2018/08/13 12:25:00', 'YYYY/MM/DD HH24:MI:SS'), 'Campeonato2018', TO_DATE('2018/08/02', 'YYYY/MM/DD'), '0X10'); -- 3
INSERT INTO PARTIDA VALUES (28, 'B', 'C', 'G', 'H', TO_DATE('2018/08/10 14:20:00', 'YYYY/MM/DD HH24:MI:SS'), 'Campeonato2018', TO_DATE('2018/08/02', 'YYYY/MM/DD'), NULL);

--2017 (sem nenhuma partida com um dos times nao pontuando): ABCL
INSERT INTO PARTIDA VALUES (29, 'A', 'C', 'B', 'L', TO_DATE('2017/07/29 13:00:31', 'YYYY/MM/DD HH24:MI:SS'), 'Campeonato2017', TO_DATE('2017/07/01', 'YYYY/MM/DD'), NULL);
INSERT INTO PARTIDA VALUES (30, 'A', 'L', 'B', 'C', TO_DATE('2017/07/25 13:20:00', 'YYYY/MM/DD HH24:MI:SS'), 'Campeonato2017', TO_DATE('2017/07/01', 'YYYY/MM/DD'), NULL);

-- Alimentacao focada nas consultas
INSERT INTO JOGADOR VALUES ('EngComper1', NULL, 'EC');  -- EC19
INSERT INTO JOGADOR VALUES ('EngComper2', NULL, 'EC');  -- EC19
INSERT INTO JOGADOR VALUES ('Dummy1', NULL, 'BSI');     -- Dupla que sempre joga contra a EC19
INSERT INTO JOGADOR VALUES ('Dummy2', NULL, 'BCC');     -- Dupla sem partida
INSERT INTO JOGADOR VALUES ('Dummy3', NULL, 'BCC');     -- Dupla que sempre joga contra a EC19
INSERT INTO JOGADOR VALUES ('Dummy4', NULL, 'BSI');     -- Dupla sem partida

INSERT INTO DUPLA VALUES ('EngComper1', 'EngComper2', 'EC19');      -- Participa de todos campeonato menos 2017 e 2019
INSERT INTO DUPLA VALUES ('Dummy1', 'Dummy3', 'DummiesImpar');      -- Dupla que joga contra EC19
INSERT INTO DUPLA VALUES ('Dummy2', 'Dummy4', 'DummiesPar');        -- Dupla sem partida

INSERT INTO CAMPEONATO VALUES ('CampeonatoFake1', TO_DATE('1975/11/23', 'YYYY/MM/DD'), NULL);   -- Campeonato sem partidas
INSERT INTO CAMPEONATO VALUES ('CampeonatoFake2', TO_DATE('2019/09/23', 'YYYY/MM/DD'), NULL);   -- Campeonato entre 2018-2021 com 1 partida so
INSERT INTO CAMPEONATO VALUES ('RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), NULL);         -- Campeonato para testar REGEX da questao 5

-- Partidas EC19
INSERT INTO PARTIDA VALUES (31, 'Dummy1', 'Dummy3', 'EngComper1', 'EngComper2', TO_DATE('2018/08/02 01:00:00', 'YYYY/MM/DD HH24:MI:SS'), 'Campeonato2018', TO_DATE('2018/08/02', 'YYYY/MM/DD'), '10X10');
INSERT INTO PARTIDA VALUES (32, 'EngComper1', 'EngComper2', 'Dummy1', 'Dummy3', TO_DATE('2020/02/04 02:00:00', 'YYYY/MM/DD HH24:MI:SS'), 'Campeonato2020', TO_DATE('2020/02/04', 'YYYY/MM/DD'), '10X10');
INSERT INTO PARTIDA VALUES (33, 'Dummy1', 'Dummy3', 'EngComper1', 'EngComper2', TO_DATE('2021/12/05 03:00:00', 'YYYY/MM/DD HH24:MI:SS'), 'Campeonato2021', TO_DATE('2021/12/05', 'YYYY/MM/DD'), '10X10');

-- Campeonato com so 1 partida entre 2018-2021
INSERT INTO PARTIDA VALUES (34, 'A', 'B', 'D', 'E', TO_DATE('2019/09/23 00:43:00', 'YYYY/MM/DD HH24:MI:SS'), 'CampeonatoFake2', TO_DATE('2019/09/23', 'YYYY/MM/DD'), '1X0');

-- Partidas REGEX
INSERT INTO PARTIDA VALUES (35, 'A', 'B', 'D', 'E', TO_DATE('1950/01/01 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '0X0');      -- 01
INSERT INTO PARTIDA VALUES (36, 'A', 'B', 'D', 'E', TO_DATE('1950/01/02 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '0X1');      -- 02
INSERT INTO PARTIDA VALUES (37, 'A', 'B', 'D', 'E', TO_DATE('1950/01/03 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '0X00');     -- 03
INSERT INTO PARTIDA VALUES (38, 'A', 'B', 'D', 'E', TO_DATE('1950/01/04 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '0X01');     -- 04
INSERT INTO PARTIDA VALUES (39, 'A', 'B', 'D', 'E', TO_DATE('1950/01/05 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '0X10');     -- 05
INSERT INTO PARTIDA VALUES (40, 'A', 'B', 'D', 'E', TO_DATE('1950/01/06 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '0X11');     -- 06
INSERT INTO PARTIDA VALUES (41, 'A', 'B', 'D', 'E', TO_DATE('1950/01/07 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '00X0');     -- 07
INSERT INTO PARTIDA VALUES (42, 'A', 'B', 'D', 'E', TO_DATE('1950/01/08 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '00X1');     -- 08
INSERT INTO PARTIDA VALUES (43, 'A', 'B', 'D', 'E', TO_DATE('1950/01/09 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '00X00');    -- 09
INSERT INTO PARTIDA VALUES (44, 'A', 'B', 'D', 'E', TO_DATE('1950/01/10 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '00X01');    -- 10
INSERT INTO PARTIDA VALUES (45, 'A', 'B', 'D', 'E', TO_DATE('1950/01/11 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '00X10');    -- 11
INSERT INTO PARTIDA VALUES (46, 'A', 'B', 'D', 'E', TO_DATE('1950/01/12 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '00X11');    -- 12
INSERT INTO PARTIDA VALUES (47, 'A', 'B', 'D', 'E', TO_DATE('1950/01/13 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '0X0');      -- 13
INSERT INTO PARTIDA VALUES (48, 'A', 'B', 'D', 'E', TO_DATE('1950/01/14 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '1X0');      -- 14
INSERT INTO PARTIDA VALUES (49, 'A', 'B', 'D', 'E', TO_DATE('1950/01/15 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '00X0');     -- 15
INSERT INTO PARTIDA VALUES (50, 'A', 'B', 'D', 'E', TO_DATE('1950/01/16 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '01X0');     -- 16
INSERT INTO PARTIDA VALUES (51, 'A', 'B', 'D', 'E', TO_DATE('1950/01/17 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '10X0');     -- 17
INSERT INTO PARTIDA VALUES (52, 'A', 'B', 'D', 'E', TO_DATE('1950/01/18 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '11X0');     -- 18
INSERT INTO PARTIDA VALUES (53, 'A', 'B', 'D', 'E', TO_DATE('1950/01/19 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '0X00');     -- 19
INSERT INTO PARTIDA VALUES (54, 'A', 'B', 'D', 'E', TO_DATE('1950/01/20 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '1X00');     -- 20
INSERT INTO PARTIDA VALUES (55, 'A', 'B', 'D', 'E', TO_DATE('1950/01/21 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '00X00');    -- 21
INSERT INTO PARTIDA VALUES (56, 'A', 'B', 'D', 'E', TO_DATE('1950/01/22 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '01X00');    -- 22
INSERT INTO PARTIDA VALUES (57, 'A', 'B', 'D', 'E', TO_DATE('1950/01/23 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '10X00');    -- 23
INSERT INTO PARTIDA VALUES (58, 'A', 'B', 'D', 'E', TO_DATE('1950/01/24 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '11X00');    -- 24
INSERT INTO PARTIDA VALUES (59, 'A', 'B', 'D', 'E', TO_DATE('1950/01/25 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '1X1');
INSERT INTO PARTIDA VALUES (60, 'A', 'B', 'D', 'E', TO_DATE('1950/01/26 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '1X01');
INSERT INTO PARTIDA VALUES (61, 'A', 'B', 'D', 'E', TO_DATE('1950/01/27 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '1X10');
INSERT INTO PARTIDA VALUES (62, 'A', 'B', 'D', 'E', TO_DATE('1950/01/28 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '1X11');
INSERT INTO PARTIDA VALUES (63, 'A', 'B', 'D', 'E', TO_DATE('1950/01/29 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '01X1');
INSERT INTO PARTIDA VALUES (64, 'A', 'B', 'D', 'E', TO_DATE('1950/01/30 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '01X01');
INSERT INTO PARTIDA VALUES (65, 'A', 'B', 'D', 'E', TO_DATE('1950/01/31 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '01X10');
INSERT INTO PARTIDA VALUES (66, 'A', 'B', 'D', 'E', TO_DATE('1950/02/01 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '01X11');
INSERT INTO PARTIDA VALUES (67, 'A', 'B', 'D', 'E', TO_DATE('1950/02/02 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '10X1');
INSERT INTO PARTIDA VALUES (68, 'A', 'B', 'D', 'E', TO_DATE('1950/02/03 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '10X01');
INSERT INTO PARTIDA VALUES (69, 'A', 'B', 'D', 'E', TO_DATE('1950/02/04 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '10X10');
INSERT INTO PARTIDA VALUES (70, 'A', 'B', 'D', 'E', TO_DATE('1950/02/05 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '10X11');
INSERT INTO PARTIDA VALUES (71, 'A', 'B', 'D', 'E', TO_DATE('1950/02/06 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '11X1');
INSERT INTO PARTIDA VALUES (72, 'A', 'B', 'D', 'E', TO_DATE('1950/02/07 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '11X01');
INSERT INTO PARTIDA VALUES (73, 'A', 'B', 'D', 'E', TO_DATE('1950/02/08 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '11X10');
INSERT INTO PARTIDA VALUES (74, 'A', 'B', 'D', 'E', TO_DATE('1950/02/09 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '11X11');
INSERT INTO PARTIDA VALUES (75, 'A', 'B', 'D', 'E', TO_DATE('1950/02/10 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '1X1');
INSERT INTO PARTIDA VALUES (76, 'A', 'B', 'D', 'E', TO_DATE('1950/02/11 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '01X1');
INSERT INTO PARTIDA VALUES (77, 'A', 'B', 'D', 'E', TO_DATE('1950/02/12 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '10X1');
INSERT INTO PARTIDA VALUES (78, 'A', 'B', 'D', 'E', TO_DATE('1950/02/13 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '11X1');
INSERT INTO PARTIDA VALUES (79, 'A', 'B', 'D', 'E', TO_DATE('1950/02/14 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '1X01');
INSERT INTO PARTIDA VALUES (80, 'A', 'B', 'D', 'E', TO_DATE('1950/02/15 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '01X01');
INSERT INTO PARTIDA VALUES (81, 'A', 'B', 'D', 'E', TO_DATE('1950/02/16 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '10X01');
INSERT INTO PARTIDA VALUES (82, 'A', 'B', 'D', 'E', TO_DATE('1950/02/17 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '11X01');
INSERT INTO PARTIDA VALUES (83, 'A', 'B', 'D', 'E', TO_DATE('1950/02/18 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '1X10');
INSERT INTO PARTIDA VALUES (84, 'A', 'B', 'D', 'E', TO_DATE('1950/02/19 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '01X10');
INSERT INTO PARTIDA VALUES (85, 'A', 'B', 'D', 'E', TO_DATE('1950/02/20 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '10X10');
INSERT INTO PARTIDA VALUES (86, 'A', 'B', 'D', 'E', TO_DATE('1950/02/21 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '11X10');
INSERT INTO PARTIDA VALUES (87, 'A', 'B', 'D', 'E', TO_DATE('1950/02/22 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '1X11');
INSERT INTO PARTIDA VALUES (88, 'A', 'B', 'D', 'E', TO_DATE('1950/02/23 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '01X11');
INSERT INTO PARTIDA VALUES (89, 'A', 'B', 'D', 'E', TO_DATE('1950/02/24 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '10X11');
INSERT INTO PARTIDA VALUES (90, 'A', 'B', 'D', 'E', TO_DATE('1950/02/25 01:01:01', 'YYYY/MM/DD HH24:MI:SS'), 'RegexTest', TO_DATE('1950/01/01', 'YYYY/MM/DD'), '11X11');

UPDATE Jogador SET Curso = 'ENG COMP' WHERE Curso = 'EC'; --Para que a pesquisa encontre no ex1

COMMIT;
EXEC DBMS_STATS.GATHER_SCHEMA_STATS(NULL, NULL);

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--1) Para cada jogador do curso 'Eng Comp', listar data de nascimento e nome(s) da(s) dupla(s) em que joga/jogou.
-- Solucao: Simplesmente pega os dados pedidos usando INNER JOIN e seleciona apenas os engcompers usando WHERE
SELECT J.Nome AS Jogador, J.Data_Nasc, D.Nome AS Dupla      -- Informacoes pedidas
FROM Dupla D JOIN Jogador J                                 -- Join com Jogador eh necessario para pegar a data de nascimento e curso
    ON (J.Nome = D.Jogador1 OR J.Nome = D.Jogador2)   
WHERE (UPPER(J.Curso) = 'ENG COMP')                         -- Apenas jogadores da Eng Comp
ORDER BY J.Nome, D.Nome;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--2) Para as duplas que participaram de campeonatos em 2019 ou 2020, selecionar o nome da dupla e o campeonato.
-- Solucao: Simplesmente pega os dados pedidos usando INNER JOIN e seleciona apenas os campeonato de 2019 e 2020 usando WHERE
SELECT DISTINCT D.Nome AS Dupla, P.Campeonato, P.Data_Campeonato AS Data_Campeonato         -- Informacoes pedidas. Distinct eh necessario pois uma dupla pode jogar em varias partidas do campeonato
FROM Partida P JOIN Dupla D ON ((P.Dup1_Jog1 = D.Jogador1 AND P.Dup1_Jog2 = D.Jogador2)     -- Join necessario para pegar nome das duplas. Veja que nao eh necessario dar JOIN na tabela do Campeonato
                            OR  (P.Dup2_Jog1 = D.Jogador1 AND P.Dup2_Jog2 = D.Jogador2))    -- Pega para ambas as duplas
WHERE (EXTRACT(YEAR FROM P.DATA_CAMPEONATO) IN (2019, 2020))                                -- Garante que o campeonato aconteceu em 2019 ou 2020. Poderia ser feito usando BETWEEN 2019 AND 2020 mas da na mesma.
ORDER BY D.Nome, P.Campeonato, P.Data_Campeonato;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
--3) Para cada partida, selecione ID, nomes das duplas que jogaram, data e horario, nome do campeonato, datas de inicio e fim do campeonato.
-- Solucao: Como precisamos do nome de ambas as duplas em uma unica tupla, fazemos dois INNER JOINS para cada partida, um para a dupla 'de casa' e outro para dupla 'visitante'.
SELECT P.ID, D1.Nome AS DuplaCasa, D2.Nome AS DuplaVisitante,                                           -- Nome das duplas jogadoras
        C.Nome AS Nome_Campeonato, C.Data_Inicio AS Data_Inicio_Camp, C.Data_Fim AS Data_Fim_Camp,      -- Informacoes do campeonato que rolou essa partida
        TO_CHAR(P.Data, 'DD/MM/YYYY') AS Data_Partida, TO_CHAR(P.Data, 'HH24:MI:SS') AS Hora_Partida    -- Data e Hora que aconteceu essa partida
FROM Partida P JOIN Dupla D1 ON (P.Dup1_Jog1 = D1.Jogador1 AND P.Dup1_Jog2 = D1.Jogador2)               -- Casa
               JOIN Dupla D2 ON (P.Dup2_Jog1 = D2.Jogador1 AND P.Dup2_Jog2 = D2.Jogador2)               -- Visitante
               JOIN Campeonato C ON (P.Campeonato = C.Nome AND P.Data_Campeonato = C.Data_Inicio)       -- Para obter a data de fim do campeonato
ORDER BY P.ID;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--4) Selecionar, para todos os jogadores, seu curso e a quantidade de campeonatos dos quais ja participou.
-- Solucao: Separamos as partidas em grupos para cada jogador e contamos quantos campeonatos distintos o jogador jogou checando a concatenacao do nome do campeonato com a data do campeonato
SELECT J.Nome, J.Curso, COUNT(distinct P.Campeonato || P.Data_Campeonato) AS Qtd_Campeonatos            -- Mostra informacoes do jogador e conta quantos campeonatos distintos ele participou
FROM Jogador J LEFT JOIN Partida P                                                                      -- Identifica todas partidas que ele participou (left join pq pode ser 0)
    ON (J.Nome = P.Dup1_Jog1 OR J.Nome = P.Dup1_Jog2 OR J.Nome = P.Dup2_Jog1 OR J.Nome = P.Dup2_Jog2)    
GROUP BY J.Nome, J.Curso                                                                                -- Agrupa por jogador
ORDER BY J.Nome;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--5) Selecionar quantas partidas ocorreram por campeonato, considerando apenas partidas em que uma das duplas nao pontuou (zero pontos)
-- Solucao: Semelhante a solucao do exercicio anterior, mas como P.ID ja eh unico fica mais facil. 
-- A clausula de nao pontuar precisa ser aplicada antes do OUTTER JOIN para preservar os campeonatos que nao tenham essas partidas,
-- por isso colocamos ela dentro do ON.
-- OBS: O tipo char adiciona padding com espacos em branco (' ') se a string nao for do tamanho correto, por isso os regex terminam em ' *$'
SELECT C.Nome, C.Data_Inicio, COUNT(P.ID) AS Qtd_Partidas_com_0_Pontos      -- Mostra informacoes do campeonato e a contagem de partidas
FROM Campeonato C LEFT JOIN Partida P                                       -- Left join apenas para caso um campeonato nao tenha nenhuma partida no qual uma das duplas nao pontuou
    ON (P.Campeonato = C.Nome AND P.Data_Campeonato = C.Data_Inicio AND REGEXP_LIKE(P.Pontuacao, '(^[0-9]{1,2}\X0{1,2} *$)|(^0{1,2}\X[0-9]{1,2} *$)', 'i'))
GROUP BY C.Nome, C.Data_Inicio                                              -- Agrupa as partidas por campeonato
ORDER BY C.Nome, C.Data_Inicio;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--6) Selecionar para todos os campeonatos, nome, datas de inicio e fim, e quantidade de partidas ocorridas entre 2018 e 2021. Considere apenas campeonatos que tiveram pelo menos 2 partidas.
-- Solucao: Tambem semelhante a solucao anterior, mas como nos importamos apenas com campeonatos que tenhas pelo menos 2 partidas, nao ha necessidade de OUTTER JOIN
SELECT C.Nome AS Campeonato, C.Data_Inicio, C.Data_Fim, COUNT (P.ID) AS Qtd_Partidas_Entre_2018_2021    -- Mostra informacoes do campeonato
FROM Partida P JOIN Campeonato C                                                                        -- Join para poder pegar a data de fim
    ON (P.Campeonato = C.Nome AND P.Data_Campeonato = C.Data_Inicio)       
WHERE (EXTRACT(YEAR FROM P.Data) BETWEEN 2018 AND 2021)                                                 -- Garante que o ano esteja entre 2018 e 2021
GROUP BY C.Nome, C.Data_Inicio, C.Data_Fim                                                              -- Agrupa as partidas por campeonato
HAVING COUNT(P.ID) >= 2                                                                                 -- Mostra apenas aqueles que tiverem pelo menos 2 partidas (tira o CampeonatoFake2)
ORDER BY C.Nome, C.Data_Inicio;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 7) Selecionar nome e curso dos jogadores que participaram de pelo um campeonato, mas nao jogaram no ano de 2020.
-- Solucao: Fazemos uma consulta aninhada para os jogadores que jogaram no ano de 2020 e colocamos uma restricao de NOT IN na consulta externa.
-- Poderiamos trocar o NOT IN por um MINUS mas fica mais lento, vide justificativa da questao 10.
SELECT DISTINCT J.Nome, J.Curso                                 -- Seleciona os Jogadores (distinct pois pode ter participado de mais de uma partida)
FROM Partida P JOIN Jogador J 
    ON (J.Nome = P.Dup1_Jog1 OR J.Nome = P.Dup1_Jog2 OR J.Nome = P.Dup2_Jog1 OR J.Nome = P.Dup2_Jog2)
WHERE (EXTRACT(YEAR FROM P.Data) <> 2020 AND J.Nome NOT IN (   -- Que participaram de um campeonato sem ser em 2020 e exclui jogadores que tambem jogaram em 2020 (year <> 2020 nao eh necessario, mas eh mais eficiente eliminar por essa condicao do que nao pertencer ao conjunto)
    SELECT DISTINCT Ji.Nome                                    -- Pega o nome dos jogadores que jogaram em 2020 (distinct nao obrigatorio, mas acredito que seja mais eficiente se tiver muitas partidas por jogador, ja que calcula apenas uma vez)
    FROM Partida Pi JOIN Jogador Ji ON (Ji.Nome = Pi.Dup1_Jog1 OR Ji.Nome = Pi.Dup1_Jog2 OR Ji.Nome = Pi.Dup2_Jog1 OR Ji.Nome = Pi.Dup2_Jog2)
    WHERE (EXTRACT(YEAR FROM Pi.Data) = 2020)))
ORDER BY J.Nome;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 8) Selecionar, para cada jogador, seu nome, curso, nome(s) da(s) duplas em que joga e nome do outro jogador da dupla.
-- Solucao: uma consulta padrao dando JOIN em somente um dos jogadores por vez e fazendo um CASE para descobrir qual dos dois nao foi 'selecionado' no JOIN.
SELECT J.Nome AS Jogador, J.Curso AS CursoJogador, D.Nome AS NomeDupla,
    CASE J.Nome                 -- Pega sempre o nome do outro jogador
        WHEN D.Jogador1
            THEN D.Jogador2
        ELSE 
            D.Jogador1
    END AS Dupla
    FROM Jogador J JOIN Dupla D ON (J.Nome = D.Jogador1 OR J.Nome = D.Jogador2) -- Join necessario para pegar o curso e definir qual o jogador que estamos falando
ORDER BY D.Nome, J.Nome;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 9) Para cada dupla, selecionar a data da primeira e a data da ultima partida que jogou em cada campeonato que disputou.
-- Ex: se a dupla 'EC19' participou de dois campeonatos, serao listadas as datas da primeira e da ultima partida de cada um dos campeonatos.
-- Solucao: Fazemos uma consulta na tabela de partida agrupando ela por cada dupla e depois por cada campeonato. Assim, basta utilizar as funcoes MIN e MAX no atributo Data da partida.
-- Acredito que agrupar por Dupla, Campeonato seja indiferente de agrupar por Campeonato, Dupla tanto em questoes de performance quanto de resultado. O SGDB deve otimizar por conta propria.
SELECT D.Nome AS Dupla, P.Campeonato, P.Data_Campeonato, MIN(P.Data) AS DataPrimeiraPartida, MAX(P.Data) AS DataUltimaPartida   -- Informacoes pedidas
FROM Dupla D JOIN Partida P ON ((P.Dup1_Jog1 = D.Jogador1 AND P.Dup1_Jog2 = D.Jogador2)
                            OR  (P.Dup2_Jog1 = D.Jogador1 AND P.Dup2_Jog2 = D.Jogador2))
GROUP BY D.Nome, P.Campeonato, P.Data_Campeonato                                                                                -- Separa por equipes e por campeonato, para poder calcular o MIN e MAX
ORDER BY D.Nome, P.Campeonato, P.Data_Campeonato;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--10) Selecionar os nomes das duplas que participaram de todos os campeonatos dos quais a dupla 'EC19' participou.
-- Solucao: Calcula os campeonatos que a EC19 participou mas a dupla nao. Se a dupla participou de todos que a EC19, o resultado sera um conjunto vazio.
-- Uma outra opcao seria fazer a diferenca da EC19 com a dupla, que teoricamente seria similar em termos de performance
-- mas na pratica eh mais devagar pois o MINUS possui um overhead maior (com ordenacoes desnecessarias) se checarmos no EXPLAIN PLAN.
SELECT De.Nome FROM Dupla De WHERE NOT EXISTS (
    SELECT Pi.Campeonato                                                        -- Calcula todos campeonatos da EC19
    FROM Partida Pi JOIN Dupla Di
        ON ((Pi.Dup1_Jog1 = Di.Jogador1 AND Pi.Dup1_Jog2 = Di.Jogador2)     
        OR (Pi.Dup2_Jog1 = Di.Jogador1 AND Pi.Dup2_Jog2 = Di.Jogador2))
    WHERE (Di.Nome = 'EC19' AND Pi.Campeonato NOT IN (                          -- que nao fazem parte dos campeonatos da dupla
        SELECT Pii.Campeonato                                                   -- Calcula todos campeonatos da Dupla
        FROM Partida Pii
        WHERE ((Pii.Dup1_Jog1 = De.Jogador1 AND Pii.Dup1_Jog2 = De.Jogador2)    
            OR (Pii.Dup2_Jog1 = De.Jogador1 AND Pii.Dup2_Jog2 = De.Jogador2))
    ))
)
ORDER BY De.Nome;


-- Teste com NOT IN
EXPLAIN PLAN FOR
SELECT De.Nome FROM Dupla De WHERE NOT EXISTS (
    SELECT Pi.Campeonato                                                        -- Calcula todos campeonatos da EC19
    FROM Partida Pi JOIN Dupla Di
        ON ((Pi.Dup1_Jog1 = Di.Jogador1 AND Pi.Dup1_Jog2 = Di.Jogador2)     
        OR (Pi.Dup2_Jog1 = Di.Jogador1 AND Pi.Dup2_Jog2 = Di.Jogador2))
    WHERE (Di.Nome = 'EC19' AND Pi.Campeonato NOT IN (                          -- que nao fazem parte dos campeonatos da dupla
        SELECT Pii.Campeonato                                                   -- Calcula todos campeonatos da Dupla
        FROM Partida Pii
        WHERE ((Pii.Dup1_Jog1 = De.Jogador1 AND Pii.Dup1_Jog2 = De.Jogador2)    
            OR (Pii.Dup2_Jog1 = De.Jogador1 AND Pii.Dup2_Jog2 = De.Jogador2))
    ))
);
SELECT plan_table_output FROM TABLE(dbms_xplan.display());

-- Teste com MINUS
EXPLAIN PLAN FOR
SELECT De.Nome FROM Dupla De WHERE NOT EXISTS (
    SELECT Pi.Campeonato                                                        -- todos campeonatos da EC19
    FROM Partida Pi JOIN Dupla Di
        ON ((Pi.Dup1_Jog1 = Di.Jogador1 AND Pi.Dup1_Jog2 = Di.Jogador2)     
        OR (Pi.Dup2_Jog1 = Di.Jogador1 AND Pi.Dup2_Jog2 = Di.Jogador2))
    WHERE (Di.Nome = 'EC19') 
    MINUS (                                                                     -- menos
        SELECT Pii.Campeonato                                                   -- todos campeonatos da Dupla
        FROM Partida Pii
        WHERE ((Pii.Dup1_Jog1 = De.Jogador1 AND Pii.Dup1_Jog2 = De.Jogador2)    
            OR (Pii.Dup2_Jog1 = De.Jogador1 AND Pii.Dup2_Jog2 = De.Jogador2))
    )
);
SELECT plan_table_output FROM TABLE(dbms_xplan.display());

-- Uma terceira opcao seria utilizar mais um NOT EXISTS ao inves do NOT IN e mover a condicao para a consulta interna.
-- Embora o plano de execucao permaneca o mesmo, essa solucao eh mais confusa
EXPLAIN PLAN FOR
SELECT De.Nome FROM Dupla De WHERE NOT EXISTS (
    SELECT Pi.Campeonato                                                        -- todos campeonatos da EC19
    FROM Partida Pi JOIN Dupla Di
        ON ((Pi.Dup1_Jog1 = Di.Jogador1 AND Pi.Dup1_Jog2 = Di.Jogador2)     
        OR (Pi.Dup2_Jog1 = Di.Jogador1 AND Pi.Dup2_Jog2 = Di.Jogador2))
    WHERE (Di.Nome = 'EC19' AND NOT EXISTS (                                    -- Checa se o select mais interno retorna null, i.e., a dupla De. nao participou de algum campeonato
        SELECT Pii.Campeonato                                                   -- Checa para cada campeonato que a EC19 participou se a dupla De tambem participou. Se a dupla De NAO participou, entao retorna null
        FROM Partida Pii
        WHERE (((Pii.Dup1_Jog1 = De.Jogador1 AND Pii.Dup1_Jog2 = De.Jogador2)    
            OR  (Pii.Dup2_Jog1 = De.Jogador1 AND Pii.Dup2_Jog2 = De.Jogador2))
            AND Pi.Campeonato = Pii.Campeonato)
    ))
);
SELECT plan_table_output FROM TABLE(dbms_xplan.display());
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
