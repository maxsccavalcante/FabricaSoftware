-- Clinica_Care SQL
-- DDL (Criação do Banco e Tabelas)

CREATE DATABASE IF NOT EXISTS clinica_care
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE clinica_care;

-- Tabela: pacientes
CREATE TABLE pacientes (
    id_paciente     INT AUTO_INCREMENT PRIMARY KEY,
    nome_completo   VARCHAR(150) NOT NULL,
    cpf             VARCHAR(14) NOT NULL UNIQUE,
    data_nascimento DATE NOT NULL,
    genero          VARCHAR(20),
    endereco        VARCHAR(255),
    telefone        VARCHAR(20),
    email           VARCHAR(150),
    tipo_plano      VARCHAR(50) NOT NULL,
    data_cadastro   DATE NOT NULL DEFAULT (CURRENT_DATE)
);

-- Tabela: medicos
CREATE TABLE medicos (
    id_medico               INT AUTO_INCREMENT PRIMARY KEY,
    nome_completo            VARCHAR(150) NOT NULL,
    crm                      VARCHAR(20) NOT NULL UNIQUE,
    telefone                 VARCHAR(20),
    email                    VARCHAR(150),
    data_contratacao         DATE,
    status_ativo             BOOLEAN DEFAULT TRUE,
    horario_disponibilidade  VARCHAR(255)
);

-- Tabela: especialidades
CREATE TABLE especialidades (
    id_especialidade      INT AUTO_INCREMENT PRIMARY KEY,
    nome_especialidade     VARCHAR(100) NOT NULL UNIQUE,
    descricao               VARCHAR(255),
    valor_base_consulta     DECIMAL(10,2) NOT NULL,
    duracao_media_minutos   INT,
    ativa                    BOOLEAN DEFAULT TRUE,
    data_criacao             DATE DEFAULT (CURRENT_DATE),
    observacoes              VARCHAR(255)
);

-- Tabela: medico_especialidade (associativa - resolve N:N)
CREATE TABLE medico_especialidade (
    id_medico        INT NOT NULL,
    id_especialidade INT NOT NULL,
    data_inicio      DATE,
    principal        BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (id_medico, id_especialidade),
    FOREIGN KEY (id_medico) REFERENCES medicos(id_medico)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_especialidade) REFERENCES especialidades(id_especialidade)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabela: consultas
CREATE TABLE consultas (
    id_consulta       INT AUTO_INCREMENT PRIMARY KEY,
    id_paciente       INT NOT NULL,
    id_medico         INT NOT NULL,
    id_especialidade  INT NOT NULL,
    data_consulta     DATE NOT NULL,
    hora_consulta     TIME NOT NULL,
    status            VARCHAR(20) NOT NULL DEFAULT 'agendada',
    valor_consulta    DECIMAL(10,2) NOT NULL,
    observacoes       VARCHAR(255),
    data_agendamento  DATE NOT NULL DEFAULT (CURRENT_DATE),
    FOREIGN KEY (id_paciente) REFERENCES pacientes(id_paciente)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_medico) REFERENCES medicos(id_medico)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_especialidade) REFERENCES especialidades(id_especialidade)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_status CHECK (status IN ('agendada','realizada','cancelada','faltou'))
);

