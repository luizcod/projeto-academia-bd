DROP DATABASE IF EXISTS academia_db;
CREATE DATABASE academia_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE academia_db;

CREATE TABLE Academia (
    cnpj    CHAR(14)     NOT NULL,
    cidade  VARCHAR(80)  NOT NULL,
    uf      CHAR(2)      NOT NULL,
    rua     VARCHAR(120) NOT NULL,
    PRIMARY KEY (cnpj)
) ENGINE=InnoDB;

CREATE TABLE Fornecedor (
    cnpj          CHAR(14)     NOT NULL,
    cidade        VARCHAR(80)  NOT NULL,
    uf            CHAR(2)      NOT NULL,
    rua           VARCHAR(120) NOT NULL,
    telefone      VARCHAR(20),
    cnpj_academia CHAR(14)     NOT NULL,
    PRIMARY KEY (cnpj),
    CONSTRAINT fk_fornecedor_academia
        FOREIGN KEY (cnpj_academia) REFERENCES Academia (cnpj)
) ENGINE=InnoDB;

CREATE TABLE Produtos (
    id_produto      INT           NOT NULL AUTO_INCREMENT,
    nome            VARCHAR(100)  NOT NULL,
    tipo_produto    VARCHAR(50),
    preco_produto   DECIMAL(10,2) NOT NULL,
    quantidade      INT           NOT NULL DEFAULT 0,
    cnpj_fornecedor CHAR(14)      NOT NULL,
    PRIMARY KEY (id_produto),
    CONSTRAINT fk_produto_fornecedor
        FOREIGN KEY (cnpj_fornecedor) REFERENCES Fornecedor (cnpj),
    CONSTRAINT ck_produto_preco CHECK (preco_produto > 0),
    CONSTRAINT ck_produto_qtd   CHECK (quantidade >= 0)
) ENGINE=InnoDB;

CREATE TABLE Zelador (
    cpf           CHAR(11)     NOT NULL,
    nome          VARCHAR(100) NOT NULL,
    turno         VARCHAR(20),
    cnpj_academia CHAR(14)     NOT NULL,
    PRIMARY KEY (cpf),
    CONSTRAINT fk_zelador_academia
        FOREIGN KEY (cnpj_academia) REFERENCES Academia (cnpj),
    CONSTRAINT ck_zelador_turno CHECK (turno IN ('Manha','Tarde','Noite'))
) ENGINE=InnoDB;

CREATE TABLE Despesas (
    id_despesas    INT           NOT NULL AUTO_INCREMENT,
    categoria      VARCHAR(50)   NOT NULL,
    valor          DECIMAL(10,2) NOT NULL,
    descricao      VARCHAR(255),
    data_despesas  DATE          NOT NULL,
    cnpj_academia  CHAR(14)      NOT NULL,
    PRIMARY KEY (id_despesas),
    CONSTRAINT fk_despesa_academia
        FOREIGN KEY (cnpj_academia) REFERENCES Academia (cnpj),
    CONSTRAINT ck_despesa_valor CHECK (valor > 0)
) ENGINE=InnoDB;

CREATE TABLE Plano (
    id_plano      INT           NOT NULL AUTO_INCREMENT,
    nome_plano    VARCHAR(60)   NOT NULL,
    preco         DECIMAL(10,2) NOT NULL,
    duracao       INT           NOT NULL COMMENT 'Duração em meses',
    cnpj_academia CHAR(14)      NOT NULL,
    PRIMARY KEY (id_plano),
    CONSTRAINT fk_plano_academia
        FOREIGN KEY (cnpj_academia) REFERENCES Academia (cnpj),
    CONSTRAINT ck_plano_preco   CHECK (preco > 0),
    CONSTRAINT ck_plano_duracao CHECK (duracao > 0)
) ENGINE=InnoDB;

CREATE TABLE Professor (
    cpf              CHAR(11)     NOT NULL,
    nome             VARCHAR(100) NOT NULL,
    horario_trabalho VARCHAR(50),
    especialidade    VARCHAR(80),
    telefone         VARCHAR(20),
    email            VARCHAR(120),
    cnpj_academia    CHAR(14)     NOT NULL,
    PRIMARY KEY (cpf),
    UNIQUE KEY uq_professor_email (email),
    CONSTRAINT fk_professor_academia
        FOREIGN KEY (cnpj_academia) REFERENCES Academia (cnpj)
) ENGINE=InnoDB;

