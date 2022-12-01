require_relative '../../lib/assets/application_auth_controller.rb'

class TransactionController < ApplicationAuthController
  def create
    user = get_logged_in_user
    if user.nil?
      return render status: :unauthorized, json: UNAUTHORIZED_RESPONSE_BODY
    end

    body = JSON.parse request.body.read

    transaction =
      Transaction.new amount: body['amount'],
                      note: body['note'],
                      group_id: body['group_id'],
                      user_id: user.id
    if transaction.invalid?
      render status: :bad_request,
             json: {
               message: 'the data provivded is invalid',
               data: transaction.errors,
             }
      return
    end

    transaction.save!

    render status: :created, json: transaction
  end

  def get_all
    user = get_logged_in_user
    if user.nil?
      return render status: :unauthorized, json: UNAUTHORIZED_RESPONSE_BODY
    end

    render status: :ok, json: Transaction.where(user_id: user.id)
  end
end
