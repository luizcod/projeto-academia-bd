DROP DATABASE IF EXISTS academia_db;
CREATE DATABASE academia_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE academia_db;

CREATE TABLE Academia (
    cnpj   CHAR(14)     NOT NULL,
    cidade VARCHAR(80)  NOT NULL,
    uf     CHAR(2)      NOT NULL,
    rua    VARCHAR(120) NOT NULL,
    PRIMARY KEY (cnpj)
) ENGINE=InnoDB;

CREATE TABLE Fornecedor (
    cnpj          CHAR(14)      NOT NULL,
    preco_produto DECIMAL(10,2),
    cidade        VARCHAR(80)   NOT NULL,
    uf            CHAR(2)       NOT NULL,
    rua           VARCHAR(120)  NOT NULL,
    PRIMARY KEY (cnpj),
    CONSTRAINT ck_fornecedor_preco CHECK (preco_produto > 0)
) ENGINE=InnoDB;

CREATE TABLE Fornecedor_Telefone (
    cnpj_fornecedor CHAR(14)    NOT NULL,
    telefone        VARCHAR(20) NOT NULL,
    PRIMARY KEY (cnpj_fornecedor, telefone),
    CONSTRAINT fk_ftel_fornecedor FOREIGN KEY (cnpj_fornecedor)
        REFERENCES Fornecedor (cnpj) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Produtos (
    id_produto      INT           NOT NULL AUTO_INCREMENT,
    nome            VARCHAR(100)  NOT NULL,
    tipo_produto    VARCHAR(50),
    preco           DECIMAL(10,2) NOT NULL,
    quantidade      INT           NOT NULL DEFAULT 0,
    cnpj_academia   CHAR(14)      NOT NULL,
    cnpj_fornecedor CHAR(14)      NOT NULL,
    PRIMARY KEY (id_produto),
    CONSTRAINT fk_produto_academia   FOREIGN KEY (cnpj_academia)   REFERENCES Academia (cnpj),
    CONSTRAINT fk_produto_fornecedor FOREIGN KEY (cnpj_fornecedor) REFERENCES Fornecedor (cnpj),
    CONSTRAINT ck_produto_preco CHECK (preco > 0),
    CONSTRAINT ck_produto_qtd   CHECK (quantidade >= 0)
) ENGINE=InnoDB;

CREATE TABLE Zelador (
    cpf           CHAR(11)     NOT NULL,
    nome          VARCHAR(100) NOT NULL,
    turno         VARCHAR(20),
    cnpj_academia CHAR(14)     NOT NULL,
    PRIMARY KEY (cpf),
    CONSTRAINT fk_zelador_academia FOREIGN KEY (cnpj_academia) REFERENCES Academia (cnpj),
    CONSTRAINT ck_zelador_turno CHECK (turno IN ('Manha','Tarde','Noite'))
) ENGINE=InnoDB;

CREATE TABLE Despesas (
    id_despesas   INT           NOT NULL AUTO_INCREMENT,
    categoria     VARCHAR(50)   NOT NULL,
    valor         DECIMAL(10,2) NOT NULL,
    descricao     VARCHAR(255),
    data_despesas DATE          NOT NULL,
    cnpj_academia CHAR(14)      NOT NULL,
    PRIMARY KEY (id_despesas),
    CONSTRAINT fk_despesa_academia FOREIGN KEY (cnpj_academia) REFERENCES Academia (cnpj),
    CONSTRAINT ck_despesa_valor CHECK (valor > 0)
) ENGINE=InnoDB;

CREATE TABLE Plano (
    id_plano      INT           NOT NULL AUTO_INCREMENT,
    nome_plano    VARCHAR(60)   NOT NULL,
    preco         DECIMAL(10,2) NOT NULL,
    duracao       INT           NOT NULL COMMENT 'Duração em meses',
    cnpj_academia CHAR(14)      NOT NULL,
    PRIMARY KEY (id_plano),
    CONSTRAINT fk_plano_academia FOREIGN KEY (cnpj_academia) REFERENCES Academia (cnpj),
    CONSTRAINT ck_plano_preco   CHECK (preco > 0),
    CONSTRAINT ck_plano_duracao CHECK (duracao > 0)
) ENGINE=InnoDB;

CREATE TABLE Professor (
    cpf              CHAR(11)     NOT NULL,
    nome             VARCHAR(100) NOT NULL,
    horario_trabalho VARCHAR(50),
    especialidade    VARCHAR(80),
    PRIMARY KEY (cpf)
) ENGINE=InnoDB;

CREATE TABLE Professor_Telefone (
    cpf_professor CHAR(11)    NOT NULL,
    telefone      VARCHAR(20) NOT NULL,
    PRIMARY KEY (cpf_professor, telefone),
    CONSTRAINT fk_ptel_professor FOREIGN KEY (cpf_professor)
        REFERENCES Professor (cpf) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Professor_Email (
    cpf_professor CHAR(11)     NOT NULL,
    email         VARCHAR(120) NOT NULL,
    PRIMARY KEY (cpf_professor, email),
    UNIQUE KEY uq_professor_email (email),
    CONSTRAINT fk_pemail_professor FOREIGN KEY (cpf_professor)
        REFERENCES Professor (cpf) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Plano_Professor (
    id_plano      INT      NOT NULL,
    cpf_professor CHAR(11) NOT NULL,
    PRIMARY KEY (id_plano, cpf_professor),
    CONSTRAINT fk_pp_plano     FOREIGN KEY (id_plano)      REFERENCES Plano (id_plano) ON DELETE CASCADE,
    CONSTRAINT fk_pp_professor FOREIGN KEY (cpf_professor) REFERENCES Professor (cpf)  ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Aluno (
    cpf             CHAR(11)     NOT NULL,
    nome            VARCHAR(100) NOT NULL,
    data_nascimento DATE,
    cidade          VARCHAR(80),
    uf              CHAR(2),
    rua             VARCHAR(120),
    PRIMARY KEY (cpf)
) ENGINE=InnoDB;

CREATE TABLE Aluno_Telefone (
    cpf_aluno CHAR(11)    NOT NULL,
    telefone  VARCHAR(20) NOT NULL,
    PRIMARY KEY (cpf_aluno, telefone),
    CONSTRAINT fk_atel_aluno FOREIGN KEY (cpf_aluno)
        REFERENCES Aluno (cpf) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Aluno_Email (
    cpf_aluno CHAR(11)     NOT NULL,
    email     VARCHAR(120) NOT NULL,
    PRIMARY KEY (cpf_aluno, email),
    UNIQUE KEY uq_aluno_email (email),
    CONSTRAINT fk_aemail_aluno FOREIGN KEY (cpf_aluno)
        REFERENCES Aluno (cpf) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Matricula (
    id_matricula       INT         NOT NULL AUTO_INCREMENT,
    status_mensalidade VARCHAR(20) NOT NULL DEFAULT 'Em dia',
    frequencia         INT         DEFAULT 0,
    cpf_aluno          CHAR(11)    NOT NULL,
    PRIMARY KEY (id_matricula),
    UNIQUE KEY uq_matricula_aluno (cpf_aluno),
    CONSTRAINT fk_matricula_aluno FOREIGN KEY (cpf_aluno) REFERENCES Aluno (cpf),
    CONSTRAINT ck_matricula_status CHECK (status_mensalidade IN ('Em dia','Atrasada','Pendente')),
    CONSTRAINT ck_matricula_freq   CHECK (frequencia >= 0)
) ENGINE=InnoDB;

CREATE TABLE Plano_Matricula (
    id_plano     INT NOT NULL,
    id_matricula INT NOT NULL,
    PRIMARY KEY (id_plano, id_matricula),
    CONSTRAINT fk_pm_plano     FOREIGN KEY (id_plano)     REFERENCES Plano (id_plano)         ON DELETE CASCADE,
    CONSTRAINT fk_pm_matricula FOREIGN KEY (id_matricula) REFERENCES Matricula (id_matricula) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Exercicios (
    id_exercicios      INT          NOT NULL AUTO_INCREMENT,
    tipos_de_atividade VARCHAR(60)  NOT NULL,
    descricao          VARCHAR(255),
    nr_atividade       INT,
    cpf_aluno          CHAR(11)     NOT NULL,
    PRIMARY KEY (id_exercicios),
    CONSTRAINT fk_exercicio_aluno FOREIGN KEY (cpf_aluno) REFERENCES Aluno (cpf),
    CONSTRAINT ck_exercicio_nr CHECK (nr_atividade > 0)
) ENGINE=InnoDB;

CREATE TABLE Tecnico (
    cpf           CHAR(11)     NOT NULL,
    nome          VARCHAR(100) NOT NULL,
    especialidade VARCHAR(80),
    PRIMARY KEY (cpf)
) ENGINE=InnoDB;

CREATE TABLE Tecnico_Telefone (
    cpf_tecnico CHAR(11)    NOT NULL,
    telefone    VARCHAR(20) NOT NULL,
    PRIMARY KEY (cpf_tecnico, telefone),
    CONSTRAINT fk_ttel_tecnico FOREIGN KEY (cpf_tecnico)
        REFERENCES Tecnico (cpf) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Equipamentos (
    id_equipamentos INT         NOT NULL AUTO_INCREMENT,
    marca           VARCHAR(60),
    data_aquisicao  DATE,
    status_atual    VARCHAR(30) DEFAULT 'Ativo',
    PRIMARY KEY (id_equipamentos),
    CONSTRAINT ck_equip_status CHECK (status_atual IN ('Ativo','Manutencao','Inativo'))
) ENGINE=InnoDB;

CREATE TABLE Exercicio_Equipamento (
    id_exercicios   INT NOT NULL,
    id_equipamentos INT NOT NULL,
    PRIMARY KEY (id_exercicios, id_equipamentos),
    CONSTRAINT fk_ee_exercicio   FOREIGN KEY (id_exercicios)   REFERENCES Exercicios (id_exercicios)     ON DELETE CASCADE,
    CONSTRAINT fk_ee_equipamento FOREIGN KEY (id_equipamentos) REFERENCES Equipamentos (id_equipamentos) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Tecnico_Equipamento (
    cpf_tecnico     CHAR(11) NOT NULL,
    id_equipamentos INT      NOT NULL,
    PRIMARY KEY (cpf_tecnico, id_equipamentos),
    CONSTRAINT fk_te_tecnico     FOREIGN KEY (cpf_tecnico)     REFERENCES Tecnico (cpf)                  ON DELETE CASCADE,
    CONSTRAINT fk_te_equipamento FOREIGN KEY (id_equipamentos) REFERENCES Equipamentos (id_equipamentos) ON DELETE CASCADE
) ENGINE=InnoDB;
INSERT INTO Academia VALUES ('12345678000190', 'Brasília', 'DF', 'SQS 308 Bloco A');

INSERT INTO Fornecedor (cnpj, preco_produto, cidade, uf, rua) VALUES
('11000000000101', 129.90, 'Brasília',       'DF', 'SIA Trecho 3 Lote 10'),
('11000000000202',  89.90, 'Goiânia',        'GO', 'Av. Anhanguera 1500'),
('11000000000303',  59.90, 'São Paulo',      'SP', 'Rua da Consolação 800'),
('11000000000404',  39.90, 'Belo Horizonte', 'MG', 'Av. Afonso Pena 2000'),
('11000000000505',  29.90, 'Rio de Janeiro', 'RJ', 'Rua do Catete 120'),
('11000000000606',  49.90, 'Curitiba',       'PR', 'Rua XV de Novembro 300'),
('11000000000707',  24.90, 'Salvador',       'BA', 'Av. Tancredo Neves 900'),
('11000000000808',   8.50, 'Brasília',       'DF', 'SCS Quadra 6 Bloco B'),
('11000000000909',  99.90, 'Anápolis',       'GO', 'Rua Barão do Rio Branco 45'),
('11000000001010', 119.90, 'Uberlândia',     'MG', 'Av. João Naves 700');

INSERT INTO Fornecedor_Telefone VALUES
('11000000000101', '(61) 3333-0001'), ('11000000000202', '(62) 3333-0002'),
('11000000000303', '(11) 3333-0003'), ('11000000000404', '(31) 3333-0004'),
('11000000000505', '(21) 3333-0005'), ('11000000000606', '(41) 3333-0006'),
('11000000000707', '(71) 3333-0007'), ('11000000000808', '(61) 3333-0008'),
('11000000000909', '(62) 3333-0009'), ('11000000001010', '(34) 3333-0010'),
('11000000000101', '(61) 99333-0001');

INSERT INTO Produtos (nome, tipo_produto, preco, quantidade, cnpj_academia, cnpj_fornecedor) VALUES
('Whey Protein 900g',   'Suplemento', 149.90, 40,  '12345678000190', '11000000000101'),
('Creatina 300g',       'Suplemento', 109.90, 35,  '12345678000190', '11000000000202'),
('BCAA 120 cápsulas',   'Suplemento',  79.90, 50,  '12345678000190', '11000000000303'),
('Garrafa Térmica 1L',  'Acessório',   59.90, 80,  '12345678000190', '11000000000404'),
('Luva de Treino',      'Acessório',   44.90, 60,  '12345678000190', '11000000000505'),
('Camiseta Dry Fit',    'Vestuário',   79.90, 100, '12345678000190', '11000000000606'),
('Toalha de Academia',  'Acessório',   34.90, 120, '12345678000190', '11000000000707'),
('Barra Proteica',      'Alimento',    12.00, 300, '12345678000190', '11000000000808'),
('Pré-treino 300g',     'Suplemento', 129.90, 25,  '12345678000190', '11000000000909'),
('Cinto de Musculação', 'Acessório',  149.90, 15,  '12345678000190', '11000000001010');

INSERT INTO Zelador VALUES
('10000000001', 'José Almeida',    'Manha', '12345678000190'),
('10000000002', 'Maria Souza',     'Tarde', '12345678000190'),
('10000000003', 'Carlos Pereira',  'Noite', '12345678000190'),
('10000000004', 'Ana Lima',        'Manha', '12345678000190'),
('10000000005', 'Paulo Ribeiro',   'Tarde', '12345678000190'),
('10000000006', 'Fernanda Costa',  'Noite', '12345678000190'),
('10000000007', 'Roberto Nunes',   'Manha', '12345678000190'),
('10000000008', 'Luciana Barros',  'Tarde', '12345678000190'),
('10000000009', 'Marcos Teixeira', 'Noite', '12345678000190'),
('10000000010', 'Patrícia Gomes',  'Manha', '12345678000190');

INSERT INTO Despesas (categoria, valor, descricao, data_despesas, cnpj_academia) VALUES
('Energia',      2450.00, 'Conta de luz de outubro',   '2026-10-05', '12345678000190'),
('Água',          680.50, 'Conta de água de outubro',  '2026-10-06', '12345678000190'),
('Aluguel',      8500.00, 'Aluguel do imóvel',         '2026-10-10', '12345678000190'),
('Limpeza',       420.00, 'Produtos de limpeza',       '2026-10-12', '12345678000190'),
('Manutenção',    950.00, 'Reparo de esteira',         '2026-10-15', '12345678000190'),
('Internet',      220.00, 'Plano de internet',         '2026-10-15', '12345678000190'),
('Marketing',    1200.00, 'Anúncios em redes sociais', '2026-10-18', '12345678000190'),
('Salários',    18000.00, 'Folha de pagamento',        '2026-10-30', '12345678000190'),
('Equipamentos', 3200.00, 'Compra de halteres',        '2026-10-20', '12345678000190'),
('Impostos',     1750.00, 'Impostos mensais',          '2026-10-25', '12345678000190');

INSERT INTO Plano (nome_plano, preco, duracao, cnpj_academia) VALUES
('Mensal',      120.00,  1, '12345678000190'),
('Trimestral',  330.00,  3, '12345678000190'),
('Semestral',   600.00,  6, '12345678000190'),
('Anual',      1000.00, 12, '12345678000190'),
('Estudante',    90.00,  1, '12345678000190'),
('Casal',       210.00,  1, '12345678000190'),
('Família',     350.00,  1, '12345678000190'),
('Premium',     180.00,  1, '12345678000190'),
('Diurno',      100.00,  1, '12345678000190'),
('Noturno',     110.00,  1, '12345678000190');

INSERT INTO Professor VALUES
('20000000001', 'Rafael Martins',  '06h-12h', 'Hipertrofia'),
('20000000002', 'Juliana Rocha',   '12h-18h', 'Emagrecimento'),
('20000000003', 'Bruno Carvalho',  '18h-22h', 'Funcional'),
('20000000004', 'Camila Duarte',   '06h-12h', 'Reabilitação'),
('20000000005', 'Diego Fernandes', '12h-18h', 'Powerlifting'),
('20000000006', 'Larissa Mendes',  '18h-22h', 'Pilates'),
('20000000007', 'Thiago Araújo',   '06h-12h', 'Crossfit'),
('20000000008', 'Renata Silva',    '12h-18h', 'Condicionamento'),
('20000000009', 'Gustavo Pinto',   '18h-22h', 'Hipertrofia'),
('20000000010', 'Aline Batista',   '06h-12h', 'Alongamento');

INSERT INTO Professor_Telefone VALUES
('20000000001', '(61) 99100-0001'), ('20000000002', '(61) 99100-0002'),
('20000000003', '(61) 99100-0003'), ('20000000004', '(61) 99100-0004'),
('20000000005', '(61) 99100-0005'), ('20000000006', '(61) 99100-0006'),
('20000000007', '(61) 99100-0007'), ('20000000008', '(61) 99100-0008'),
('20000000009', '(61) 99100-0009'), ('20000000010', '(61) 99100-0010');

INSERT INTO Professor_Email VALUES
('20000000001', 'rafael.martins@academia.com'), ('20000000002', 'juliana.rocha@academia.com'),
('20000000003', 'bruno.carvalho@academia.com'), ('20000000004', 'camila.duarte@academia.com'),
('20000000005', 'diego.fernandes@academia.com'), ('20000000006', 'larissa.mendes@academia.com'),
('20000000007', 'thiago.araujo@academia.com'),   ('20000000008', 'renata.silva@academia.com'),
('20000000009', 'gustavo.pinto@academia.com'),   ('20000000010', 'aline.batista@academia.com');

INSERT INTO Plano_Professor VALUES
(1, '20000000001'), (1, '20000000002'), (2, '20000000003'), (3, '20000000004'),
(4, '20000000005'), (5, '20000000006'), (6, '20000000007'), (7, '20000000008'),
(8, '20000000009'), (9, '20000000010'), (10, '20000000001'), (10, '20000000003');

INSERT INTO Aluno VALUES
('30000000001', 'Sara Oliveira',   '2002-03-14', 'Brasília',     'DF', 'QNN 10 Casa 5'),
('30000000002', 'Thomas Ferreira', '2001-07-22', 'Brasília',     'DF', 'QI 15 Lote 3'),
('30000000003', 'Arthur Santos',   '2000-11-02', 'Brasília',     'DF', 'SQN 205 Bloco C'),
('30000000004', 'Beatriz Moreira', '1998-05-30', 'Brasília',     'DF', 'SQS 112 Bloco F'),
('30000000005', 'Felipe Cardoso',  '1995-01-18', 'Taguatinga',   'DF', 'QNA 20 Casa 12'),
('30000000006', 'Gabriela Alves',  '2003-09-09', 'Brasília',     'DF', 'SQN 310 Bloco A'),
('30000000007', 'Henrique Lopes',  '1992-12-25', 'Ceilândia',    'DF', 'QNM 8 Conjunto B'),
('30000000008', 'Isabela Ramos',   '1999-04-03', 'Brasília',     'DF', 'SQS 405 Bloco D'),
('30000000009', 'João Vieira',     '1990-08-17', 'Águas Claras', 'DF', 'Rua 25 Norte 10'),
('30000000010', 'Karina Melo',     '2004-02-11', 'Brasília',     'DF', 'SQN 114 Bloco B'),
('30000000011', 'Leonardo Dias',   '1997-06-27', 'Brasília',     'DF', 'SQS 207 Bloco G'),
('30000000012', 'Mariana Freitas', '1996-10-05', 'Sobradinho',   'DF', 'Quadra 5 Casa 20');

INSERT INTO Aluno_Telefone VALUES
('30000000001', '(61) 98200-0001'), ('30000000002', '(61) 98200-0002'),
('30000000003', '(61) 98200-0003'), ('30000000004', '(61) 98200-0004'),
('30000000005', '(61) 98200-0005'), ('30000000006', '(61) 98200-0006'),
('30000000007', '(61) 98200-0007'), ('30000000008', '(61) 98200-0008'),
('30000000009', '(61) 98200-0009'), ('30000000010', '(61) 98200-0010'),
('30000000011', '(61) 98200-0011'), ('30000000012', '(61) 98200-0012'),
('30000000001', '(61) 3200-0001');

INSERT INTO Aluno_Email VALUES
('30000000001', 'sara.oliveira@email.com'),   ('30000000002', 'thomas.ferreira@email.com'),
('30000000003', 'arthur.santos@email.com'),   ('30000000004', 'beatriz.moreira@email.com'),
('30000000005', 'felipe.cardoso@email.com'),  ('30000000006', 'gabriela.alves@email.com'),
('30000000007', 'henrique.lopes@email.com'),  ('30000000008', 'isabela.ramos@email.com'),
('30000000009', 'joao.vieira@email.com'),     ('30000000010', 'karina.melo@email.com'),
('30000000011', 'leonardo.dias@email.com'),   ('30000000012', 'mariana.freitas@email.com');

INSERT INTO Matricula (status_mensalidade, frequencia, cpf_aluno) VALUES
('Em dia',   12, '30000000001'), ('Em dia',   20, '30000000002'),
('Atrasada',  8, '30000000003'), ('Em dia',   15, '30000000004'),
('Em dia',   25, '30000000005'), ('Pendente',  5, '30000000006'),
('Em dia',   18, '30000000007'), ('Em dia',   10, '30000000008'),
('Em dia',   30, '30000000009'), ('Atrasada',  3, '30000000010'),
('Em dia',   22, '30000000011'), ('Em dia',   14, '30000000012');

INSERT INTO Plano_Matricula VALUES
(1, 1), (2, 2), (1, 3), (4, 4), (3, 5), (5, 6),
(8, 7), (6, 8), (4, 9), (5, 10), (10, 11), (7, 12);

INSERT INTO Exercicios (tipos_de_atividade, descricao, nr_atividade, cpf_aluno) VALUES
('Musculação', 'Supino reto com barra',   1,  '30000000001'),
('Musculação', 'Agachamento livre',       2,  '30000000001'),
('Musculação', 'Levantamento terra',      3,  '30000000002'),
('Musculação', 'Rosca direta',            4,  '30000000004'),
('Cardio',     'Corrida na esteira',      5,  '30000000005'),
('Cardio',     'Bicicleta ergométrica',   6,  '30000000006'),
('Musculação', 'Leg press 45 graus',      7,  '30000000007'),
('Musculação', 'Puxada alta na polia',    8,  '30000000009'),
('Funcional',  'Remada na máquina',       9,  '30000000011'),
('Cardio',     'Simulador de escada',    10,  '30000000012');

INSERT INTO Tecnico VALUES
('40000000001', 'Anderson Pacheco', 'Esteiras'),
('40000000002', 'Cláudio Moura',    'Máquinas de peso'),
('40000000003', 'Eduardo Santana',  'Bicicletas'),
('40000000004', 'Fábio Nogueira',   'Elétrica'),
('40000000005', 'Gilberto Rezende', 'Polias e cabos'),
('40000000006', 'Hugo Barbosa',     'Máquinas de peso'),
('40000000007', 'Igor Cunha',       'Esteiras'),
('40000000008', 'Jair Monteiro',    'Elípticos'),
('40000000009', 'Kleber Assis',     'Geral'),
('40000000010', 'Leandro Prado',    'Geral');

INSERT INTO Tecnico_Telefone VALUES
('40000000001', '(61) 99300-0001'), ('40000000002', '(61) 99300-0002'),
('40000000003', '(61) 99300-0003'), ('40000000004', '(61) 99300-0004'),
('40000000005', '(61) 99300-0005'), ('40000000006', '(61) 99300-0006'),
('40000000007', '(61) 99300-0007'), ('40000000008', '(61) 99300-0008'),
('40000000009', '(61) 99300-0009'), ('40000000010', '(61) 99300-0010');

INSERT INTO Equipamentos (marca, data_aquisicao, status_atual) VALUES
('Movement',     '2022-03-10', 'Ativo'),
('Technogym',    '2021-07-15', 'Ativo'),
('Life Fitness', '2023-01-20', 'Ativo'),
('Movement',     '2022-09-05', 'Manutencao'),
('Technogym',    '2020-11-30', 'Ativo'),
('Kikos',        '2023-05-12', 'Ativo'),
('Movement',     '2021-02-18', 'Inativo'),
('Life Fitness', '2024-04-08', 'Ativo'),
('Technogym',    '2022-12-01', 'Ativo'),
('Kikos',        '2024-08-22', 'Ativo');

INSERT INTO Exercicio_Equipamento VALUES
(1, 2), (2, 2), (3, 5), (4, 6), (5, 1), (5, 7), (6, 3), (7, 2), (8, 5), (9, 6), (10, 8);

INSERT INTO Tecnico_Equipamento VALUES
('40000000001', 1), ('40000000002', 2), ('40000000003', 3), ('40000000004', 4),
('40000000005', 5), ('40000000006', 6), ('40000000007', 7), ('40000000008', 8),
('40000000009', 9), ('40000000010', 10), ('40000000009', 4);
