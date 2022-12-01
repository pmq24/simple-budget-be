class TransactionController < ApplicationController
  def create
    user = require_auth
    body = parse_request_body

    transaction =
      Transaction.new amount: body['amount'],
                      note: body['note'],
                      group_id: body['group_id'],
                      user_id: user.id
    if transaction.invalid?
      render_bad_request_response transaction.errors
      return
    end

    transaction.save

    render_success_response transaction
  end

  def get_all
    user = require_auth

    render status: :ok, json: Transaction.where(user_id: user.id)
  end

  # TODO: as this method is used in other controllers as well, it should be refactored to make it more reusable
  def require_auth
    if not session.key? 'user_id'
      render status: :unauthorized, json: { 'message' => 'You have to log in' }
      return
    end

    user_id = session['user_id']
    user = User.find(user_id)

    if user.nil?
      render status: :unauthorized, json: { 'message' => 'You have to log in' }
      return
    end

    return user
  end

  def parse_request_body
    return JSON.parse request.body.read
  end

  def render_bad_request_response(errors)
    render status: :bad_request,
           json: {
             'message' =>
               'the provided data is invalid, refer to `errors` for details',
             'errors' => errors,
           }
  end

  def render_success_response(transaction)
    render status: :created,
           json: {
             'message' => 'the transaction was successfully created',
             'data' => transaction.to_json,
           }
  end
end