-- Tabela: prontuarios
CREATE TABLE prontuarios (
    id_prontuario       INT AUTO_INCREMENT PRIMARY KEY,
    id_consulta         INT NOT NULL UNIQUE,
    data_registro       DATE NOT NULL,
    diagnostico         TEXT,
    anotacoes           TEXT,
    sintomas_relatados  TEXT,
    exames_solicitados  TEXT,
    observacoes         TEXT,
    FOREIGN KEY (id_consulta) REFERENCES consultas(id_consulta)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Tabela: prescricoes
CREATE TABLE prescricoes (
    id_prescricao       INT AUTO_INCREMENT PRIMARY KEY,
    id_prontuario       INT NOT NULL,
    medicamento         VARCHAR(150) NOT NULL,
    dosagem             VARCHAR(50),
    frequencia          VARCHAR(50),
    duracao_tratamento  VARCHAR(50),
    data_prescricao     DATE NOT NULL,
    observacoes         VARCHAR(255),
    FOREIGN KEY (id_prontuario) REFERENCES prontuarios(id_prontuario)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabela: pagamentos
CREATE TABLE pagamentos (
    id_pagamento       INT AUTO_INCREMENT PRIMARY KEY,
    id_consulta        INT NOT NULL UNIQUE,
    valor              DECIMAL(10,2) NOT NULL,
    data_pagamento     DATE,
    metodo_pagamento   VARCHAR(20),
    status_pagamento   VARCHAR(20) NOT NULL DEFAULT 'pendente',
    data_vencimento    DATE,
    numero_recibo      VARCHAR(50),
    FOREIGN KEY (id_consulta) REFERENCES consultas(id_consulta)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_status_pagamento CHECK (status_pagamento IN ('pendente','pago','cancelado')),
    CONSTRAINT chk_metodo_pagamento CHECK (metodo_pagamento IN ('dinheiro','cartao','pix'))
);

-- DML (Inserção de Dados)
-- Os IDs são gerados automaticamente (AUTO_INCREMENT)
-- Especialidades (12 registros):
INSERT INTO especialidades (nome_especialidade, descricao, valor_base_consulta, duracao_media_minutos, ativa, observacoes) VALUES
('Cardiologia', 'Diagnóstico e tratamento de doenças do coração', 250.00, 40, TRUE, 'Alta demanda'),
('Pediatria', 'Atendimento clínico de crianças e adolescentes', 180.00, 30, TRUE, NULL),
('Ortopedia', 'Tratamento de ossos, músculos e articulações', 220.00, 35, TRUE, NULL),
('Dermatologia', 'Diagnóstico e tratamento de doenças de pele', 200.00, 25, TRUE, NULL),
('Ginecologia', 'Saúde do sistema reprodutor feminino', 210.00, 35, TRUE, NULL),
('Clínica Geral', 'Atendimento clínico geral e check-ups', 150.00, 30, TRUE, 'Porta de entrada mais comum'),
('Neurologia', 'Diagnóstico e tratamento de doenças neurológicas', 280.00, 45, TRUE, NULL),
('Endocrinologia', 'Tratamento de distúrbios hormonais e metabólicos', 230.00, 35, TRUE, NULL),
('Psiquiatria', 'Saúde mental e transtornos psiquiátricos', 250.00, 50, TRUE, NULL),
('Oftalmologia', 'Diagnóstico e tratamento de doenças oculares', 190.00, 25, TRUE, NULL),
('Otorrinolaringologia', 'Tratamento de ouvido, nariz e garganta', 200.00, 30, TRUE, NULL),
('Urologia', 'Tratamento do sistema urinário e reprodutor masculino', 220.00, 35, TRUE, NULL);

-- Médicos (14 registros):
INSERT INTO medicos (nome_completo, crm, telefone, email, data_contratacao, status_ativo, horario_disponibilidade) VALUES
('Dr. Carlos Eduardo Silva', 'CRM/PB 10234', '(83) 99111-2233', 'carlos.silva@clinicacare.com', '2018-03-10', TRUE, 'Seg-Qui 08h-12h'),
('Dra. Fernanda Costa Lima', 'CRM/PB 10567', '(83) 99222-3344', 'fernanda.lima@clinicacare.com', '2019-06-15', TRUE, 'Seg-Sex 13h-17h'),
('Dr. Ricardo Alves Santos', 'CRM/PB 10890', '(83) 99333-4455', 'ricardo.santos@clinicacare.com', '2017-01-20', TRUE, 'Ter-Sex 08h-12h'),
('Dra. Juliana Pereira Souza', 'CRM/PB 11023', '(83) 99444-5566', 'juliana.souza@clinicacare.com', '2020-02-05', TRUE, 'Seg-Qua 14h-18h'),
('Dr. Marcelo Rodrigues Oliveira', 'CRM/PB 11345', '(83) 99555-6677', 'marcelo.oliveira@clinicacare.com', '2016-09-12', TRUE, 'Seg-Sex 08h-12h'),
('Dra. Patrícia Gomes Ferreira', 'CRM/PB 11678', '(83) 99666-7788', 'patricia.ferreira@clinicacare.com', '2021-04-18', TRUE, 'Qua-Sex 09h-13h'),
('Dr. André Luiz Barbosa', 'CRM/PB 11901', '(83) 99777-8899', 'andre.barbosa@clinicacare.com', '2015-11-30', TRUE, 'Seg-Qui 13h-17h'),
('Dra. Camila Rocha Nascimento', 'CRM/PB 12234', '(83) 99888-9900', 'camila.nascimento@clinicacare.com', '2019-08-22', TRUE, 'Ter-Qui 08h-12h'),
('Dr. Eduardo Martins Cavalcante', 'CRM/PB 12567', '(83) 99999-0011', 'eduardo.cavalcante@clinicacare.com', '2020-05-14', TRUE, 'Seg-Sex 07h-11h'),
('Dra. Beatriz Almeida Cardoso', 'CRM/PB 12890', '(83) 98111-1122', 'beatriz.cardoso@clinicacare.com', '2018-07-09', TRUE, 'Seg-Qua 08h-12h'),
('Dr. Rafael Nunes Teixeira', 'CRM/PB 13123', '(83) 98222-2233', 'rafael.teixeira@clinicacare.com', '2017-10-03', TRUE, 'Ter-Sex 14h-18h'),
('Dra. Larissa Dias Monteiro', 'CRM/PB 13456', '(83) 98333-3344', 'larissa.monteiro@clinicacare.com', '2022-01-11', TRUE, 'Seg-Sex 08h-12h'),
('Dr. Thiago Correia Ramos', 'CRM/PB 13789', '(83) 98444-4455', 'thiago.ramos@clinicacare.com', '2019-03-27', TRUE, 'Seg-Qua 13h-17h'),
('Dra. Vanessa Lima Araújo', 'CRM/PB 14012', '(83) 98555-5566', 'vanessa.araujo@clinicacare.com', '2021-09-06', TRUE, 'Qua-Sex 08h-12h');

-- Médico x Especialidade (18 registros):
INSERT INTO medico_especialidade (id_medico, id_especialidade, data_inicio, principal) VALUES
(1, 1, '2018-03-10', TRUE),
(2, 2, '2019-06-15', TRUE),
(3, 3, '2017-01-20', TRUE),
(4, 5, '2020-02-05', TRUE),
(5, 6, '2016-09-12', TRUE),
(5, 8, '2020-01-15', FALSE),
(6, 4, '2021-04-18', TRUE),
(7, 7, '2015-11-30', TRUE),
(8, 9, '2019-08-22', TRUE),
(9, 10, '2020-05-14', TRUE),
(10, 11, '2018-07-09', TRUE),
(11, 12, '2017-10-03', TRUE),
(12, 6, '2022-01-11', TRUE),
(12, 2, '2022-06-01', FALSE),
(13, 1, '2019-03-27', TRUE),
(13, 6, '2021-01-01', FALSE),
(14, 8, '2021-09-06', TRUE),
(14, 5, '2022-03-01', FALSE);

-- Pacientes (16 registros):
INSERT INTO pacientes (nome_completo, cpf, data_nascimento, genero, endereco, telefone, email, tipo_plano, data_cadastro) VALUES
('Ana Beatriz Souza Lima', '123.456.789-01', '1990-05-14', 'Feminino', 'Rua das Trincheiras, 120, Centro, João Pessoa - PB', '(83) 98111-0001', 'ana.lima@email.com', 'particular', '2023-01-15'),
('João Pedro Ferreira Costa', '234.567.890-12', '1985-11-22', 'Masculino', 'Av. Epitácio Pessoa, 450, Tambaú, João Pessoa - PB', '(83) 98111-0002', 'joao.costa@email.com', 'convenio_x', '2023-02-10'),
('Maria Clara Oliveira Santos', '345.678.901-23', '2001-03-08', 'Feminino', 'Rua Maciel Pinheiro, 78, Varadouro, João Pessoa - PB', '(83) 98111-0003', 'maria.santos@email.com', 'convenio_y', '2023-03-05'),
('Pedro Henrique Almeida Rocha', '456.789.012-34', '1978-07-30', 'Masculino', 'Rua Rodrigues de Aquino, 210, Centro, João Pessoa - PB', '(83) 98111-0004', 'pedro.rocha@email.com', 'particular', '2023-04-20'),
('Luiza Fernanda Cardoso Silva', '567.890.123-45', '1995-09-17', 'Feminino', 'Av. Beira Rio, 300, Bancários, João Pessoa - PB', '(83) 98111-0005', 'luiza.silva@email.com', 'convenio_x', '2023-05-12'),
('Gabriel Souza Martins', '678.901.234-56', '2010-01-25', 'Masculino', 'Rua João Suassuna, 55, Torre, João Pessoa - PB', '(83) 98111-0006', 'gabriel.martins@email.com', 'convenio_y', '2023-06-18'),
('Camila Rodrigues Nunes', '789.012.345-67', '1988-12-02', 'Feminino', 'Rua Cristóvão Colombo, 190, Jaguaribe, João Pessoa - PB', '(83) 98111-0007', 'camila.nunes@email.com', 'particular', '2023-07-22'),
('Lucas Gabriel Pereira Dias', '890.123.456-78', '1999-04-19', 'Masculino', 'Av. Cruz das Armas, 88, Cruz das Armas, João Pessoa - PB', '(83) 98111-0008', 'lucas.dias@email.com', 'convenio_x', '2023-08-30'),
('Isabela Cristina Gomes Barbosa', '901.234.567-89', '1972-06-11', 'Feminino', 'Rua Duque de Caxias, 33, Jaguaribe, João Pessoa - PB', '(83) 98111-0009', 'isabela.barbosa@email.com', 'convenio_y', '2023-09-14'),
('Rafael Augusto Teixeira Lima', '012.345.678-90', '2015-02-28', 'Masculino', 'Rua Maria Elizabeth, 145, Miramar, João Pessoa - PB', '(83) 98111-0010', 'rafael.lima@email.com', 'particular', '2023-10-05'),
('Beatriz Helena Monteiro Costa', '111.222.333-44', '1993-08-09', 'Feminino', 'Av. Argemiro de Figueiredo, 500, Mangabeira, João Pessoa - PB', '(83) 98111-0011', 'beatriz.costa@email.com', 'convenio_x', '2024-01-08'),
('Felipe Henrique Araújo Souza', '222.333.444-55', '1982-10-16', 'Masculino', 'Rua Padre Meira, 67, Torre, João Pessoa - PB', '(83) 98111-0012', 'felipe.souza@email.com', 'particular', '2024-02-19'),
('Larissa Maria Cavalcante Silva', '333.444.555-66', '2005-05-03', 'Feminino', 'Rua Manoel Inocêncio, 22, Bessa, João Pessoa - PB', '(83) 98111-0013', 'larissa.silva@email.com', 'convenio_y', '2024-03-27'),
('Thiago Rodrigo Nascimento Alves', '444.555.666-77', '1968-01-12', 'Masculino', 'Av. Ruy Carneiro, 700, Bessa, João Pessoa - PB', '(83) 98111-0014', 'thiago.alves@email.com', 'particular', '2024-05-02'),
('Vanessa Cristina Lima Ferreira', '555.666.777-88', '1991-11-27', 'Feminino', 'Rua José Rodrigues Rocha, 90, Manaíra, João Pessoa - PB', '(83) 98111-0015', 'vanessa.ferreira@email.com', 'convenio_x', '2024-06-11'),
('Carlos Eduardo Santos Rocha', '666.777.888-99', '1975-03-21', 'Masculino', 'Av. João Machado, 250, Centro, João Pessoa - PB', '(83) 98111-0016', 'carlos.rocha@email.com', 'convenio_y', '2024-07-25');

-- Consultas (20 registros):
INSERT INTO consultas (id_paciente, id_medico, id_especialidade, data_consulta, hora_consulta, status, valor_consulta, observacoes) VALUES
(1, 1, 1, '2026-02-10', '09:00:00', 'realizada', 250.00, 'Retorno em 3 meses'),
(2, 2, 2, '2026-02-11', '10:00:00', 'realizada', 180.00, NULL),
(3, 3, 3, '2026-02-12', '14:00:00', 'realizada', 220.00, NULL),
(4, 4, 5, '2026-02-13', '11:00:00', 'realizada', 210.00, 'Exame preventivo anual'),
(5, 5, 6, '2026-02-14', '08:30:00', 'realizada', 150.00, NULL),
(6, 6, 4, '2026-02-17', '15:00:00', 'realizada', 200.00, NULL),
(7, 7, 7, '2026-02-18', '09:30:00', 'realizada', 280.00, 'Encaminhado para exame de imagem'),
(8, 8, 9, '2026-02-19', '13:00:00', 'realizada', 250.00, NULL),
(9, 9, 10, '2026-02-20', '10:30:00', 'realizada', 190.00, NULL),
(10, 10, 11, '2026-02-21', '14:30:00', 'realizada', 200.00, NULL),
(11, 11, 12, '2026-02-24', '09:00:00', 'realizada', 220.00, NULL),
(12, 12, 6, '2026-02-25', '11:30:00', 'realizada', 150.00, NULL),
(13, 13, 1, '2026-02-26', '16:00:00', 'realizada', 250.00, 'Paciente estável'),
(14, 14, 8, '2026-03-03', '10:00:00', 'agendada', 230.00, NULL),
(15, 1, 1, '2026-03-04', '09:00:00', 'agendada', 250.00, NULL),
(16, 2, 2, '2026-03-05', '10:30:00', 'agendada', 180.00, NULL),
(1, 5, 6, '2026-03-06', '08:00:00', 'agendada', 150.00, NULL),
(2, 3, 3, '2026-02-10', '09:00:00', 'cancelada', 220.00, 'Paciente remarcou'),
(3, 6, 4, '2026-02-13', '15:30:00', 'cancelada', 200.00, 'Cancelado pela clínica'),
(4, 7, 7, '2026-02-17', '09:30:00', 'faltou', 280.00, 'Paciente não compareceu');

-- Prontuários (13 registros - apenas consultas realizadas):
INSERT INTO prontuarios (id_consulta, data_registro, diagnostico, anotacoes, sintomas_relatados, exames_solicitados, observacoes) VALUES
(1, '2026-02-10', 'Hipertensão arterial leve', 'Paciente relata episódios de palpitação, pressão arterial 140/90 mmHg', 'Palpitações, cansaço leve', 'Eletrocardiograma, exame de sangue completo', NULL),
(2, '2026-02-11', 'Infecção viral das vias aéreas superiores', 'Febre baixa há 2 dias, sem outros sintomas graves', 'Febre, tosse leve', 'Nenhum, apenas observação', NULL),
(3, '2026-02-12', 'Tendinite no ombro direito', 'Dor ao levantar o braço, sem histórico de trauma recente', 'Dor no ombro, limitação de movimento', 'Ressonância magnética do ombro', NULL),
(4, '2026-02-13', 'Consulta de rotina, sem alterações', 'Exame preventivo dentro da normalidade', 'Nenhum', 'Papanicolau', NULL),
(5, '2026-02-14', 'Check-up geral, resultados normais', 'Paciente sem queixas relevantes', 'Nenhum', 'Hemograma completo', NULL),
(6, '2026-02-17', 'Dermatite atópica leve', 'Lesões de pele nos braços, coceira moderada', 'Coceira, vermelhidão', 'Nenhum', NULL),
(7, '2026-02-18', 'Enxaqueca crônica', 'Paciente relata dores de cabeça frequentes há 3 meses', 'Dor de cabeça, sensibilidade à luz', 'Ressonância magnética do crânio', NULL),
(8, '2026-02-19', 'Transtorno de ansiedade generalizada', 'Paciente relata insônia e preocupação excessiva', 'Ansiedade, insônia', 'Nenhum', NULL),
(9, '2026-02-20', 'Miopia leve', 'Necessário ajuste de grau dos óculos', 'Visão embaçada à distância', 'Exame de refração', NULL),
(10, '2026-02-21', 'Sinusite aguda', 'Congestão nasal e dor facial há 5 dias', 'Congestão nasal, dor facial', 'Tomografia dos seios da face', NULL),
(11, '2026-02-24', 'Infecção urinária', 'Paciente relata ardor ao urinar', 'Ardor urinário, frequência aumentada', 'Exame de urina', NULL),
(12, '2026-02-25', 'Gripe comum', 'Sintomas leves, sem necessidade de afastamento', 'Febre baixa, coriza', 'Nenhum', NULL),
(13, '2026-02-26', 'Arritmia leve', 'Acompanhamento de rotina, sem alterações graves no exame', 'Palpitações ocasionais', 'Holter 24h', NULL);

-- Prescrições (18 registros):
INSERT INTO prescricoes (id_prontuario, medicamento, dosagem, frequencia, duracao_tratamento, data_prescricao, observacoes) VALUES
(1, 'Losartana', '50mg', '1x ao dia', '30 dias', '2026-02-10', NULL),
(1, 'Ácido acetilsalicílico', '100mg', '1x ao dia', '90 dias', '2026-02-10', 'Uso contínuo, reavaliar em retorno'),
(2, 'Paracetamol', '200mg/ml', '3x ao dia', '5 dias', '2026-02-11', NULL),
(3, 'Ibuprofeno', '400mg', '2x ao dia', '7 dias', '2026-02-12', NULL),
(3, 'Dexametasona (pomada)', 'Aplicação local', '2x ao dia', '10 dias', '2026-02-12', NULL),
(4, 'Ácido fólico', '5mg', '1x ao dia', '30 dias', '2026-02-13', NULL),
(5, 'Complexo vitamínico', '1 cápsula', '1x ao dia', '30 dias', '2026-02-14', NULL),
(6, 'Hidrocortisona (creme)', 'Aplicação local', '2x ao dia', '14 dias', '2026-02-17', NULL),
(6, 'Loratadina', '10mg', '1x ao dia', '10 dias', '2026-02-17', NULL),
(7, 'Sumatriptano', '50mg', 'Conforme necessário', '30 dias', '2026-02-18', 'Máximo 2 doses por semana'),
(8, 'Sertralina', '50mg', '1x ao dia', '60 dias', '2026-02-19', NULL),
(8, 'Clonazepam', '0,5mg', '1x ao dia (noite)', '30 dias', '2026-02-19', NULL),
(9, 'Colírio lubrificante', '1 gota em cada olho', '3x ao dia', '15 dias', '2026-02-20', NULL),
(10, 'Amoxicilina', '500mg', '3x ao dia', '7 dias', '2026-02-21', NULL),
(11, 'Ciprofloxacino', '500mg', '2x ao dia', '7 dias', '2026-02-24', NULL),
(11, 'Fenazopiridina', '100mg', '3x ao dia', '3 dias', '2026-02-24', NULL),
(12, 'Dipirona', '500mg', 'Conforme necessário', '5 dias', '2026-02-25', NULL),
(13, 'Metoprolol', '25mg', '1x ao dia', '30 dias', '2026-02-26', 'Uso contínuo');

-- Pagamentos (20 registros - um por consulta):
INSERT INTO pagamentos (id_consulta, valor, data_pagamento, metodo_pagamento, status_pagamento, data_vencimento, numero_recibo) VALUES
(1, 250.00, '2026-02-10', 'pix', 'pago', '2026-02-10', 'REC-2026-0001'),
(2, 180.00, '2026-02-11', 'cartao', 'pago', '2026-02-11', 'REC-2026-0002'),
(3, 220.00, '2026-02-12', 'dinheiro', 'pago', '2026-02-12', 'REC-2026-0003'),
(4, 210.00, '2026-02-13', 'cartao', 'pago', '2026-02-13', 'REC-2026-0004'),
(5, 150.00, '2026-02-14', 'pix', 'pago', '2026-02-14', 'REC-2026-0005'),
(6, 200.00, '2026-02-18', 'cartao', 'pago', '2026-02-17', 'REC-2026-0006'),
(7, 280.00, '2026-02-18', 'pix', 'pago', '2026-02-18', 'REC-2026-0007'),
(8, 250.00, '2026-02-19', 'dinheiro', 'pago', '2026-02-19', 'REC-2026-0008'),
(9, 190.00, '2026-02-20', 'cartao', 'pago', '2026-02-20', 'REC-2026-0009'),
(10, 200.00, '2026-02-22', 'pix', 'pago', '2026-02-21', 'REC-2026-0010'),
(11, 220.00, '2026-02-24', 'cartao', 'pago', '2026-02-24', 'REC-2026-0011'),
(12, 150.00, '2026-02-25', 'dinheiro', 'pago', '2026-02-25', 'REC-2026-0012'),
(13, 250.00, '2026-02-26', 'pix', 'pago', '2026-02-26', 'REC-2026-0013'),
(14, 230.00, NULL, NULL, 'pendente', '2026-03-03', NULL),
(15, 250.00, NULL, NULL, 'pendente', '2026-03-04', NULL),
(16, 180.00, NULL, NULL, 'pendente', '2026-03-05', NULL),
(17, 150.00, NULL, NULL, 'pendente', '2026-03-06', NULL),
(18, 220.00, NULL, NULL, 'cancelado', '2026-02-10', NULL),
(19, 200.00, NULL, NULL, 'cancelado', '2026-02-13', NULL),
(20, 280.00, NULL, NULL, 'cancelado', '2026-02-17', NULL);

-- UPDATE Solicitados
-- 1. Consulta que estava agendada foi cancelada a pedido do paciente:
UPDATE consultas
SET status = 'cancelada', observacoes = 'Paciente solicitou cancelamento'
WHERE id_consulta = 16;

-- 2. Pagamento pendente foi quitado:
UPDATE pagamentos
SET status_pagamento = 'pago', data_pagamento = '2026-03-01', metodo_pagamento = 'pix', numero_recibo = 'REC-2026-0014'
WHERE id_consulta = 14;

-- 3. Reajuste no valor base da especialidade de Cardiologia:
UPDATE especialidades
SET valor_base_consulta = 260.00
WHERE nome_especialidade = 'Cardiologia';

-- 4. Médico encerrou vínculo com a clínica:
UPDATE medicos
SET status_ativo = FALSE
WHERE id_medico = 7;

-- DQL (Consultas de Agregação e JOINs)
-- Valor médio de consulta por especialidade (AVG):
SELECT
    e.nome_especialidade,
    ROUND(AVG(c.valor_consulta), 2) AS valor_medio_consulta,
    COUNT(c.id_consulta) AS total_consultas
FROM consultas c
JOIN especialidades e ON e.id_especialidade = c.id_especialidade
GROUP BY e.nome_especialidade
ORDER BY valor_medio_consulta DESC;

-- Faturamento total (pagamentos pagos) por médico (SUM):
SELECT
    m.nome_completo AS medico,
    SUM(p.valor) AS faturamento_total
FROM pagamentos p
JOIN consultas c ON c.id_consulta = p.id_consulta
JOIN medicos m ON m.id_medico = c.id_medico
WHERE p.status_pagamento = 'pago'
GROUP BY m.nome_completo
ORDER BY faturamento_total DESC;

-- Quantidade de pacientes por tipo de plano (COUNT):
SELECT
    tipo_plano,
    COUNT(*) AS quantidade_pacientes
FROM pacientes
GROUP BY tipo_plano
ORDER BY quantidade_pacientes DESC;

-- Valor máximo e mínimo de consulta por especialidade (MAX / MIN):
SELECT
    e.nome_especialidade,
    MAX(c.valor_consulta) AS valor_maximo,
    MIN(c.valor_consulta) AS valor_minimo
FROM consultas c
JOIN especialidades e ON e.id_especialidade = c.id_especialidade
GROUP BY e.nome_especialidade
ORDER BY valor_maximo DESC;

-- Distribuição de consultas por status  (COUNT + agrupamento por status):
SELECT
    status,
    COUNT(*) AS quantidade,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM consultas), 1) AS percentual
