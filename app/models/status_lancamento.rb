class StatusLancamento < ActiveRecord::Base
	has_many :despesas
	
		REPROVADO = 3
		PENDENTE  = 1
		
	def	pendente?
	  self.status == PENDENTE
	end
	
	def	reprovado?
	  self.status == REPROVADO
	end
end
