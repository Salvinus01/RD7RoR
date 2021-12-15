class CentroCustosController < ApplicationController
	before_filter :verifica_administrador
	def self.seven_spec
		{ :telas => { [:new, :create] => 1, [:edit, :update] => 7 }}
	end
	
	def index
		@nav_bar = "Cadastro > Centro de Custo"
		
		
		
		if(params[:ordem] == nil) or (params[:ordem] == "")
			@centro_custos = CentroCusto.select("*").order("cod_centro_custo ASC")
		else
			case params[:ordem]
				when "codAsc"
					@centro_custos = CentroCusto.select("*").order("cod_centro_custo ASC")
				when "codDsc"
					@centro_custos = CentroCusto.select("*").order("cod_centro_custo DESC")
				when "descAsc"
					@centro_custos = CentroCusto.select("*").order("dsc_centro_custo ASC")
				when "descDsc"
					@centro_custos = CentroCusto.select("*").order("dsc_centro_custo DESC")
			end
		end
		
		case params[:commit]
			when "Ativar" then
				ativar
			when "Inativar" then
				inativar
		end
		
		if !params[:ativo].nil? and params[:inativo].nil?
			@centro_custos = @centro_custos.where("status_centro_custo = 1")
		else
			if params[:ativo].nil? and !params[:inativo].nil?
				@centro_custos = @centro_custos.where("status_centro_custo = 0")
			end
		end
		
		if params[:codigo] != "" and !params[:codigo].nil?
			@centro_custos = @centro_custos.where("cod_centro_custo = #{params[:codigo]}")
		end
		
		if params[:descricao] != "" and !params[:descricao].nil?
			@centro_custos = @centro_custos.where("dsc_centro_custo like ?", "%" + params[:descricao] + "%")
		end
		
		@centro_custos = @centro_custos.paginate(:page => params[:page], :per_page => 10)
	end
	
	def new
		@nav_bar = "Cadastro > Centro de Custo > Novo"
		
		@centro_custo = CentroCusto.new
	end
	
	def create
		@centro_custo = CentroCusto.new(params[:centro_custo])
		
		respond_to do |format|
			if @centro_custo.save
				format.html { redirect_to centro_custos_url }
				flash[:notice] = "Centro de Custo criado com sucesso!"
			else
				format.html { redirect_to new_centro_custo_url }
				flash[:error] = "Nenhum campo deve ficar em branco!"
			end
		end
	end
	
	def edit
		@nav_bar = "Cadastro > Centro de Custo > Editar"
		
		@centro_custo = CentroCusto.find(params[:id])
	end
	
	def update
		@centro_custo = CentroCusto.find(params[:id])

		respond_to do |format|
			if @centro_custo.update_attributes(params[:centro_custo])
				format.html { redirect_to centro_custos_url }
				flash[:notice] = "Centro de Custo alterado com sucesso!"
			else
				format.html { redirect_to edit_centro_custo_url }
				flash[:error] = "Nenhum campo deve ficar em branco!"
			end
		end
	end
	
	def ativar
		if !params[:lote].nil?
			cen = CentroCusto.find(params[:lote])
			for c in cen do
				if c.status_centro_custo == 0
					c.update_attribute :status_centro_custo, 1
					flash[:notice] = "Centro de Custo ativado com sucesso!"
				else
					flash[:error] = "Centro de Custo já está ativo!"
				end
			end
		else
			flash[:error] = "Nenhum Centro de Custo foi selecionado!"
		end
		redirect_to centro_custos_path
	end
	
	def inativar
		if !params[:lote].nil?
			cen = CentroCusto.find(params[:lote])
			for c in cen do
				if c.status_centro_custo == 1
					c.update_attribute :status_centro_custo, 0
					flash[:notice] = "Centro de Custo inativado com sucesso!"
				else
					flash[:error] = "Centro de Custo já está inativo!"
				end
			end
		else
			flash[:error] = "Nenhum Centro de Custo foi selecionado!"
		end
		redirect_to centro_custos_path
	end
end
