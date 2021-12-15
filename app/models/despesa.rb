class Despesa < ActiveRecord::Base
  belongs_to :Periodo
  belongs_to :Usuario
  belongs_to :TipoLancamento
  belongs_to :TipoDespesa
  belongs_to :FormaPagamento
  belongs_to :CentroCusto
  belongs_to :StatusLancamento
  
  validates_presence_of :tipo_lancamento_id
  validates_presence_of :tipo_despesa_id
  validates_presence_of :forma_pagamento_id
  validates_presence_of :centro_custo_id
  # validates_presence_of :periodo_id
  #validates_presence_of :status_lancamento_id
  
  def self.carrega_usuarios(usuario, logado, periodo)
	Despesa.find_by_sql("select u.nome, usuario_id,0 as nr_aprovado, 0 as vlr_aprovado,
						0 as nr_reprovado, 0 as vlr_reprovado, 
						0 as nr_pendente_aprovacao, 0 as vlr_pendente_aprovacao 
						from despesas, usuarios u
						where status_lancamento_id in (2,3,4) #{usuario} and
						despesas.usuario_id = u.id
						and usuario_id <> #{logado}
						and despesas.periodo_id = #{periodo}
						group by usuario_id")
  end
  
  def self.calcula_valores_despesas(usuario, periodo, status)
	Despesa.find_by_sql("select sum(vlr_despesa) as valor, count(vlr_despesa) as quantidade 
						from despesas
						where usuario_id = #{usuario} and status_lancamento_id = #{status} and periodo_id = #{periodo}
						group by usuario_id")
  end
  
  def self.carrega_lancamentos
	Despesa.joins("left outer join status_lancamentos sl on despesas.status_lancamento_id = sl.id")
			.joins("left outer join tipo_despesas td on despesas.tipo_despesa_id = td.id")
			.joins("left outer join tipo_lancamentos tl on despesas.tipo_lancamento_id = tl.id")
			.joins("left outer join centro_custos cc on despesas.centro_custo_id = cc.id")
			.joins("left outer join forma_pagamentos fp on despesas.forma_pagamento_id = fp.id")
			.joins("left outer join usuarios u on despesas.usuario_id = u.id")
			.select("despesas.*,
					sl.dsc_status_lancamento as status,
					td.dsc_tipo_despesa as tipo_despesa,
					tl.dsc_tipo_lancamento as dsc_tipo_lancamento,
					cc.cod_centro_custo as cod_centro_custo,
					fp.dsc_forma_pagamento as dsc_forma_pagamento,
					u.nome as usuario")
  end
  
  def self.carrega_historico(id)
		Despesa.joins("left outer join historico_movimentos h on despesas.id = h.despesa_id")
				.joins("left outer join tipo_movimentos tm on tm.id = h.tipo_movimento_id")
				.joins("left outer join usuarios u on u.id = h.usuario_alt_id")
				.select("tm.dsc_tipo_movimento, h.obs_historico_movimento, h.created_at, u.nome as nome")
				.where("despesas.id = #{id}")
  end
end
