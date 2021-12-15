class CreateTipoLancamentos < ActiveRecord::Migration
  def change
    create_table :tipo_lancamentos do |t|
      t.string :dsc_tipo_lancamento
      t.integer :status_tipo_lancamento
      t.integer :usuario_alt_id

      t.timestamps
    end
  end
end
