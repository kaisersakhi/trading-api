class UsersController < ApplicationController
  def sign_up
    # binding.irb
    if params[:email].blank? || params[:password].blank?
      render json: { msg: "email and password both are required to sign up" }, status: :bad_request

      return
    end

    @user = User.new(email: params[:email], password: params[:password])
    if @user.save
      render json: {
        status: "success",
        msg: "User successfully signed up",
        payload: {
          user_id: @user.id
        }
      }, status: 201

    else
      render json: { msg: @user.errors.full_messages.join(", ") }, status:  :bad_request
    end
  end

  def login
    if params[:email].blank? || params[:password].blank?
      render json: { msg: "email and password are both required" }, status: :bad_request

      return
    end

    token = create_jwt_token(params[:email], params[:password])

    if token.present?
      render json: { token: token }, status: :ok
    else
      render json: { msg: "email or password incorrect" }, status: :unauthorized
    end
  end
end