CREATE TABLE Aluno (
    id_matricula       INT          NOT NULL AUTO_INCREMENT,
    cpf                CHAR(11)     NOT NULL,
    nome               VARCHAR(100) NOT NULL,
    data_nascimento    DATE,
    cidade             VARCHAR(80),
    uf                 CHAR(2),
    rua                VARCHAR(120),
    telefone           VARCHAR(20),
    email              VARCHAR(120),
    frequencia         INT          DEFAULT 0,
    status_mensalidade VARCHAR(20)  DEFAULT 'Em dia',
    id_plano           INT          NOT NULL,
    cnpj_academia      CHAR(14)     NOT NULL,
    PRIMARY KEY (id_matricula),
    UNIQUE KEY uq_aluno_cpf (cpf),
    UNIQUE KEY uq_aluno_email (email),
    CONSTRAINT fk_aluno_plano
        FOREIGN KEY (id_plano) REFERENCES Plano (id_plano),
    CONSTRAINT fk_aluno_academia
        FOREIGN KEY (cnpj_academia) REFERENCES Academia (cnpj),
    CONSTRAINT ck_aluno_freq   CHECK (frequencia >= 0),
    CONSTRAINT ck_aluno_status CHECK (status_mensalidade IN ('Em dia','Atrasada','Pendente'))
) ENGINE=InnoDB;

CREATE TABLE Exercicios (
    id_exercicios      INT          NOT NULL AUTO_INCREMENT,
    tipos_de_atividade VARCHAR(60)  NOT NULL,
    descricao          VARCHAR(255),
    nr_atividade       INT,
    PRIMARY KEY (id_exercicios),
    CONSTRAINT ck_exercicio_nr CHECK (nr_atividade > 0)
) ENGINE=InnoDB;

CREATE TABLE Tecnico (
    cpf           CHAR(11)     NOT NULL,
    nome          VARCHAR(100) NOT NULL,
    especialidade VARCHAR(80),
    telefone      VARCHAR(20),
    PRIMARY KEY (cpf)
) ENGINE=InnoDB;

CREATE TABLE Equipamentos (
    id_equipamentos INT          NOT NULL AUTO_INCREMENT,
    marca           VARCHAR(60),
    data_aquisicao  DATE,
    status_atual    VARCHAR(30)  DEFAULT 'Ativo',
    cnpj_academia   CHAR(14)     NOT NULL,
    cpf_tecnico     CHAR(11),
    PRIMARY KEY (id_equipamentos),
    CONSTRAINT fk_equip_academia
        FOREIGN KEY (cnpj_academia) REFERENCES Academia (cnpj),
    CONSTRAINT fk_equip_tecnico
        FOREIGN KEY (cpf_tecnico) REFERENCES Tecnico (cpf),
    CONSTRAINT ck_equip_status CHECK (status_atual IN ('Ativo','Manutencao','Inativo'))
) ENGINE=InnoDB;

