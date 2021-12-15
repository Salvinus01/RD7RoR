class PeriodosController < ApplicationController
   before_filter :verifica_administrador
   def self.seven_spec
		{ :telas => {[:new, :create] => 3, [:edit, :update] => 9}}
   end
   
   def index
	@nav_bar = "Cadastro > Periodo"
	
	@anos = Periodo.find_by_sql("select year(dt_inicio_lancamento) as anos from periodos group by anos")
	
	case params[:commit]
		when "Ativar" then
			ativar
		when "Inativar" then
			inativar
	end
	
	@periodos = Periodo.select("*")
	
	if params[:mes] != "0" and !params[:mes].nil? and params[:mes] != ""
		@periodos = @periodos.where("month(dt_inicio_lancamento) = #{params[:mes]}")
	end
	
	if params[:ano] != "0" and !params[:ano].nil? and params[:ano] != ""
		@periodos = @periodos.where("year(dt_inicio_lancamento) = #{params[:ano]}")	
	end
	
	if params[:status] != "0" and !params[:status].nil?
		if params[:status] == "1"
			@periodos = @periodos.where("dt_inicio_lancamento <= now() and dt_fim_lancamento >= now()")
		elsif params[:status] == "2"
			@periodos = @periodos.where("dt_fim_lancamento < now() and dt_aprovacao >= now()")
		elsif params[:status] == "3"
			@periodos = @periodos.where("dt_aprovacao < now() and dt_envio_financeiro > now()")
		else
			@periodos = @periodos.where("dt_envio_financeiro < now()")
		end
	end

	
	@periodos = @periodos.paginate(:page => params[:page], :per_page => 10, :order => "id DESC")
	
  end

  def new
	@nav_bar = "Cadastro > Periodo > Novo"
	
	@periodo = Periodo.new
	
	respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @periodo }
    end
  end

	def edit
		@nav_bar = "Cadastro > Periodo > Editar"
		
		@periodo = Periodo.find_by_sql("select *, (date_format(dt_inicio_lancamento,'%d/%m/%Y')) as dt_inicio_lancamento,
												(date_format(dt_fim_lancamento,'%d/%m/%Y')) as dt_fim_lancamento,
												(date_format(dt_aprovacao,'%d/%m/%Y')) as dt_aprovacao,
												(date_format(dt_envio_financeiro,'%d/%m/%Y')) as dt_envio_financeiro
												from periodos
												where id=#{params[:id]}")
	end

  def create
	@periodo = Periodo.new(params[:periodo])
	if Periodo.where("'#{@periodo.dt_inicio_lancamento.to_date}' >= dt_inicio_lancamento and '#{@periodo.dt_inicio_lancamento.to_date}' <= dt_fim_lancamento").count != 0
		existe = true
	elsif Periodo.where("'#{@periodo.dt_envio_financeiro.to_date}' >= dt_inicio_lancamento and '#{@periodo.dt_envio_financeiro.to_date}' <= dt_envio_financeiro").count != 0
		existe = true
	else
		existe = false
	end
	
	if existe
		flash[:error] = "Novo período não deve ocorrer simultaneamente com outros períodos. Favor alterar as datas."
		redirect_to :back
	else
		puts params[:periodo]
		puts @periodo.dt_inicio_lancamento
		respond_to do |format|
			if @periodo.save
				format.html { redirect_to periodos_url }
			else
				format.html { redirect_to new_periodo_url }
				flash[:error] = "Nenhum campo deve ficar em branco!"
			end
		end
	end
  end

  def update
	@periodo = Periodo.find(params[:id])
	puts Periodo.where("'#{@periodo.dt_inicio_lancamento.to_date}' >= dt_inicio_lancamento and '#{@periodo.dt_inicio_lancamento.to_date}' <= dt_fim_lancamento and id <> #{params[:id]}").count
	if Periodo.where("'#{@periodo.dt_inicio_lancamento.to_date}' >= dt_inicio_lancamento and '#{@periodo.dt_inicio_lancamento.to_date}' <= dt_fim_lancamento and id <> #{params[:id]}").count != 0
		existe = true
	elsif Periodo.where("'#{@periodo.dt_envio_financeiro.to_date}' >= dt_inicio_lancamento and '#{@periodo.dt_envio_financeiro.to_date}' <= dt_envio_financeiro and id <> #{params[:id]}").count != 0
		existe = true
	else
		existe = false
	end
	
	if existe
		flash[:error] = "Novo período não deve ocorrer simultaneamente com outros períodos. Favor alterar as datas."
		redirect_to :back
	else
		respond_to do |format|
			if @periodo.update_attributes(params[:periodo])
				format.html { redirect_to periodos_url }
				flash[:notice] = "Periodo alterado com sucesso!"
			else
				format.html { redirect_to edit_periodo_url }
				flash[:error] = "Nenhum campo deve ficar em branco!"
			end
		end
	end
  end

end