FROM consultas
GROUP BY status
ORDER BY quantidade DESC;

-- Consultas completas com paciente, médico e especialidade (INNER JOIN):
SELECT
    c.id_consulta,
    pac.nome_completo AS paciente,
    med.nome_completo AS medico,
    e.nome_especialidade AS especialidade,
    c.data_consulta,
    c.status,
    c.valor_consulta
FROM consultas c
INNER JOIN pacientes pac ON pac.id_paciente = c.id_paciente
INNER JOIN medicos med ON med.id_medico = c.id_medico
INNER JOIN especialidades e ON e.id_especialidade = c.id_especialidade
ORDER BY c.data_consulta, c.hora_consulta;

-- Todas as consultas e, quando existir, o diagnóstico do prontuário (LEFT JOIN):
-- (consultas que NÃO foram realizadas aparecem com prontuário em branco/NULL)
SELECT
    c.id_consulta,
    c.data_consulta,
    c.status,
    pr.diagnostico
FROM consultas c
LEFT JOIN prontuarios pr ON pr.id_consulta = c.id_consulta
ORDER BY c.data_consulta;

-- Pacientes e suas consultas (partindo da tabela consultas como base à direita) (RIGHT JOIN):
SELECT
    pac.nome_completo AS paciente,
    c.id_consulta,
    c.data_consulta,
    c.status
