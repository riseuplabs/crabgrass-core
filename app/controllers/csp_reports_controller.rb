class CspReportsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    report = JSON.parse(request.body.read)['csp-report']
    Rails.logger.debug report.slice(
      'blocked_uri',
      'violated_directive',
      'referrer',
      'document-uri')
    CspReport.create!(
      blocked_uri: report['blocked-uri'],
      document_uri: report['document-uri'],
      effective_directive: report['effective-directive'],
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
