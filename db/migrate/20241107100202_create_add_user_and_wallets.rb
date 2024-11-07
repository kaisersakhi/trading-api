class CreateAddUserAndWallets < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false

      t.timestamps
    end

    create_table :currencies do |t|
      t.string :name, null: false
      t.string :symbol, null: false

      t.timestamps
    end

    create_table :wallets do |t|
      t.references :user, null: false, foreign_key: true
      t.references :currency, null: false, foreign_key: true
      t.bigint :balance, default: 0

      t.timestamps
    end

    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.string :side, null: false
      t.integer :status, null: false
      t.bigint :base_currency, null: false
      t.bigint :quote_currency, null: false
      t.integer :volume, null: false
      t.float :price, null: false

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :currencies, :symbol, unique: true
    add_foreign_key :orders, :currencies, column: :base_currency
    add_foreign_key :orders, :currencies, column: :quote_currency
  end
end
