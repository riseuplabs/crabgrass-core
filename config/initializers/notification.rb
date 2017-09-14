ActiveSupport::Notifications.subscribe 'deprecation.rails' do |_name, _start, _finish, _id, payload|
  Rails.logger.debug "DEPRECATION: #{payload[:message]}"
end