FROM consultas c
RIGHT JOIN pacientes pac ON pac.id_paciente = c.id_paciente
ORDER BY pac.nome_completo;

-- Quantidade de medicamentos prescritos por prontuário (INNER JOIN + agregação):
SELECT
    pr.id_prontuario,
    pr.diagnostico,
    COUNT(pres.id_prescricao) AS qtd_medicamentos_prescritos
FROM prontuarios pr
INNER JOIN prescricoes pres ON pres.id_prontuario = pr.id_prontuario
GROUP BY pr.id_prontuario, pr.diagnostico
ORDER BY qtd_medicamentos_prescritos DESC;

-- EXERCÍCIO PRÁTICO

-- Exercício 1 - Subquery 

-- a) Registro com maior valor de consulta (subquery no WHERE)
SELECT id_consulta, id_paciente, id_medico, id_especialidade, valor_consulta
FROM consultas
WHERE valor_consulta = (SELECT MAX(valor_consulta) FROM consultas);

-- b) Pacientes que consultaram em especialidades acima do valor médio (subquery com IN)
SELECT nome_completo, tipo_plano
FROM pacientes
WHERE id_paciente IN (
    SELECT c.id_paciente
    FROM consultas c
    WHERE c.id_especialidade IN (
        SELECT id_especialidade
        FROM especialidades
        WHERE valor_base_consulta > (SELECT AVG(valor_base_consulta) FROM especialidades)
    )
);

