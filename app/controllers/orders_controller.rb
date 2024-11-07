class OrdersController < ApplicationController
  before_action :verify_request

  def create
    side = params[:side]
    base_currency = Currency.find_by(symbol: params[:base_currency]&.upcase)
    quote_currency = Currency.find_by(symbol: params[:quote_currency]&.upcase)
    quote_price = params[:quote_price].to_f
    volume = params[:volume].to_f

    if side.blank? || base_currency.blank? || quote_currency.blank? || quote_price.zero? || volume.zero?
      render json: { error: "side, base_currency, quote_currency, quote_price, volume and quote_currency are required fields" }

      return
    end

    if wallet(side, base_currency, quote_currency).blank?
      render json: { error: "Wallet not found" }, status: 401

      return
    end

    unless order_processable?(side, volume, quote_price)
      render json: { error: "You don't have that much balance in the current wallet, please lower the volume" }, status: 401

      return
    end

    order = nil
    # binding.irb
    @wallet.with_lock do
      order = Order.new(
        user: current_user,
        side: side,
        base_currency: base_currency,
        quote_currency: quote_currency,
        volume: volume,
        price: quote_price,
        status: :pending
      )

      operate_on_wallet(order) if order.save

      @wallet.save
    end

    if order.errors.present?
      render json: { error: order.errors.full_messages.join(", ") }, status: 422
    else
      render json: {
        status: :success,
        message: "Successfully created",
        payload: order
      }, status: 201
    end
  end

  def cancel
    # binding.irb
    order = Order.find(params[:order_id])

    if order.blank? || order.cancel? || order.complete?
      render json: { error: "Order not found or order is either already cancelled or completed." }, status: 404

      return
    end

    wallet(order.side, order.base_currency, order.quote_currency)

    @wallet.with_lock do
      order.update!(status: :cancel)

      if order.sell?
        @wallet.balance += (order.volume * 100)
      elsif
        @wallet.balance += (order.volume * order.price * 100)
      end

      @wallet.save
    end

    render json: {
      status: :success,
      message: "Successfully canceled",
      payload: order # Specs show that this should be an empty string but I think its a mistake.
    }, status: 200
  end

  private

  def operate_on_wallet(order)
    if order.side == "sell"
      @wallet.balance -= (order.volume * 100)
    elsif order.side == "buy"
      @wallet.balance -= (order.price * 100 * order.volume)
    end
  end

  def order_processable?(side, volume, price)
    if side == "sell"
      (@wallet.balance / 100) >= volume
    elsif side == "buy"
      (@wallet.balance / 100) >= (volume * price)
    else
      false
    end
  end

  def wallet(side, base_curr, quote_curr)
    @wallet ||= case side
    when "sell"
     current_user.wallets.where(currency: base_curr).first
    when "buy"
     current_user.wallets.where(currency: quote_curr).first
    else
     nil
    end
  end
end
