class CreateCspReports < ActiveRecord::Migration
  def change
    create_table :csp_reports do |t|
      t.text :document_uri
      t.text :referrer
      t.text :violated_directive
      t.text :effective_directive
      t.text :original_policy
      t.text :blocked_uri
      t.integer :status_code
      t.text :ip
      t.text :user_agent
      t.boolean :report_only

      t.timestamps
    end
  end
end

