class DespesasController < ApplicationController
require "will_paginate/array"
require 'net/http'
	
	def self.seven_spec
		{:telas => {[:new, :create] => 6, [:edit, :update] => 12}}
	end
	
	def index
		
		
		@nav_bar = "Lançamento > Consultar"
		carrega_lancamentos
		if params[:periodo].nil?
			if @periodo.count == 0
				params[:periodo] = Periodo.last.id
			else
				params[:periodo] = @periodo.first.id
			end
		end
		
		case params[:commit]
			when "Enviar para Aprovação" then
				enviar_aprovacao
			when "Excluir" then
				excluir
		end
		
		@dados_periodo = Periodo.find_by_sql(" select *, datediff(dt_fim_lancamento, now()) as dias_faltam from periodos where id = #{params[:periodo]}")
		if @dados_periodo.first.dt_inicio_lancamento <= Time.now.to_date and @dados_periodo.first.dt_fim_lancamento >= Time.now.to_date
			@status_periodo = "Aberto"
		elsif @dados_periodo.first.dt_fim_lancamento < Time.now.to_date and @dados_periodo.first.dt_aprovacao >= Time.now.to_date
			@status_periodo = "Em Aprovação"
		elsif @dados_periodo.first.dt_aprovacao < Time.now.to_date and @dados_periodo.first.dt_envio_financeiro > Time.now.to_date
			@status_periodo = "Aprovado"
		else
			@status_periodo = "Fechado"
		end
		@lancamentos = Despesa.carrega_lancamentos
		# if @acesso != "RD7WEB003"
			@lancamentos = @lancamentos.where("periodo_id = #{params[:periodo]} and usuario_id = #{@usuario_logado.id}")
		# else
			# @lancamentos = @lancamentos.where("periodo_id = #{params[:periodo]}")
		# end
		# if @acesso != "RD7WEB003"
			@despesas = Despesa.find_by_sql("select t.dsc_tipo_despesa, format(sum(d.vlr_despesa), 2) as valores
									from despesas d, tipo_despesas t
									where 
									d.tipo_despesa_id = t.id and
									periodo_id = #{@periodo.first.id} and
									d.usuario_id = #{@usuario_logado.id}
									group by tipo_despesa_id")
			@valor_total = Despesa.find_by_sql("select ifnull(sum(vlr_despesa), 0) as total from despesas where periodo_id = #{params[:periodo]} and status_lancamento_id = 2 and usuario_id = #{@usuario_logado.id}")
		# else
			# @despesas = Despesa.find_by_sql("select t.dsc_tipo_despesa, count(d.tipo_despesa_id) as valores
									# from despesas d, tipo_despesas t
									# where 
									# d.tipo_despesa_id = t.id and
									# periodo_id = #{params[:periodo]}
									# group by tipo_despesa_id")
			# @valor_total = Despesa.find_by_sql("select ifnull(sum(vlr_despesa), 0) as total from despesas where periodo_id = #{params[:periodo]} and status_lancamento_id = 2")
		# end
		@valores = []
		@legenda = []
		for d in @despesas do
			@valores << d.valores
			@legenda << [d.valores, d.dsc_tipo_despesa.to_s]
		end
		if params[:tipo_lancamento] != "0" and !params[:tipo_lancamento].nil?
			@lancamentos = @lancamentos.where("tipo_lancamento_id = ?", params[:tipo_lancamento])
		end
		
		if params[:tipo_despesa] != "0" and !params[:tipo_despesa].nil?
			@lancamentos = @lancamentos.where("tipo_despesa_id = ?", params[:tipo_despesa])
		end
		
		if params[:status] != "0" and !params[:status].nil?
			@lancamentos = @lancamentos.where("status_lancamento_id = ?", params[:status])
		end
		
		if params[:centro_custo] != "0" and !params[:centro_custo].nil?
			@lancamentos = @lancamentos.where("centro_custo_id = ?", params[:centro_custo])
		end
		
		if params[:forma_pagamento] != "0" and !params[:forma_pagamento].nil?
			@lancamentos = @lancamentos.where("forma_pagamento_id = ?", params[:forma_pagamento])
		end
		
		if !params[:de].nil? and params[:de] != "" and !params[:ate].nil? and params[:ate] != ""
			@lancamentos = @lancamentos.where("Despesas.created_at >= ? and Despesas.created_at <= ?", params[:de].to_date, params[:ate].to_date)
		end
		
		if params[:nro_documento] != "" and !params[:nro_documento].nil?
			@lancamentos = @lancamentos.where("nro_documento = ?", params[:nro_documento])
		end
		
		@lancamentos = @lancamentos.paginate(:page => params[:page], :per_page => 10, :order => "id DESC")
		if @acesso == "RD7WEB002"
			flash[:error] = "Você não possui permissão para acessar esta página. Favor contactar o Administrador."
			redirect_to "/home/index"
		end
	end
	
	def aprovacao
		@nav_bar = "Aprovação"
		
		carrega_lancamentos
		
		if params[:periodo].nil?
			if @periodo.count == 0
				params[:periodo] = Periodo.last.id
			else
				params[:periodo] = @periodo.first.id
			end
		end
		
		if params[:usuario] == "and usuario_id > 0"
			params[:usuario] = "0"
		end
		
		if params[:usuario] == "0" or params[:usuario].nil?
			params[:usuario] = "and usuario_id > 0"
		else
			params[:usuario] = "and usuario_id = " + params[:usuario]
		end
		
		
		@lancamentos = Despesa.carrega_usuarios(params[:usuario], @usuario_logado.id, params[:periodo])
		
		for l in @lancamentos do
			@aprovado = Despesa.calcula_valores_despesas(l.usuario_id, params[:periodo], 2)
			@reprovado = Despesa.calcula_valores_despesas(l.usuario_id, params[:periodo], 3)
			@pendente = Despesa.calcula_valores_despesas(l.usuario_id, params[:periodo], 4)
			for a in @aprovado do
				l.vlr_aprovado = a.valor
				l.nr_aprovado = a.quantidade
			end
			for r in @reprovado do
				l.vlr_reprovado = r.valor
				l.nr_reprovado = r.quantidade
			end
			for p in @pendente do
				l.vlr_pendente_aprovacao = p.valor
				l.nr_pendente_aprovacao = p.quantidade
			end
		end
		
		if !params[:status].nil? and params[:status] != "0"
			lanc = []
			if params[:status] == "2"
				for l in @lancamentos do
					if l.nr_pendente_aprovacao == 0 && l.nr_reprovado == 0
						lanc << l
					end
				end
			elsif params[:status] == "3"
				for l in @lancamentos do
					if l.nr_reprovado != 0 && l.nr_pendente_aprovacao == 0
						lanc << l
					end
				end
			elsif params[:status] == "4"
				for l in @lancamentos do
					if l.nr_pendente_aprovacao > 0
						lanc << l
					end
				end
			end
			@lancamentos = lanc
		end
		
		@lancamentos = @lancamentos.paginate(:page => params[:page], :per_page => 10)
		if @acesso == "RD7WEB001"
			flash[:error] = "Você não possui permissão para acessar esta página. Favor contactar o Administrador."
			redirect_to "/home/index"
		end
	end
	
	def aprovacao_detalhe
		@nav_bar = "Aprovação > Detalhe"
		carrega_lancamentos
		@periodo = Periodo.select("*").where("id = #{params[:periodo]}")
		case params[:commit]
			when "Aprovar"
				aprovar
			when "Reprovar"
				reprovar
		end
		
		@usuario = Usuario.find(params[:usuario])
		@periodo = Periodo.find(params[:periodo])
		@lancamentos = Despesa.carrega_lancamentos
		@lancamentos = @lancamentos.where("usuario_id = #{params[:usuario]} and periodo_id = #{params[:periodo]} and status_lancamento_id <> 1")
		
		if @lancamentos.count == @lancamentos.where("status_lancamento_id = 2").count
			@status_lancamentos = "Aprovado"
		else
			if @lancamentos.where("status_lancamento_id = 3").count > 0
				@status_lancamentos = "Reprovado"
			else
				@status_lancamentos = "Pendente"
			end
		end
		
		if params[:tipo_lancamento] != "0" and !params[:tipo_lancamento].nil? and params[:tipo_lancamento] != ""
			@lancamentos = @lancamentos.where("tipo_lancamento_id = #{params[:tipo_lancamento]}")
		end
		
		if params[:tipo_despesa] != "0" and !params[:tipo_despesa].nil? and params[:tipo_despesa] != ""
			@lancamentos = @lancamentos.where("tipo_despesa_id = #{params[:tipo_despesa]}")
		end
		
		if params[:forma_pagamento] != "0" and !params[:forma_pagamento].nil? and params[:forma_pagamento] != ""
			@lancamentos = @lancamentos.where("forma_pagamento_id = #{params[:forma_pagamento]}")
		end
		
		if params[:status] != "0" and !params[:status].nil? and params[:status] != ""
			@lancamentos = @lancamentos.where("status_lancamento_id = #{params[:status]}")
		end
		
		if params[:centro_custo] != "0" and !params[:centro_custo].nil? and params[:centro_custo] != ""
			@lancamentos = @lancamentos.where("centro_custo_id = #{params[:centro_custo]}")
		end
		
		@valor_total = Despesa.find_by_sql("select ifnull(sum(vlr_despesa),0) as total from despesas where periodo_id = #{params[:periodo]} and status_lancamento_id = 2 and usuario_id = #{params[:usuario]}")
		
		@lancamentos = @lancamentos.paginate(:page => params[:page], :per_page => 10)
		if @acesso == "RD7WEB001"
			flash[:error] = "Você não possui permissão para acessar esta página. Favor contactar o Administrador."
			redirect_to "/home/index"
		end
	end
	
	def aprovar
		if !params[:lote].nil?
			@lancamentos = Despesa.find(params[:lote])
			if @lancamentos.class == Array
				for l in @lancamentos do
					if l.status_lancamento_id == 2 or l.status_lancamento_id == 3
						flash[:error] = "Lançamento selecionado já passou por aprovação."
						break
					else
						l.update_attribute :status_lancamento_id, 2
						l.update_attribute :usuario_alt_id, @usuario_logado.id
						h = HistoricoMovimento.new(:tipo_movimento_id => "4", :status_historico_movimento => "1", :despesa_id => l.id, :usuario_alt_id => @usuario_logado.id)
						h.save
						flash[:notice] = "Aprovação efetuada com sucesso!"
					end
				end
			else
				if @lancamentos.status_lancamento_id == 2 or @lancamentos.status_lancamento_id == 3
					flash[:error] = "Lançamento selecionado já passou por aprovação."
				else
					@lancamentos.update_attribute :status_lancamento_id, 2
					@lancamentos.update_attribute :usuario_alt_id, @usuario_logado.id
					h = HistoricoMovimento.new(:tipo_movimento_id => "4", :status_historico_movimento => "1", :despesa_id => @lancamentos.id, :usuario_alt_id => @usuario_logado.id)
					h.save
					flash[:notice] = "Aprovação efetuada com sucesso!"
				end
			end
		else
			flash[:error] = "Selecione itens para aprovação!"
		end
		limpa_url("/despesas/aprovacao_detalhe")
	end
	
	def reprovar
		if !params[:lote].nil?
			desp = params[:lote].split(",")
			@lancamentos = Despesa.find(desp)
			for l in @lancamentos do
				if l.status_lancamento_id == 2 or l.status_lancamento_id == 3
					flash[:error] = "Lançamento selecionado já passou por aprovação."
					break
				else
					l.update_attribute :status_lancamento_id, 3
					l.update_attribute :dsc_motivo, params[:motivo]
					l.update_attribute :usuario_alt_id, @usuario_logado.id
					h = HistoricoMovimento.new(:tipo_movimento_id => "2", :status_historico_movimento => "1", :despesa_id => l.id, :obs_historico_movimento => "Motivo Reprovação: #{params[:motivo]}", :usuario_alt_id => @usuario_logado.id)
					h.save
					flash[:notice] = "Reprovação efetuada com sucesso!"
				end
			end
		else
			flash[:error] = "Selecione itens para reprovação!"
		end
		limpa_url("/despesas/aprovacao_detalhe")
	end
	
	def new
		@nav_bar = "Lançamento > Novo"
		carrega_lancamentos
		if params[:commit] == "copiar"
			@lanc_original = Despesa.find(params[:despesa])
			@lancamento = Despesa.new(:tipo_lancamento_id => @lanc_original.tipo_lancamento_id,
									:tipo_despesa_id => @lanc_original.tipo_despesa_id,
									:forma_pagamento_id => @lanc_original.forma_pagamento_id,
									:centro_custo_id => @lanc_original.centro_custo_id,
									:vlr_documento => format("%.2f", @lanc_original.vlr_documento),
									:nro_quantidade => @lanc_original.nro_quantidade,
									:vlr_despesa => format("%.2f", @lanc_original.vlr_despesa),
									:dsc_despesa => @lanc_original.dsc_despesa)
		else
			@lancamento = Despesa.new
		end
	end
	
	def create
		params[:despesa][:vlr_documento] = params[:despesa][:vlr_documento].tr(",", ".")
		params[:despesa][:vlr_despesa] = params[:despesa][:vlr_despesa].tr(",", ".")
		@lancamento = Despesa.new(params[:despesa])
		@lancamento.status_lancamento_id = "1"
		@lancamento.periodo_id = params[:periodo]
		respond_to do |format|
			if @lancamento.save
				h = HistoricoMovimento.new(:tipo_movimento_id => "1", :status_historico_movimento => "1", :despesa_id => @lancamento.id, :usuario_alt_id => @usuario_logado.id)
				h.save
				if params[:flgEnvioAuto]
					@lancamento.update_attributes(:status_lancamento_id => 4, :usuario_alt_id => @usuario_logado.id)
					h = HistoricoMovimento.new(:tipo_movimento_id => "6", :status_historico_movimento => "1", :despesa_id => @lancamento.id, :usuario_alt_id => @usuario_logado.id)
					h.save
					format.html { redirect_to new_despesa_url }
					flash[:notice] = "Lançamento criado e enviado para Aprovação com sucesso!"
				else
					format.html { redirect_to new_despesa_url }
					flash[:notice] = "Lançamento criado com sucesso!"
				end
			else
				format.html { render new }
				flash[:error] = "Nenhum campo deve ficar em branco!"
			end
		end
	end
	
	def edit
		@nav_bar = "Lançamento > Editar"
		@lancamento = Despesa.find_by_sql("select *, (date_format(dt_documento,'%d/%m/%Y')) as dt_documento,
													format(vlr_documento, 2) as vlr_documento,
													format(vlr_despesa, 2) as vlr_despesa
													from despesas where id = #{params[:id]}")
		carrega_lancamentos
		@historico = Despesa.carrega_historico(params[:id])
	end
	
	def update
		@lancamento = Despesa.find(params[:id])
		respond_to do |format|
			if @lancamento.update_attributes(params[:despesa], :status_lancamento_id => "1", :usuario_alt_id => @usuario_logado.id)
				format.html { redirect_to new_despesa_url }
				flash[:notice] = "Despesa alterada com sucesso!"
				h = HistoricoMovimento.new(:tipo_movimento_id => "3", :status_historico_movimento => "1", :despesa_id => @lancamento.id, :usuario_alt_id => @usuario_logado.id)
				h.save
				if params[:flgEnvioAuto]
					@lancamento.update_attributes(:status_lancamento_id => 4, :usuario_alt_id => @usuario_logado.id)
					h = HistoricoMovimento.new(:tipo_movimento_id => "6", :status_historico_movimento => "1", :despesa_id => @lancamento.id, :usuario_alt_id => @usuario_logado.id)
					h.save
					format.html { redirect_to new_despesa_url }
					flash[:notice] = "Lançamento alterado e enviado para Aprovação com sucesso!"
				else
					format.html { redirect_to new_despesa_url }
					flash[:notice] = "Lançamento alterado com sucesso!"
				end
			end
		end
	end
	
	def carrega_lancamentos
		@status = StatusLancamento.select("*").order("dsc_status_lancamento ASC")
		@usuarios = Usuario.select("*").order("nome ASC")
		@tipo_lancamentos = TipoLancamento.select("*").where("status_tipo_lancamento = 1").order("dsc_tipo_lancamento ASC")
		@periodos = Periodo.select("*").order("id desc")
		@tipo_despesas = TipoDespesa.select("*").where("status_tipo_despesa = 1").order("dsc_tipo_despesa ASC")
		@forma_pagamentos = FormaPagamento.select("*").where("status_forma_pagamento = 1").order("dsc_forma_pagamento ASC")
		@centro_custos = CentroCusto.select("*").where("status_centro_custo = 1").order("cod_centro_custo")
		@periodo = Periodo.select("*, datediff(dt_fim_lancamento, now()) as dias_faltam").where("date(dt_inicio_lancamento) <= date(NOW()) and date(dt_envio_financeiro) >= date(NOW())")
		if @periodo.count == 0
			id_periodo = Periodo.select("id").last
			@periodo = Periodo.select("*, datediff(dt_fim_lancamento, now()) as dias_faltam").where("id = #{id_periodo.id}")
		end
		
		@lancamentos = Despesa.find_by_sql("select sl.dsc_status_lancamento as descricao, td.dsc_tipo_despesa as despesa, d.* from
											status_lancamentos sl, despesas d, tipo_despesas td where
											sl.id = d.status_lancamento_id and
											d.tipo_despesa_id = td.id and
											d.usuario_id = #{@usuario_logado.id} and
											d.periodo_id = #{@periodo.first.id}
											order by d.id DESC limit 10")
	end
	
	def excluir
		if !params[:lote].nil?
			@lancamentos = Despesa.find(params[:lote])
			if @lancamentos.class == Array
				for l in @lancamentos do
					if l.status_lancamento_id == 2 or l.status_lancamento_id == 4
						flash[:error] = "Somente Lançamentos Pendentes podem ser excluídos!"
						break
					else
						h = HistoricoMovimento.new(:tipo_movimento_id => "5", :status_historico_movimento => "1", :despesa_id => l.id, :usuario_alt_id => @usuario_logado.id)
						h.save
						l.destroy
						flash[:notice] = "Exclusão realizada com sucesso!"
					end
				end
			else
				if @lancamentos.status_lancamento_id == 2 or @lancamentos.status_lancamento_id == 4
					flash[:error] = "Lançamento não pode ser excluído."
				else
					h = HistoricoMovimento.new(:tipo_movimento_id => "5", :status_historico_movimento => "1", :despesa_id => @lancamentos.id, :usuario_alt_id => @usuario_logado.id)
					h.save
					@lancamentos.destroy
					flash[:notice] = "Exclusão realizada com sucesso!"
				end
			end
		else
			flash[:error] = "Selecione itens para exclusão!"
		end
		limpa_url("/despesas")
	end
	
	def enviar_aprovacao
		if !params[:lote].nil?
			@lancamentos = Despesa.find(params[:lote])
			if @lancamentos.class == Array
				for l in @lancamentos do
					if l.status_lancamento_id == 4 or l.status_lancamento_id == 2 or l.status_lancamento_id == 3
						flash[:error] = "Lançamento já foi enviado para Aprovação!"
					else
					#TODO Consertar os "números mágicos"
					#@lancamento.enviar_para_aprovacao
						l.update_attributes(:status_lancamento_id => 4, :usuario_alt_id => @usuario_logado.id)
						h = HistoricoMovimento.new(:tipo_movimento_id => "6", :status_historico_movimento => "1", :despesa_id => l.id, :usuario_alt_id => @usuario_logado.id)
						h.save
						flash[:notice] = "Lançamento(s) enviado(s) para Aprovação!"
					end
				end
			else
				if @lancamentos.status_lancamento_id == 4 or @lancamentos.status_lancamento_id == 2
					flash[:error] = "Lançamento já foi enviado para Aprovação!"
				else
					@lancamentos.update_attribute :status_lancamento_id, 4
					@lancamentos.update_attribute :usuario_alt_id, @usuario_logado.id
					h = HistoricoMovimento.new(:tipo_movimento_id => "6", :status_historico_movimento => "1", :despesa_id => @lancamentos.id, :usuario_alt_id => @usuario_logado.id)
					h.save
					flash[:notice] = "Lançamento(s) enviado(s) para Aprovação!"
				end
			end
		else
			flash[:error] = "Selecione itens para serem enviados!"
		end
		if params[:ir_para]
			case params[:ir_para]
				when "home"
					redirect_to home_index_url
				when "novo"
				 redirect_to new_despesa_url
			end
		else
			limpa_url("/despesas")
		end
		
	end
	
	def limpa_url(path)
		u = URI::parse request.headers["Referer"]
		u.query = "periodo=#{params[:periodo]}&usuario=#{params[:usuario] unless params[:usuario] == nil}&tipo_lancamento=#{params[:tipo_lancamento] unless params[:tipo_lancamento] == nil}&tipo_despesa=#{params[:tipo_despesa] unless params[:tipo_despesa] == nil}&status=#{params[:status] unless params[:status] == nil}&nro_documento=#{params[:nro_documento] unless params[:nro_documento] == nil}&de=#{params[:de] unless params[:de] == nil}&ate=#{params[:ate] unless params[:ate] ==nil}&centro_custo=#{params[:centro_custo] unless params[:centro_custo] == nil}&forma_pagamento=#{params[:forma_pagamento] unless params[:forma_pagamento] == nil}&page=#{params[:page] unless params[:page] == nil}&commit=#{params[:commit] unless params[:commit] == nil or params[:commit] != "Buscar"}"
		u.path = path
		redirect_to u.to_s
	end
	
end
