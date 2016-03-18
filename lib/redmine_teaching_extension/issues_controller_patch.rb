require_dependency 'issues_controller'

class IssuesController

  append_before_filter :set_users, :only => [:create, :update]

  private

    def set_users
      @users = [User.find(params[:assigned_to_id])] ## user_id o assigned_to_id ??
      @users << User.find((params[:issue] && params[:issue][:assigned_to_ids]).reject!(&:blank?))
      @users.uniq!
      @issue.assignable_users << @users
    end

end