class TipoLancamentosController < ApplicationController
  before_filter :verifica_administrador
  def self.seven_spec
	{:telas => {[:new, :create] => 5, [:edit, :update] => 11}}
  end
  
  def index
	@nav_bar = "Cadastro > Tipo de Lançamento"
	
	case params[:commit]
		when "Ativar" then
			ativar
		when "Inativar" then
			inativar	
	end
	
	@tipo_lancamentos = TipoLancamento.select("*")
	
	if !params[:ativo].nil? and params[:inativo].nil?
		@tipo_lancamentos = @tipo_lancamentos.where("status_tipo_lancamento = 1")
	else
		if params[:ativo].nil? and !params[:inativo].nil?
			@tipo_lancamentos = @tipo_lancamentos.where("status_tipo_lancamento = 0")
		end
	end
	
	if params[:descricao] != "" and !params[:descricao].nil?
		@tipo_lancamentos = @tipo_lancamentos.where("dsc_tipo_lancamento like ?", params[:descricao])
	end
	
	@tipo_lancamentos = @tipo_lancamentos.paginate(:page => params[:page], :per_page => 10)
  end

  def new
	@nav_bar = "Cadastro > Tipo de Lançamento > Novo"
	
	@tipo_lancamento = TipoLancamento.new
  end

  def create
	@tipo_lancamento = TipoLancamento.new(params[:tipo_lancamento])
	
	respond_to do |format|
		if @tipo_lancamento.save
			format.html { redirect_to tipo_lancamentos_url }
			flash[:notice] = "Tipo de Lançamento criado com sucesso!"
		else
			format.html { redirect_to new_tipo_lancamento_url }
			flash[:error] = "Nenhum campo deve ficar em branco!"
		end
	end
  end

  def edit
	@nav_bar = "Cadastro > Tipo de Lançamento > Editar"
	
	@tipo_lancamento = TipoLancamento.find(params[:id])
  end

  def update
	@tipo_lancamento = TipoLancamento.find(params[:id])
	
	respond_to do |format|
		if @tipo_lancamento.update_attributes(params[:tipo_lancamento])
			format.html { redirect_to tipo_lancamentos_url }
			flash[:notice] = "Tipo de Lançamento alterado com sucesso!"
		else
			format.html { redirect_to edit_tipo_lancamento_url }
			flash[:error] = "Nenhum campo deve ficar em branco!"
		end
	end
  end

  def ativar
	if !params[:lote].nil?
		tplanc = TipoLancamento.find(params[:lote])
		for t in tplanc do
			if t.status_tipo_lancamento == 0
				t.update_attribute :status_tipo_lancamento, 1
				flash[:notice] = "Tipo de Lançamento ativado com sucesso!"
			else
				flash[:error] = "Tipo de Lançamento já está ativo!"
			end
		end
	else
		flash[:error] = "Nenhum Tipo de Lançamento foi selecionada!"
	end
	redirect_to tipo_lancamentos_path
  end

  def inativar
	if !params[:lote].nil?
		tplanc = TipoLancamento.find(params[:lote])
		for t in tplanc do
			if t.status_tipo_lancamento == 1
				t.update_attribute :status_tipo_lancamento, 0
				flash[:notice] = "Tipo de Lançamento inativado com sucesso!"
			else
				flash[:error] = "Tipo de Lançamento já está inativo!"
			end
		end
	else
		flash[:error] = "Nenhum tipo de lançamento foi selecionada!"
	end
	redirect_to tipo_lancamentos_path
  end
end
