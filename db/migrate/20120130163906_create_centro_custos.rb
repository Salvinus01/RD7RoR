class CreateCentroCustos < ActiveRecord::Migration
  def change
    create_table :centro_custos do |t|
      t.integer :cod_centro_custo
      t.string :dsc_centro_custo
      t.integer :status_centro_custo
      t.integer :usuario_alt_id

      t.timestamps
    end
  end
end
