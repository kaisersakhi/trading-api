class ApplicationController < ActionController::API

  protected

  attr_reader :current_user

  def verify_request
    token = request.headers["AUTHORIZATION"]&.split(" ")&.last

    begin
      decoded = JWT.decode(token, Rails.application.credentials.jwt_secret, true, algorithm: "HS256")[0]

      if Time.at(decoded["exp"]) <= Time.current
        render json: { error: "Token expired" }, status: :unauthorized
      end

      @current_user = User.find(decoded["user_id"])

    rescue JWT::DecodeError
      render json: { error: "Not Authorized" }, status: :unauthorized
    end
  end

  def create_jwt_token(email, password)
    user = User.find_by(email: email)

    if user&.authenticate(password)
      encode_token(user)
    end
  end

  def encode_token(user)
    paylod = {user_id: user.id, exp: (Time.now + 7.days).to_i }
    JWT.encode(paylod, Rails.application.credentials.jwt_secret, 'HS256')
  end
end
