class CspReportsController < ApplicationController  
  skip_before_action :verify_authenticity_token
  skip_before_action :require_user_signed_in

  def create
    report = JSON.parse(request.body.read)['csp-report']
    CspReport.create!(
      blocked_uri: report['blocked-uri'],
      document_uri: report['document-uri'],
      effective_directive: report['effective-directive'],
      ip: request.remote_ip,
      original_policy: report['original-policy'],
      report_only: params[:report_only] == 'true',
      referrer: report['referrer'],
      status_code: report['status-code'],
      user_agent: request.user_agent,
      violated_directive: report['violated-directive']
    )
    render nothing: true
  end
end  
