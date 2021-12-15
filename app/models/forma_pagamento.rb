class FormaPagamento < ActiveRecord::Base
	has_many :despesas
	
	validates_presence_of :dsc_forma_pagamento
	validates_presence_of :status_forma_pagamento
end
