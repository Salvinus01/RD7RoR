class CentroCusto < ActiveRecord::Base
	has_many :despesas
	validates_presence_of :cod_centro_custo
	validates_presence_of :dsc_centro_custo
	validates_presence_of :status_centro_custo

end