CREATE TABLE Aluno_Exercicio (
    id_matricula  INT NOT NULL,
    id_exercicios INT NOT NULL,
    PRIMARY KEY (id_matricula, id_exercicios),
    CONSTRAINT fk_ae_aluno
        FOREIGN KEY (id_matricula) REFERENCES Aluno (id_matricula)
        ON DELETE CASCADE,
    CONSTRAINT fk_ae_exercicio
        FOREIGN KEY (id_exercicios) REFERENCES Exercicios (id_exercicios)
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Exercicio_Equipamento (
    id_exercicios   INT NOT NULL,
    id_equipamentos INT NOT NULL,
    PRIMARY KEY (id_exercicios, id_equipamentos),
    CONSTRAINT fk_ee_exercicio
        FOREIGN KEY (id_exercicios) REFERENCES Exercicios (id_exercicios)
        ON DELETE CASCADE,
    CONSTRAINT fk_ee_equipamento
        FOREIGN KEY (id_equipamentos) REFERENCES Equipamentos (id_equipamentos)
        ON DELETE CASCADE
) ENGINE=InnoDB;
INSERT INTO Academia (cnpj, cidade, uf, rua) VALUES
('12345678000190', 'Brasília', 'DF', 'SQS 308 Bloco A');

INSERT INTO Fornecedor (cnpj, cidade, uf, rua, telefone, cnpj_academia) VALUES
('11000000000101', 'Brasília',       'DF', 'SIA Trecho 3 Lote 10',   '(61) 3333-0001', '12345678000190'),
('11000000000202', 'Goiânia',        'GO', 'Av. Anhanguera 1500',    '(62) 3333-0002', '12345678000190'),
('11000000000303', 'São Paulo',      'SP', 'Rua da Consolação 800',  '(11) 3333-0003', '12345678000190'),
('11000000000404', 'Belo Horizonte', 'MG', 'Av. Afonso Pena 2000',   '(31) 3333-0004', '12345678000190'),
('11000000000505', 'Rio de Janeiro', 'RJ', 'Rua do Catete 120',      '(21) 3333-0005', '12345678000190'),
('11000000000606', 'Curitiba',       'PR', 'Rua XV de Novembro 300', '(41) 3333-0006', '12345678000190'),
('11000000000707', 'Salvador',       'BA', 'Av. Tancredo Neves 900', '(71) 3333-0007', '12345678000190'),
('11000000000808', 'Brasília',       'DF', 'SCS Quadra 6 Bloco B',   '(61) 3333-0008', '12345678000190'),
('11000000000909', 'Anápolis',       'GO', 'Rua Barão do Rio Branco 45', '(62) 3333-0009', '12345678000190'),
('11000000001010', 'Uberlândia',     'MG', 'Av. João Naves 700',     '(34) 3333-0010', '12345678000190');

INSERT INTO Produtos (nome, tipo_produto, preco_produto, quantidade, cnpj_fornecedor) VALUES
('Whey Protein 900g',    'Suplemento', 129.90, 40,  '11000000000101'),
('Creatina 300g',        'Suplemento',  89.90, 35,  '11000000000202'),
('BCAA 120 cápsulas',    'Suplemento',  59.90, 50,  '11000000000303'),
('Garrafa Térmica 1L',   'Acessório',   39.90, 80,  '11000000000404'),
('Luva de Treino',       'Acessório',   29.90, 60,  '11000000000505'),
('Camiseta Dry Fit',     'Vestuário',   49.90, 100, '11000000000606'),
('Toalha de Academia',   'Acessório',   24.90, 120, '11000000000707'),
('Barra Proteica',       'Alimento',     8.50, 300, '11000000000808'),
('Pré-treino 300g',      'Suplemento',  99.90, 25,  '11000000000909'),
('Cinto de Musculação',  'Acessório',  119.90, 15,  '11000000001010');

INSERT INTO Zelador (cpf, nome, turno, cnpj_academia) VALUES
('10000000001', 'José Almeida',      'Manha', '12345678000190'),
('10000000002', 'Maria Souza',       'Tarde', '12345678000190'),
('10000000003', 'Carlos Pereira',    'Noite', '12345678000190'),
('10000000004', 'Ana Lima',          'Manha', '12345678000190'),
('10000000005', 'Paulo Ribeiro',     'Tarde', '12345678000190'),
('10000000006', 'Fernanda Costa',    'Noite', '12345678000190'),
('10000000007', 'Roberto Nunes',     'Manha', '12345678000190'),
('10000000008', 'Luciana Barros',    'Tarde', '12345678000190'),
('10000000009', 'Marcos Teixeira',   'Noite', '12345678000190'),
('10000000010', 'Patrícia Gomes',    'Manha', '12345678000190');

INSERT INTO Despesas (categoria, valor, descricao, data_despesas, cnpj_academia) VALUES
('Energia',     2450.00, 'Conta de luz de outubro',        '2026-10-05', '12345678000190'),
('Água',         680.50, 'Conta de água de outubro',       '2026-10-06', '12345678000190'),
('Aluguel',     8500.00, 'Aluguel do imóvel',              '2026-10-10', '12345678000190'),
('Limpeza',      420.00, 'Produtos de limpeza',            '2026-10-12', '12345678000190'),
('Manutenção',   950.00, 'Reparo de esteira',              '2026-10-15', '12345678000190'),
('Internet',     220.00, 'Plano de internet',              '2026-10-15', '12345678000190'),
('Marketing',   1200.00, 'Anúncios em redes sociais',      '2026-10-18', '12345678000190'),
('Salários',   18000.00, 'Folha de pagamento',             '2026-10-30', '12345678000190'),
('Equipamentos',3200.00, 'Compra de halteres',             '2026-10-20', '12345678000190'),
('Impostos',    1750.00, 'Impostos mensais',               '2026-10-25', '12345678000190');

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

INSERT INTO Professor (cpf, nome, horario_trabalho, especialidade, telefone, email, cnpj_academia) VALUES
('20000000001', 'Rafael Martins',   '06h-12h', 'Hipertrofia',       '(61) 99100-0001', 'rafael.martins@academia.com',   '12345678000190'),
('20000000002', 'Juliana Rocha',    '12h-18h', 'Emagrecimento',     '(61) 99100-0002', 'juliana.rocha@academia.com',    '12345678000190'),
('20000000003', 'Bruno Carvalho',   '18h-22h', 'Funcional',         '(61) 99100-0003', 'bruno.carvalho@academia.com',   '12345678000190'),
('20000000004', 'Camila Duarte',    '06h-12h', 'Reabilitação',      '(61) 99100-0004', 'camila.duarte@academia.com',    '12345678000190'),
('20000000005', 'Diego Fernandes',  '12h-18h', 'Powerlifting',      '(61) 99100-0005', 'diego.fernandes@academia.com',  '12345678000190'),
('20000000006', 'Larissa Mendes',   '18h-22h', 'Pilates',           '(61) 99100-0006', 'larissa.mendes@academia.com',   '12345678000190'),
('20000000007', 'Thiago Araújo',    '06h-12h', 'Crossfit',          '(61) 99100-0007', 'thiago.araujo@academia.com',    '12345678000190'),
('20000000008', 'Renata Silva',     '12h-18h', 'Condicionamento',   '(61) 99100-0008', 'renata.silva@academia.com',     '12345678000190'),
('20000000009', 'Gustavo Pinto',    '18h-22h', 'Hipertrofia',       '(61) 99100-0009', 'gustavo.pinto@academia.com',    '12345678000190'),
('20000000010', 'Aline Batista',    '06h-12h', 'Alongamento',       '(61) 99100-0010', 'aline.batista@academia.com',    '12345678000190');

INSERT INTO Aluno (cpf, nome, data_nascimento, cidade, uf, rua, telefone, email, frequencia, status_mensalidade, id_plano, cnpj_academia) VALUES
('30000000001', 'Sara Oliveira',     '2002-03-14', 'Brasília', 'DF', 'QNN 10 Casa 5',     '(61) 98200-0001', 'sara.oliveira@email.com',     12, 'Em dia',   1,  '12345678000190'),
('30000000002', 'Thomas Ferreira',   '2001-07-22', 'Brasília', 'DF', 'QI 15 Lote 3',      '(61) 98200-0002', 'thomas.ferreira@email.com',   20, 'Em dia',   2,  '12345678000190'),
('30000000003', 'Arthur Santos',     '2000-11-02', 'Brasília', 'DF', 'SQN 205 Bloco C',   '(61) 98200-0003', 'arthur.santos@email.com',      8, 'Atrasada', 1,  '12345678000190'),
('30000000004', 'Beatriz Moreira',   '1998-05-30', 'Brasília', 'DF', 'SQS 112 Bloco F',   '(61) 98200-0004', 'beatriz.moreira@email.com',   15, 'Em dia',   4,  '12345678000190'),
('30000000005', 'Felipe Cardoso',    '1995-01-18', 'Taguatinga','DF','QNA 20 Casa 12',    '(61) 98200-0005', 'felipe.cardoso@email.com',    25, 'Em dia',   3,  '12345678000190'),
('30000000006', 'Gabriela Alves',    '2003-09-09', 'Brasília', 'DF', 'SQN 310 Bloco A',   '(61) 98200-0006', 'gabriela.alves@email.com',     5, 'Pendente', 5,  '12345678000190'),
('30000000007', 'Henrique Lopes',    '1992-12-25', 'Ceilândia','DF', 'QNM 8 Conjunto B',  '(61) 98200-0007', 'henrique.lopes@email.com',    18, 'Em dia',   8,  '12345678000190'),
('30000000008', 'Isabela Ramos',     '1999-04-03', 'Brasília', 'DF', 'SQS 405 Bloco D',   '(61) 98200-0008', 'isabela.ramos@email.com',     10, 'Em dia',   6,  '12345678000190'),
('30000000009', 'João Vieira',       '1990-08-17', 'Águas Claras','DF','Rua 25 Norte 10', '(61) 98200-0009', 'joao.vieira@email.com',       30, 'Em dia',   4,  '12345678000190'),
('30000000010', 'Karina Melo',       '2004-02-11', 'Brasília', 'DF', 'SQN 114 Bloco B',   '(61) 98200-0010', 'karina.melo@email.com',        3, 'Atrasada', 5,  '12345678000190'),
('30000000011', 'Leonardo Dias',     '1997-06-27', 'Brasília', 'DF', 'SQS 207 Bloco G',   '(61) 98200-0011', 'leonardo.dias@email.com',     22, 'Em dia',   10, '12345678000190'),
('30000000012', 'Mariana Freitas',   '1996-10-05', 'Sobradinho','DF','Quadra 5 Casa 20',  '(61) 98200-0012', 'mariana.freitas@email.com',   14, 'Em dia',   7,  '12345678000190');

INSERT INTO Exercicios (tipos_de_atividade, descricao, nr_atividade) VALUES
('Musculação', 'Supino reto com barra',        1),
('Musculação', 'Agachamento livre',            2),
('Musculação', 'Levantamento terra',           3),
('Musculação', 'Rosca direta',                 4),
('Cardio',     'Corrida na esteira',           5),
('Cardio',     'Bicicleta ergométrica',        6),
('Musculação', 'Leg press 45 graus',           7),
('Musculação', 'Puxada alta na polia',         8),
('Funcional',  'Remada na máquina',            9),
('Cardio',     'Simulador de escada',         10);

INSERT INTO Tecnico (cpf, nome, especialidade, telefone) VALUES
('40000000001', 'Anderson Pacheco', 'Esteiras',            '(61) 99300-0001'),
('40000000002', 'Cláudio Moura',    'Máquinas de peso',    '(61) 99300-0002'),
('40000000003', 'Eduardo Santana',  'Bicicletas',          '(61) 99300-0003'),
('40000000004', 'Fábio Nogueira',   'Elétrica',            '(61) 99300-0004'),
('40000000005', 'Gilberto Rezende', 'Polias e cabos',      '(61) 99300-0005'),
('40000000006', 'Hugo Barbosa',     'Máquinas de peso',    '(61) 99300-0006'),
('40000000007', 'Igor Cunha',       'Esteiras',            '(61) 99300-0007'),
('40000000008', 'Jair Monteiro',    'Elípticos',           '(61) 99300-0008'),
('40000000009', 'Kleber Assis',     'Geral',               '(61) 99300-0009'),
('40000000010', 'Leandro Prado',    'Geral',               '(61) 99300-0010');

INSERT INTO Equipamentos (marca, data_aquisicao, status_atual, cnpj_academia, cpf_tecnico) VALUES
('Movement',   '2022-03-10', 'Ativo',      '12345678000190', '40000000001'),
('Technogym',  '2021-07-15', 'Ativo',      '12345678000190', '40000000002'),
('Life Fitness','2023-01-20','Ativo',      '12345678000190', '40000000003'),
('Movement',   '2022-09-05', 'Manutencao', '12345678000190', '40000000004'),
('Technogym',  '2020-11-30', 'Ativo',      '12345678000190', '40000000005'),
('Kikos',      '2023-05-12', 'Ativo',      '12345678000190', '40000000006'),
('Movement',   '2021-02-18', 'Inativo',    '12345678000190', '40000000007'),
('Life Fitness','2024-04-08','Ativo',      '12345678000190', '40000000008'),
('Technogym',  '2022-12-01', 'Ativo',      '12345678000190', '40000000009'),
('Kikos',      '2024-08-22', 'Ativo',      '12345678000190', '40000000010');

INSERT INTO Aluno_Exercicio (id_matricula, id_exercicios) VALUES
(1, 1), (1, 2), (2, 3), (2, 5), (3, 6), (4, 1), (4, 7), (5, 2), (5, 3),
(6, 5), (7, 8), (8, 9), (9, 1), (9, 4), (10, 6), (11, 7), (12, 10);

INSERT INTO Exercicio_Equipamento (id_exercicios, id_equipamentos) VALUES
(1, 2), (2, 2), (3, 5), (4, 6), (5, 1), (5, 7), (6, 3), (7, 2), (8, 5), (9, 6), (10, 8);