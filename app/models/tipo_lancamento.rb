class TipoLancamento < ActiveRecord::Base
	has_many :despesas

	validates_presence_of :dsc_tipo_lancamento
	validates_presence_of :status_tipo_lancamento
end
