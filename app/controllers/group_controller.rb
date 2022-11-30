class GroupController < ApplicationController
  def create
    if not session.key? :user_id
      render status: :unauthorized, json: { 'message' => 'You have to log in' }
      return
    end

    user_id = session[:user_id]

    body = JSON.parse request.body.read
    group = Group.new name: body['name'], kind: body['kind'], user_id: user_id

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
end
