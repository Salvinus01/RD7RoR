class CreateStatusLancamentos < ActiveRecord::Migration
  def change
    create_table :status_lancamentos do |t|
      t.string :dsc_status_lancamento
      t.integer :status_status_lancamento
      t.integer :usuario_alt_id

      t.timestamps
    end
  end
end