-- Exercício 2 - CASE WHEN 

-- a) Categorizar consultas por faixa de valor
SELECT
    id_consulta,
    valor_consulta,
    CASE
        WHEN valor_consulta < 180 THEN 'Baixo'
        WHEN valor_consulta BETWEEN 180 AND 230 THEN 'Médio'
        ELSE 'Alto'
    END AS faixa_valor
FROM consultas
ORDER BY valor_consulta;

-- b) Contar quantos registros caem em cada faixa
SELECT
    COUNT(CASE WHEN valor_consulta < 180 THEN 1 END) AS qtd_baixo,
    COUNT(CASE WHEN valor_consulta BETWEEN 180 AND 230 THEN 1 END) AS qtd_medio,
    COUNT(CASE WHEN valor_consulta > 230 THEN 1 END) AS qtd_alto
FROM consultas;

-- Exercício 3 - Funções de Janela

-- a) ROW_NUMBER() com PARTITION BY especialidade
SELECT
    c.id_consulta,
    e.nome_especialidade,
    c.data_consulta,
    c.valor_consulta,
    ROW_NUMBER() OVER (
        PARTITION BY c.id_especialidade
        ORDER BY c.data_consulta
    ) AS numero_consulta_na_especialidade
FROM consultas c
JOIN especialidades e ON e.id_especialidade = c.id_especialidade
ORDER BY e.nome_especialidade, numero_consulta_na_especialidade;

