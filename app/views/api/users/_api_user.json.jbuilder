json.extract! api_user, :id, :username, :email, :password_digest, :session_token, :created_at, :updated_at
json.url api_user_url(api_user, format: :json)
