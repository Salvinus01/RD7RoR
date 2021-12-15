class CreateUsuarios < ActiveRecord::Migration
  def change
    create_table :usuarios do |t|
      t.string :login_7Control
      t.string :usuario_alt_id

      t.timestamps
    end
  end
end
