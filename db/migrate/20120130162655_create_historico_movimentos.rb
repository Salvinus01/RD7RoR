class CreateHistoricoMovimentos < ActiveRecord::Migration
  def change
    create_table :historico_movimentos do |t|
      t.references :tipo_movimento_id
      t.references :despesa_id
      t.string :obs_historico_movimento
      t.integer :status_historico_movimento
      t.integer :usuario_alt_id

      t.timestamps
    end
    add_index :historico_movimentos, :tipo_movimento_id_id
    add_index :historico_movimentos, :despesa_id_id
  end
end
