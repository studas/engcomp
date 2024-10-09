-- IMPORTANTE: confiram algumas respostas, porque nem todas elas foram conferidas com a elaine... se você acha que algo não faz sentido provavelmente é porque não faz

-- 1
SELECT time1, time2, data
FROM partida
WHERE local = 'SANTOS';

-- 2
-- a
SELECT data, local
FROM partida
WHERE 'PALMEIRAS' IN (time1, time2)

-- b
SELECT TO_CHAR(data, 'yyyy-mm-dd'), local
FROM partida
WHERE 'PALMEIRAS' IN (time1, time2);

-- 3
-- a
SELECT j.CPF, j.nome, (CURRENT_DATE - j.data_nasc)/365 AS idade, j.time,
       t.estado
FROM jogador j, time t;

-- b
SELECT j.CPF, j.nome, (CURRENT_DATE - j.data_nasc)/365 AS idade, j.time,
       t.estado
FROM Jogador j
  JOIN time t ON j.time = t.nome;

-- 4
-- a
SELECT j.CPF, j.nome, j.data_nasc, j.time, t.estado
FROM jogador j, time t
WHERE j.time = t.nome AND t.estado = 'SP';

-- b
SELECT j.CPF, j.nome, j.data_nasc, j.time, t.estado
FROM jogador j
  JOIN time t ON t.nome = j.time
WHERE t.estado = 'SP';

-- 6
SELECT p.time1, p.time2, p.data, p.placar, j.classico
FROM partida p
  JOIN joga j ON p.time1 = j.time1 AND p.time2 = j.time2
WHERE p.local = 'SANTOS';

-- 7
SELECT j.time1, t1.estado AS estado1, j.time2, t2.estado AS estado2
FROM joga j
  JOIN time t1 ON j.time1 = t1.nome
  JOIN time t2 ON j.time2 = t2.nome
WHERE j.classico = 'S';

-- 8
SELECT u.time, u.cor_principal
FROM uniforme u
  JOIN time t ON u.time = t.nome
WHERE t.estado = 'MG' AND t.tipo = 'PROFISSIONAL' AND u.tipo = 'TITULAR';

-- 9
SELECT p.time1, p.time2, p.data
FROM partida p
  JOIN time t1 ON p.time1 = t1.nome
  JOIN time t2 ON p.time2 = t2.nome
WHERE 'SP' IN (t1.estado, t2.estado);

-- 10
SELECT t.nome
FROM time t
WHERE t.nome NOT IN (
  SELECT t2.nome
  FROM time t2
    JOIN partida p ON t2.nome IN (p.time1, p.time2)
  WHERE p.local IN ('SAO CARLOS', 'BELO HORIZONTE')
);

-- 11
SELECT u.time, t.estado
FROM uniforme u
  JOIN time t ON u.time = t.nome
WHERE u.tipo = 'TITULAR' AND u.cor_principal IS NULL;

-- 12
SELECT jr.nome, jr.data_nasc, jr.time, p.data, p.local, jo.classico
FROM jogador jr
  JOIN joga jo ON jr.time IN (jo.time1, jo.time2)
  JOIN partida p ON p.time1 = jo.time1 AND p.time2 = jo.time2;

-- 13
SELECT t.nome, t.estado, d.nome
FROM time t
  LEFT JOIN diretor d ON t.nome = d.time;

-- 14
SELECT j.classico, COUNT(p.time1) AS quantidade
FROM partida p
  RIGHT JOIN joga j ON p.time1 = j.time1 AND p.time2 = j.time2
    AND EXTRACT(month FROM p.data) IN (1, 2)
WHERE j.classico IS NOT NULL 
GROUP BY j.classico;

-- 15
SELECT EXTRACT(month FROM p.data) AS mes, COUNT(*) AS jogos
FROM partida p
WHERE EXTRACT(year FROM p.data) = 2018
GROUP BY EXTRACT(month FROM p.data)
ORDER BY EXTRACT(month FROM p.data), COUNT(*) DESC;

-- 16
SELECT t.nome, t.estado, t.saldo_gols, EXTRACT(year FROM p.data) AS ano,
    COUNT(j.classico) AS jogos_classicos
FROM time t
  JOIN partida p ON t.nome IN (p.time1, p.time2)
  LEFT JOIN joga j ON p.time1 = j.time1 AND p.time2 = j.time2 AND j.classico = 'S'
GROUP BY t.nome, t.estado, t.saldo_gols, EXTRACT(year FROM p.data);

-- 17
SELECT tfinal.nome
FROM time tfinal
WHERE tfinal.nome IN ((
    SELECT t.nome
    FROM time t
      JOIN joga j ON t.nome IN (j.time1, j.time2)
    WHERE j.classico = 'S'
  ) INTERSECT (
    SELECT t.nome
    FROM time t
      JOIN partida p ON t.nome IN (p.time1, p.time2)
    WHERE t.tipo = 'PROFISSIONAL' AND (t.nome = p.time1 AND p.placar LIKE '0X%')
      OR (t.nome = p.time2 AND p.placar LIKE '%X0')
    GROUP BY t.nome
    HAVING COUNT(p.time1) > 1
  )
);


-- 18
SELECT t.estado, t.tipo, COUNT(t.nome) AS nro_times, AVG(t.saldo_gols) AS media
FROM time t
GROUP BY t.estado, t.tipo
ORDER BY t.estado, t.tipo;

-- 19
SELECT j.time1, j.time2, COUNT(p.time1)
FROM joga j
  LEFT JOIN partida p ON j.time1 = p.time1 AND j.time2 = p.time2
WHERE j.classico = 'S'
GROUP BY j.time1, j.time2;

-- 20
SELECT t.nome
FROM time t
WHERE t.estado = 'SP' AND NOT EXISTS (
    SELECT p.local
    FROM partida p
    WHERE 'SANTOS' IN (p.time1, p.time2)
  ) MINUS (
    SELECT p.local
    FROM partida p
    WHERE t.nome IN (p.time1, p.time2)
  )
;

-- 21
SELECT t.estado, t.nome, t.saldo_gols
FROM time t
WHERE (t.estado, t.saldo_gols) IN (
  SELECT t2.estado, MIN(t2.saldo_gols) 
  FROM time t2 
  GROUP BY t2.estado
);

-- DESAFIO
SELECT jr.nome, jr.data_nasc, jr.time, t.estado, p.data, p.local
FROM jogador jr
  JOIN time t ON jr.time = t.nome
  LEFT JOIN partida p ON jr.time IN (p.time1, p.time2) 
    AND (p.time1, p.time2) IN (
      SELECT j.time1, j.time2 
      FROM joga j
      WHERE j.classico = 'S'
    )
ORDER BY jr.nome;

