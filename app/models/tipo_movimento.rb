class TipoMovimento < ActiveRecord::Base
	has_many :Historicomovimentos
end
