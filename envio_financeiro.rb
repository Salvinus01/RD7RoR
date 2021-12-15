require 'mysql2'

mysql = Mysql2::Client.new(:host => "Fomalhaut", :username => "root", :password => "P@ssw0rd", :database => "rd7")
#mysql.connect('localhost')

results = mysql.query("select d.id,
	d.periodo_id,
	d.usuario_id,
	u.login_7Control,
	d.tipo_lancamento_id,
	tl.dsc_tipo_lancamento,
	d.tipo_despesa_id,
	td.dsc_tipo_despesa,
	d.forma_pagamento_id,
	fp.dsc_forma_pagamento,
	d.centro_custo_id,
	cc.dsc_centro_custo,
	(date(d.dt_documento)) as dt_documento,
	d.nro_documento,
	format(d.vlr_documento, 2) as vlr_documento,
	d.nro_quantidade,
	format(d.vlr_despesa, 2) as vlr_despesa,
	d.dsc_despesa,
	d.status_lancamento_id,
	sl.dsc_status_lancamento,
	d.created_at,
	d.updated_at,
	d.dsc_motivo
from
	Despesas d, Usuarios u, Tipo_lancamentos tl, Tipo_despesas td, Forma_pagamentos fp, Centro_custos cc, Status_lancamentos sl
where
	d.usuario_id = u.id and
	d.tipo_lancamento_id = tl.id and
	d.tipo_despesa_id = td.id and
	d.forma_pagamento_id = fp.id and
	d.centro_custo_id = cc.id and
	d.status_lancamento_id = sl.id and
	d.periodo_id = (select id from periodos where date(dt_envio_financeiro) = date(now())) and
	d.status_lancamento_id = 2 and
	d.dt_envio_financeiro is null")

if results.count > 0 
	arquivo = File.open("envios_financeiro/envio-financeiro#{Time.now.strftime("%Y-%m-%d-%H%M%S")}.txt", "a")
	linha = ""
	for r in results
		for k in results.first.keys do
			linha += r[k].to_s + "|"
		end
		mysql.query("UPDATE `despesas` SET `dt_envio_financeiro`='#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}' WHERE id=#{r["id"]}")
		arquivo.puts linha
		linha = ""
	end
	arquivo.close
	mysql.query("UPDATE `despesas` SET `status_lancamento_id`='5' WHERE status_lancamento_id = '1' and periodo_id = (select id from periodos where date(dt_envio_financeiro) = date(now()))")
	mysql.query("UPDATE `despesas` SET `status_lancamento_id`='6' WHERE status_lancamento_id = '4' and periodo_id = (select id from periodos where date(dt_envio_financeiro) = date(now()))")
	mysql.close()
else
	puts "Nao ha envio hoje"
end