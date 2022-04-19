create database MePoupe;
use MePoupe;

create table cliente(
cod_cliente int auto_increment,
nome varchar(50),
CPF char(11),
sexo char(1),
dt_nasc date,
telefone char(15),
email varchar(100),
primary key(cod_cliente));

insert into cliente values(1,'Bill Clinton','12999786543','M','1940-04-12', '11999786543', 'william@gmail.com'),
 (2,'Trump', '13999786544', 'M','1942-05-10', '11999186543', 'trump@gmail.com');
 
create table conta_corrente(
cod_conta int auto_increment,
dt_hora_abertura date,
saldo numeric(9,2),
Status varchar(15),
cod_cliente int,
primary key(cod_conta),
foreign key(cod_cliente)references cliente(cod_cliente));

insert into conta_corrente values (1,current_date(),50,'Ativa',1);
insert into conta_corrente values (2,current_date(),500,'Ativa',2);

create table Registro_Saque(
cod_saque int auto_increment,
cod_conta int,
dt_saque date,
valor_saque numeric(9,2),
primary key(cod_saque),
foreign key(cod_conta)references conta_corrente(cod_conta));

 create table Registro_Deposito(
cod_deposito int auto_increment,
cod_conta int,
dt_deposito date,
valor_deposito numeric(9,2),
primary key(cod_deposito),
foreign key(cod_conta)references conta_corrente(cod_conta));

insert into registro_saque values(1,2,current_date(), 20);
insert into registro_saque values(2,2,current_date(), 8);
insert into registro_saque values(3,2,'2018-10-08', 20);
insert into registro_saque values(4,2,'2018-10-07', 8);

insert into registro_deposito values(1,2,current_date(), 40);
insert into registro_deposito values(2,2,current_date(), 80);

/*------------------------------------------------------------------------------------*/

/* Resolução das Atividades */

--  1)
DELIMITER $
CREATE PROCEDURE sp_insere_cli (var_nome varchar(50), var_cpf char(11), var_sexo char(1),
	var_dt_nasc date, var_telefone char(15), var_email varchar(100))
BEGIN
	if(var_nome is null) then
		select "O campo nome é de preenchimento obrigatório" as msg;
	else if (var_cpf is null) then
		select "O campo CPF é de preenchimento obrigatório" as msg;
	else if (var_sexo is null) then
		select "O campo sexo é de preenchimento obrigatório" as msg;
	else if (var_dt_nasc is null) then
		select "O campo data de nascimento é de preenchimento obrigatório" as msg;
	else if (var_telefone is null) then
		select "O campo telefone é de preenchimento obrigatório" as msg;
	else if (var_email is null) then
		select "O campo email é de preenchimento obrigatório" as msg; 
	else
		insert into cliente(nome, CPF, sexo, dt_nasc, telefone, email) values (var_nome, var_cpf, var_sexo, var_telefone, var_dt_nasc, var_email);
END IF;
END IF;
END IF;
END IF;
END IF;
END IF;
END
$
Delimiter ;

call sp_insere_cli('Ana Silva','12345678888','M', '1990-09-12', 11999786555,'anasilv@gmail.com');
select * from cliente; 


-- 2)
create table registro_transferencia(
	cod_conta_origem int primary key auto_increment,
    cod_conta_destino int,
    valor_transferencia numeric(9,2),
    dt_transferencia date,
    hr_transferencia date
);

DELIMITER $
CREATE PROCEDURE sp_realiza_transferencia(
	cod_conta_origem int, cod_conta_destino int, valor_transferencia numeric(9,2))
BEGIN
	if((select saldo from conta_corrente where cod_conta=cod_conta_origem)>0 AND (select saldo from conta_corrente where cod_conta=cod_conta_origem)<valor_transferencia) then
		select "Saldo insuficiente!" as msg;
	else 
		update conta_corrente set saldo = saldo - valor_transferencia where cod_conta = cod_conta_origem;
		update conta_corrente set saldo = saldo + valor_transferencia where cod_conta = cod_conta_destino;
	insert into registro_transferencia(cod_conta_origem, cod_conta_destino, valor_transferencia, dt_transferencia, hr_transferencia)
    values(cod_conta_origem, cod_conta_destino, valor_transferencia, current_date(), current_time());
	END IF;
END
$
Delimiter ;

call sp_realiza_transferencia(1, 2, 50);
call sp_realiza_transferencia(2, 1, 100);

select * from registro_transferencia;
select * from conta_corrente;


-- 3)
DELIMITER $
CREATE PROCEDURE sp_total_depositos (
	conta int, mes char(2), ano char(4))
BEGIN
	if(mes < 1 || mes > 12 || mes is null) then
		select "Mês inválido!" as msg;
	else
	 select cod_conta as conta, sum(valor_deposito) as total_depositos, dt_deposito as data 
     from Registro_Deposito where cod_conta = conta
     AND month(dt_deposito) = mes AND year(dt_deposito) = ano 
     group by mes;
    END IF;
END
$
Delimiter ;

call sp_total_depositos(2, 4, 2022);


-- 4)
DELIMITER $
CREATE PROCEDURE sp_relatorio_anual_contas (ano char(4))
BEGIN
    select c.cod_conta as conta, sum(d.valor_deposito) as total_depositos, sum(s.valor_saque) as total_saque
	from conta_corrente c
	inner join Registro_Deposito d on c.cod_conta = d.cod_conta
	inner join Registro_Saque s on c.cod_conta = s.cod_conta
	where year(d.dt_deposito) = ano
    or year(s.valor_saque) = ano
	group by c.cod_conta;
END
$
Delimiter ;

call sp_relatorio_anual_contas(2022);

