
if Conf.remote_processing
  info 'remote processor activated: %s' % Conf.remote_processing
  RemoteJob.site = Conf.remote_processing
end

