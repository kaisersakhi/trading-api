class WalletsController < ApplicationController
  before_action :verify_request
  before_action :set_currency, except: :balances
  before_action :set_wallet

  def deposit
    if params[:currency].blank? || params[:amount].blank? || params[:amount].to_i == 0
      render json: { msg: "Both currency and amount must be specified, amount should be greater than zero" }

      return
    end

    if @currency.blank?
      render json: { msg: "Currency is invalid" }, status: :not_found

      return
    end

    operate_on_wallet(operation: :deposit)

    render json: {
      status: "success",
      msg: "successfully deposited funds",
      payload: {
        balance: @wallet.balance / 100.0,
        currency: @currency.symbol
      }
    }, status: :ok
  end

  def withdrawal
    if params[:currency].blank? || params[:amount].blank? || params[:amount].to_i == 0
      render json: { msg: "Both currency and amount must be specified, amount should be greater than zero" }

      return
    end

    if @currency.blank? || @wallet.blank?
      render json: { msg: "Currency is invalid or wallet doesn't exist" }, status: :not_found

      return
    end

   operate_on_wallet(operation: :withdraw)

    render json: {
      status: "success",
      msg: "successfully withdrawn funds",
      payload: {
        balance: @wallet.balance / 100.0,
        currency: @currency.symbol
      }
    }, status: :ok
  end

  def balances
    wallets = current_user.wallets.map do |w|
      {
        balance: w.balance / 100.0,
        currency: w.currency.symbol
      }
    end

    render json: {
      status: "success",
      msg: "successfully fetched funds",
      payload: wallets
    }, status: :ok
  end

  private

  def operate_on_wallet(operation:)
    amount = params[:amount] * 100

    if @wallet.blank?
      @wallet = current_user.wallets.create(currency: @currency, balance: amount)
    else
      @wallet.with_lock do
        if operation == :deposit
          @wallet.balance += amount
        elsif @wallet.balance >= amount
          @wallet.balance -= amount
        end
        @wallet.save!
      end
    end
  end

  def set_currency
    @currency ||= Currency.find_by(symbol: params[:currency])
  end

  def set_wallet
    @wallet ||= current_user.wallets.where(currency: @currency).first
  end
end
