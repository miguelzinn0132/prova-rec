create table investidores(
id serial primary key,
nome varchar not null,
cpf varchar(11) unique not null,
nivel_experiencia int check (nivel_experiencia >= 0)
);

create table carteiras(
id serial primary key,
investidor_id int,
constraint fk_investidor
foreign key (investidor_id)
references investidores(id),
endereco_wallet varchar unique not null,
rede_blockchain varchar not null,
saldo_usd decimal check (saldo_usd >= 0) not null,
status varchar default 'Ativa' check (status in ('Ativa', 'Em Analize', 'Bloqueada', 'Pausada'))
);

create table corretoras(
id serial primary key,
nome_exchange varchar not null,
cnpj varchar(14) unique not null,
email_suporte varchar unique not null
);

create table criptomoedas(
id serial primary key,
corretora_id int,
constraint fk_corretora
foreign key (corretora_id)
references corretoras(id),
nome_moeda varchar not null,
preco_unitario_usd decimal check (preco_unitario_usd >= 0) not null,
categoria varchar default 'Layer1' check (categoria in ('Layer1', 'DeFi', 'Memecoin', 'Stablecoin'))
);

create table transacoes_cripto(
id serial primary key,
carteira_id int,
constraint fk_carteira
foreign key (carteira_id)
references carteiras(id),
criptomoeda_id int,
constraint fk_criptomoeda
foreign key (criptomoeda_id)
references criptomoedas(id),
quantidade decimal check (quantidade >= 0) not null,
valor_pago decimal check (valor_pago >= 0) not null,
data_transacao timestamp default current_timestamp
);

insert into investidores(nome, cpf, nivel_experiencia) values 
 ('miguel', '12345678901', 999),
 ('samuel', '12345687901', 67),
 ('vargas', '12345678967', 666),
 ('wolfao', '12675678901', 420),
 ('tina', '12675678001', 33);

insert into carteiras(investidor_id, endereco_wallet, rede_blockchain, saldo_usd, status) values 
 (1, '0x999', 'resenhacoin', '2346356', 'Ativa'),
 (2, '0x067', 'wokecoin', '784321', 'Pausada'),
 (3, '0x666', 'edgycoin', '56723', 'Em Analize'),
 (4, '0x420', 'presscoin', '931324', 'Bloqueada'),
 (5, '0x333', 'podicoin', '234097', 'Ativa');

insert into corretoras(nome_exchange, cnpj, email_suporte) values 
 ('corretora-aura', 'udtqcssondodtq', 'aura@email.com'),
 ('corretora-laura', 'udtqcssondo67q', 'laura@email.com'),
 ('corretora-resenha', 'udt69ssondo67q', 'resenha@email.com'),
 ('corretora-farm', 'udtqcsso42o67q', 'farma@email.com'),
 ('corretora-nick', 'u22qcsso42o67q', 'nick@email.com');

 insert into criptomoedas(corretora_id, nome_moeda, preco_unitario_usd, categoria) values 
 (1, 'resenhacoin', 67, 'Memecoin'),
 (2, 'wokecoin', 1, 'DeFi'),
 (3, 'edgycoin', 666, 'Layer1'),
 (4, 'presscoin', 420, 'Stablecoin'),
 (5, 'podicoin', 33, 'Layer1');

  insert into transacoes_cripto(carteira_id, criptomoeda_id, quantidade, valor_pago) values 
  (1, 1, 1, 67),
  (2, 2, 1, 1),
  (3, 3, 1, 666),
  (4, 4, 1, 420),
  (5, 5, 1, 33);

 select 
 c.endereco_wallet, 
 c.rede_blockchain, 
 c.saldo_usd, 
 i.nome as nome_investidor, 
 i.cpf
 from carteiras c
 join investidores i on c.investidor_id = i.id
 where c.status in ('Ativa', 'Em Analise');

 select 
 co.nome_exchange, 
 sum(t.valor_pago) as total_movimentado
 from corretoras co
 join criptomoedas cr on co.id = cr.corretora_id
 join transacoes_cripto t on cr.id = t.criptomoeda_id
 group by co.id, co.nome_exchange;

 select 
 ca.endereco_wallet, 
 cr.nome_moeda, 
 t.quantidade, 
 t.valor_pago, 
 t.data_transacao
 from transacoes_cripto t
 join carteiras ca on t.carteira_id = ca.id
 join criptomoedas cr on t.criptomoeda_id = cr.id
 where t.valor_pago > 500.00
 order by t.valor_pago desc;

 create view vw_painel_carteiras as
 select 
 c.endereco_wallet, 
 c.rede_blockchain, 
 c.status, 
 c.saldo_usd, 
 i.nome as nome_investidor, 
 i.cpf
 from carteiras c
 join investidores i on c.investidor_id = i.id;

 create view vw_investimento_total_carteiras as
 select 
 c.id as carteira_id,
 c.endereco_wallet,
 c.saldo_usd,
 coalesce(sum(t.quantidade), 0) as quantidade_total_transacoes,
 coalesce(sum(t.valor_pago), 0) as valor_total_pago
 from carteiras c
 left join transacoes_cripto t on c.id = t.carteira_id
 group by c.id, c.endereco_wallet, c.saldo_usd;