-- Active: 1787782734809@@127.0.0.1@5432@bd_aula@public

DROP TABLE aluno;
DROP TABLE curso;


CREATE TABLE curso(
    id_curso INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE aluno(
    id_aluno INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome VARCHAR(80) NOT NULL,
    id_curso INTEGER NOT NULL REFERENCES curso(id_curso)
);


SELECT * FROM curso;

SELECT * FROM aluno;

INSERT INTO curso (nome) VALUES
('Sistemas de Informacao'),
('Administracao'),
('Direito'),
('Ciencia da Computacao');


INSERT INTO aluno (nome, id_curso) VALUES
('Ana Beatriz Souza', 1),
('Carlos Henrique Lima', 1),
('Daniela Martins', 2),
('Eduardo Pereira', 3),
('Fernanda Rocha', 1);


SELECT
    id_aluno AS id,
    nome AS alunos,
    id_curso
FROM
    aluno
ORDER BY
    nome ASC;


SELECT
    id_curso AS id,
    nome AS cursos
FROM
    curso
ORDER BY
    nome;


SELECT
    nome,
    id_curso
FROM
    aluno
WHERE
    id_curso = 1;


SELECT
    c.nome AS curso,
    c.id_curso
FROM
    curso c
WHERE
    c.nome = 'Sistemas de Informacao';


SELECT table_name,
       column_name,
       data_type,
       character_maximum_length AS tamanho,
       is_nullable              AS aceita_nulo,
       is_identity              AS e_identidade
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('curso', 'aluno')
ORDER BY table_name, ordinal_position;


SELECT indexname, indexdef FROM pg_indexes WHERE tablename = 'curso';


--Alunos e os curso
SELECT
    a.nome AS alunos,
    c.nome AS cursos
FROM
    aluno a
    JOIN
        curso c
    ON
        c.id_curso = a.id_curso
ORDER BY
    c.nome DESC;



--Quantidade de alunos por curso
SELECT
    c.nome AS cursos,
    COUNT(a.id_aluno) AS qtd_alunos
FROM
    curso c
    JOIN
        aluno a
    ON
        a.id_curso = c.id_curso
GROUP BY
    c.nome
ORDER BY
    qtd_alunos DESC;