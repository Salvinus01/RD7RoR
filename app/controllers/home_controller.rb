class HomeController < ApplicationController
  
  
  
  
  def index
  
	@periodo = Periodo.select("*, datediff(dt_fim_lancamento, now()) as dias_faltam").where("date(dt_inicio_lancamento) <= date(NOW()) and date(dt_envio_financeiro) >= date(NOW())")
	
	if @periodo.count == 0
		@periodo = Periodo.select("*, datediff(dt_fim_lancamento, now()) as dias_faltam").order("id DESC")
	end
	
		
	@lancamentos = Despesa.find_by_sql("select sl.dsc_status_lancamento as descricao, td.dsc_tipo_despesa as despesa, d.* from
										status_lancamentos sl, despesas d, tipo_despesas td where
										sl.id = d.status_lancamento_id and
										d.tipo_despesa_id = td.id and 
										d.usuario_id = #{@usuario_logado.id} and
										d.periodo_id = #{@periodo.first.id}
										order by d.id DESC limit 10")
	# if @acesso == "RD7WEB002" || @acesso == "RD7WEB003"
		# @aprovados = Despesa.count(:conditions => "periodo_id = #{@periodo.first.id} and status_lancamento_id = 2")
		# @pendentes = Despesa.count(:conditions => "periodo_id = #{@periodo.first.id} and status_lancamento_id = 4")
		# @reprovados = Despesa.count(:conditions => "periodo_id = #{@periodo.first.id} and status_lancamento_id = 3")
		# @usuario = ""
	# else
		@aprovados = Despesa.count(:conditions => "periodo_id = #{@periodo.first.id} and status_lancamento_id = 2 and usuario_id = #{@usuario_logado.id}")
		@pendentes = Despesa.count(:conditions => "periodo_id = #{@periodo.first.id} and status_lancamento_id = 4 and usuario_id = #{@usuario_logado.id}")
		@reprovados = Despesa.count(:conditions => "periodo_id = #{@periodo.first.id} and status_lancamento_id = 3 and usuario_id = #{@usuario_logado.id}")
		@usuario = "and usuario_id = #{@usuario_logado.id}"
	# end
	@despesas = Despesa.find_by_sql("select t.dsc_tipo_despesa, format(sum(d.vlr_despesa), 2) as valores
									from despesas d, tipo_despesas t
									where 
									d.tipo_despesa_id = t.id and
									periodo_id = #{@periodo.first.id} 
									#{@usuario}
									group by tipo_despesa_id")
									
	@valores = []
	@legenda = []
	for d in @despesas do
		@valores << d.valores
		@legenda << [d.valores, d.dsc_tipo_despesa.to_s]
	end
	puts @legenda
   respond_to :html, :mobile

  end
end