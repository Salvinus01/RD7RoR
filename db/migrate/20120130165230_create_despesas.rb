class CreateDespesas < ActiveRecord::Migration
  def change
    create_table :despesas do |t|
      t.references :periodo_id
      t.references :usuario_id
      t.references :tipo_lancamento_id
      t.references :tipo_despesa_id
      t.references :forma_pagamento_id
      t.references :centro_custo_id
      t.datetime :dt_documento
      t.string :nro_documento
      t.float :vlr_documento
      t.integer :nro_quantidade
      t.float :vlr_despesa
      t.text :dsc_despesa
      t.references :status_lancamento_id
      t.integer :usuario_alt_id

      t.timestamps
    end
    add_index :despesas, :periodo_id_id
    add_index :despesas, :usuario_id_id
    add_index :despesas, :tipo_lancamento_id_id
    add_index :despesas, :tipo_despesa_id_id
    add_index :despesas, :forma_pagamento_id_id
    add_index :despesas, :centro_custo_id_id
    add_index :despesas, :status_lancamento_id_id
  end
end