-- b) RANK() dos médicos por faturamento dentro de cada especialidade
SELECT
    e.nome_especialidade,
    med.nome_completo AS medico,
    SUM(p.valor) AS faturamento,
    RANK() OVER (
        PARTITION BY e.id_especialidade
        ORDER BY SUM(p.valor) DESC
    ) AS ranking_na_especialidade
FROM pagamentos p
JOIN consultas c ON c.id_consulta = p.id_consulta
JOIN medicos med ON med.id_medico = c.id_medico
JOIN especialidades e ON e.id_especialidade = c.id_especialidade
WHERE p.status_pagamento = 'pago'
GROUP BY e.nome_especialidade, e.id_especialidade, med.nome_completo
ORDER BY e.nome_especialidade, ranking_na_especialidade;

-- DESAFIO AVANÇADO
-- Especialidades mais lucrativas por mês + tendência:

WITH faturamento_mensal AS (
    -- (1) CTE: agrega o faturamento por especialidade e por mês
    SELECT
        e.nome_especialidade,
        DATE_FORMAT(c.data_consulta, '%Y-%m') AS mes_referencia,
        SUM(c.valor_consulta) AS faturamento_mes
    FROM consultas c
    JOIN especialidades e ON e.id_especialidade = c.id_especialidade
    WHERE c.status = 'realizada'
    GROUP BY e.nome_especialidade, DATE_FORMAT(c.data_consulta, '%Y-%m')
),
faturamento_com_janela AS (
    -- (2) Segunda CTE: aplica as funções de janela sobre o resultado da primeira
    SELECT
        nome_especialidade,
        mes_referencia,
        faturamento_mes,
        RANK() OVER (
            PARTITION BY mes_referencia
            ORDER BY faturamento_mes DESC
        ) AS ranking_no_mes,
        LAG(faturamento_mes) OVER (
            PARTITION BY nome_especialidade
            ORDER BY mes_referencia
        ) AS faturamento_mes_anterior
    FROM faturamento_mensal
)
-- (3) SELECT final: usa CASE WHEN para classificar a tendência
SELECT
    nome_especialidade,
    mes_referencia,
    faturamento_mes,
    ranking_no_mes,
    faturamento_mes_anterior,
    CASE
        WHEN faturamento_mes_anterior IS NULL THEN 'Primeiro mês com dados'
        WHEN faturamento_mes > faturamento_mes_anterior THEN 'Crescendo'
        WHEN faturamento_mes < faturamento_mes_anterior THEN 'Caindo'
        ELSE 'Estável'
    END AS tendencia
FROM faturamento_com_janela
ORDER BY mes_referencia, ranking_no_mes;

-- (4) Sugestão de índice para otimizar essa consulta:
CREATE INDEX idx_consultas_status_esp_data
ON consultas (status, id_especialidade, data_consulta);