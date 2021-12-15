class CreateFormaPagamentos < ActiveRecord::Migration
  def change
    create_table :forma_pagamentos do |t|
      t.string :dsc_forma_pagamento
      t.integer :status_forma_pagamento
      t.integer :usuario_alt_id

      t.timestamps
    end
  end
end
