class CreateTipoDespesas < ActiveRecord::Migration
  def change
    create_table :tipo_despesas do |t|
      t.string :dsc_tipo_despesa
      t.integer :status_tipo_despesa
      t.integer :usuario_alt_id

      t.timestamps
    end
  end
end
