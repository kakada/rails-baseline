class AddGfUserIdToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :gf_user_id, :integer
  end
end
