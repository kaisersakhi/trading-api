Rails.application.routes.draw do
  post "users/signup", to: "users#sign_up"
  post "users/login", to: "users#login"

  post "/wallets/deposit", to: "wallets#deposit"
  post "/wallet/withdrawal", to: "wallets#withdrawal"
  get "/wallet/balances", to: "wallets#balances"

  post "/order/create", to: "orders#create"
  put "/order/cancel", to: "orders#cancel"
end
