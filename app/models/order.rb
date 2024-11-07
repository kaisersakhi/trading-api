class Order < ApplicationRecord
  belongs_to :user
  belongs_to :base_currency, class_name: 'Currency', foreign_key: 'base_currency'
  belongs_to :quote_currency, class_name: 'Currency', foreign_key: 'quote_currency'

  enum :status, { pending: 0, cancel: 1, complete: 2 }
  enum :side,  {
    buy: "buy",
    sell: "sell"
  }

  validates :side, presence: true
end
