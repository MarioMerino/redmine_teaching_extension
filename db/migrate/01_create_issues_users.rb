class CreateIssuesUsers < ActiveRecord::Migration
  def change
    create_table :issues_users, :id => false do |t|
      t.belongs_to :issue
      t.belongs_to :user
    end
  end
end