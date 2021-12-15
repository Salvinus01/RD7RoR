class CreateTipoMovimentos < ActiveRecord::Migration
  def change
    create_table :tipo_movimentos do |t|
      t.string :desc_tipo_movimento
      t.string :status_tipo_movimento
      t.integer :usuario_alt_id

      t.timestamps
    end
  end
end
