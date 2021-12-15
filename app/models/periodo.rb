class Periodo < ActiveRecord::Base
	has_many :despesas
	
	validates :dt_inicio_lancamento, :presence => true
	validates :dt_fim_lancamento, :presence => true
	validates :dt_aprovacao, :presence => true
	validates :dt_envio_financeiro, :presence => true
end
