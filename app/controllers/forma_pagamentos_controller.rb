class FormaPagamentosController < ApplicationController
  before_filter :verifica_administrador
  def self.seven_spec
	{ :telas => {[:new, :create] => 2, [:edit, :update] => 8 }}
  end
  
  def index
	@nav_bar = "Cadastro > Forma de Pagamento"
	
	case params[:commit]
		when "Ativar" then
			ativar
		when "Inativar" then
			inativar
	end
	
	@forma_pagamentos = FormaPagamento.select("*")
	
	if !params[:ativo].nil? and params[:inativo].nil?
		@forma_pagamentos = @forma_pagamentos.where("status_forma_pagamento = 1")
	else
		if params[:ativo].nil? and !params[:inativo].nil?
			@forma_pagamentos = @forma_pagamentos.where("status_forma_pagamento = 0")
		end
	end
	
	if params[:descricao] != "" and !params[:descricao].nil?
		@forma_pagamentos = @forma_pagamentos.where("dsc_forma_pagamento like ?", "%" + params[:descricao] + "%")
	end
	
	@forma_pagamentos = @forma_pagamentos.paginate(:page => params[:page], :per_page => 10)
  end

  def new
	@nav_bar = "Cadastro > Forma Pagamento > Novo"
	@forma_pagamento = FormaPagamento.new
  end

  def create
	@forma_pagamento = FormaPagamento.new(params[:forma_pagamento])
	
	respond_to do |format|
		if @forma_pagamento.save
			format.html { redirect_to forma_pagamentos_url }
			flash[:notice] = "Forma de Pagamento criada com sucesso!"
		else
			format.html { redirect_to new_forma_pagamento_url }
			flash[:error] = "Nenhum campo deve ficar em branco!"
		end
	end
  end

  def edit
	@nav_bar = "Cadastro > Forma Pagamento > Editar"
	@forma_pagamento = FormaPagamento.find(params[:id])
  end

  def update
	@forma_pagamento = FormaPagamento.find(params[:id])
	
	respond_to do |format|
		if @forma_pagamento.update_attributes(params[:forma_pagamento])
			format.html { redirect_to forma_pagamentos_url }
			flash[:notice] = "Forma de Pagamento alterada com sucesso!"
		else
			format.html { redirect_to edit_forma_pagamento_url }
			flash[:error] = "Nenhum campo deve ficar em branco!"
		end
	end
  end
  
  def ativar
		if !params[:lote].nil?
			fpgto = FormaPagamento.find(params[:lote])
			for f in fpgto do
				if f.status_forma_pagamento == 0
					f.update_attribute :status_forma_pagamento, 1
					flash[:notice] = "Forma de Pagamento ativada com sucesso!"
				else
					flash[:error] = "Forma de pagamento já está ativa!"
				end
			end
		else
			flash[:error] = "Nenhuma forma de pagamento foi selecionada!"
		end
		redirect_to forma_pagamentos_path
  end
  
  def inativar
	if !params[:lote].nil?
		fpgto = FormaPagamento.find(params[:lote])
		for f in fpgto do
			if f.status_forma_pagamento == 1
				f.update_attribute :status_forma_pagamento, 0
				flash[:notice] = "Forma de Pagamento inativada com sucesso!"
			else
				flash[:error] = "Forma de pagamento já está inativa!"
			end
		end
	else
		flash[:error] = "Nenhuma forma de pagamento foi selecionada!"
	end
	redirect_to forma_pagamentos_path
  end
end
