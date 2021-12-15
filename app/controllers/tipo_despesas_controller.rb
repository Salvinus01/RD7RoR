class TipoDespesasController < ApplicationController
	before_filter :verifica_administrador
	def self.seven_spec
		{:telas => {[:new, :create] => 4, [:edit, :update] => 10}}
	end
	
	def index
		@nav_bar = "Cadastro > Tipo Despesa"
	 
	
		case params[:commit]
			when "Ativar" then
				ativar
			when "Inativar" then
				inativar
		end
	 
		@tipo_despesa = TipoDespesa.select("*")
		
		if params[:descricao] != "" and !params[:descricao].nil?
			@tipo_despesa = @tipo_despesa.where("dsc_tipo_despesa like ?", "%" + params[:descricao] + "%")
		end	
	
		if !params[:ativo].nil? and params[:inativo].nil?
			@tipo_despesa = @tipo_despesa.where("status_tipo_despesa = 1")
		else
			if params[:ativo].nil? and !params[:inativo].nil?
				@tipo_despesa = @tipo_despesa.where("status_tipo_despesa = 0")
			end
		end

		@tipo_despesa = @tipo_despesa.paginate(:page => params[:page], :per_page => 10)
	
	end
  
	def new
		@nav_bar = "Cadastro > Tipo Despesa > Novo"
		
		@despesa = TipoDespesa.new
		
	end
	
	
	def create
		@tipo_despesa = TipoDespesa.new(params[:tipo_despesa])

		respond_to do |format|
		  if @tipo_despesa.save
			format.html { redirect_to tipo_despesas_url }
			flash[:notice] = "Tipo de Despesa criado com sucesso!"
		  else
			format.html { redirect_to new_tipo_despesa_url }
			flash[:error] = "Nenhum campo deve ficar em branco!"
		  end
		end
	  end

	def edit
		@nav_bar = "Cadastro > Tipo Despesas > Editar"
		
		@despesa = TipoDespesa.find(params[:id])
		
	  end

	def update
		@despesa = TipoDespesa.find(params[:id])
		
		respond_to do |format|
			if @despesa.update_attributes(params[:tipo_despesa])
				format.html { redirect_to tipo_despesas_url }
				flash[:notice] = "Tipo de Despesa alterado com sucesso!"
			else
				format.html { redirect_to edit_tipo_despesa_url }
				flash[:error] = "Nenhum campo deve ficar em branco!"
			end
		end
	end
	
	def ativar
		if !params[:lote].nil?
			per = TipoDespesa.find(params[:lote])
			for p in per do
				if p.status_tipo_despesa == 0
					p.update_attribute :status_tipo_despesa, 1
					flash[:notice] = "Tipo de Despesa ativado com sucesso!"
				else
					flash[:error] = "Tipo de Despesa já está ativa!"
				end
			end
		else
			flash[:error] = "Nenhum periodo foi selecionado!"
		end
		redirect_to tipo_despesas_path
	end
	
	def inativar
		if !params[:lote].nil?
			per = TipoDespesa.find(params[:lote])
			for p in per do
				if p.status_tipo_despesa == 1
					p.update_attribute :status_tipo_despesa, 0
					flash[:notice] = "Tipo de Despesa inativado com sucesso!"
				else
					flash[:error] = "Tipo de Despesa já está inativo!"
				end
			end
		else
			flash[:error] = "Nenhum periodo foi selecionado!"
		end
		redirect_to tipo_despesas_path
	end
	

end
