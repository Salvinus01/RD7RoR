class TipoDespesa < ActiveRecord::Base
	has_many :despesas
	
	validates_presence_of :dsc_tipo_despesa
	validates_presence_of :status_tipo_despesa
end
