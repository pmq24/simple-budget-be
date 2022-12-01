require_relative '../../lib/assets/application_auth_controller.rb'

class GroupController < ApplicationAuthController
  def create
    user = get_logged_in_user
    if user.nil?
      return render status: :unauthorized, json: UNAUTHORIZED_RESPONSE_BODY
    end

    body = JSON.parse request.body.read
    group = Group.new name: body['name'], kind: body['kind'], user_id: user.id

    if group.invalid?
      errors = group.errors
      only_has_conflict_error =
        (
          errors.size == 1 and errors.key?('name') and
            errors['name'].size == 1 and
            errors['name'][0] ==
              I18n.t('activerecord.errors.models.group.attributes.name.taken')
        )

      render status: only_has_conflict_error ? :conflict : :bad_request,
             json: {
               'message' =>
                 'the provided data is invalid, refer to `errors` for details',
               'errors' => group.errors,
             }
      return
    end

    group.save!

    render status: :created,
           json: {
             'message' => 'group created successfully',
             'data' => group,
           }
  end

  def get_all
    user = get_logged_in_user
    if user.nil?
      return render status: :unauthorized, json: UNAUTHORIZED_RESPONSE_BODY
    end

    render status: :ok,
           json: {
             'message' => 'get all groups successfully',
             'data' => Group.where(user_id: user.id),
           }
  end
end
