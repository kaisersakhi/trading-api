class DashboardController < ApplicationController
  def index
    unless current_user&.is_admin?
      render json: { error: "You must be an admin" }, status: :unauthorized

      return
    end

    from_date = Time.at(params[:from_time]) # I am expecting the the time would be sent in unix epoch format
    to_date = Time.at(params[:to_time])

    orders = Order.where(created_at: from_date..to_date)

    total_volumes = {}

    Currency.find_each do |currency|
      total_volumes[currency.symbol] = 0
    end

    orders.find_each do |order|
      if order.buy?
        total_volumes[order.base_currency.symbol] += order.volume
      else
        total_volumes[order.quote_currency.symbol] += order.volume * order.price
      end
    end

    render json: {
      status: :success,
      message: "Data fetched successfully",
      playload: total_volumes
    }
  end
end
