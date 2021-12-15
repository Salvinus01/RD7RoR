class CreatePeriodos < ActiveRecord::Migration
  def change
    create_table :periodos do |t|
      t.datetime :dt_inicio_lancamento
      t.datetime :dt_fim_lancamento
      t.datetime :dt_aprovacao
      t.datetime :dt_envio_financeiro
      t.integer :status_periodo
      t.integer :usuario_alt_id

      t.timestamps
    end
  end
end
