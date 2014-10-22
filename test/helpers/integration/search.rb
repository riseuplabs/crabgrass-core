#
# Thinking Sphinx usually does not index pages during tests.
# In order to test Sphinx search properly include this module.
#
module Integration
  module Search
    def setup
      super
      @_ts_updates_enabled = ThinkingSphinx.updates_enabled?
      ThinkingSphinx.updates_enabled = true
      @_ts_deltas_enabled = ThinkingSphinx.deltas_enabled?
      ThinkingSphinx.deltas_enabled = true
      @_ts_suppress_delta_output = ThinkingSphinx.suppress_delta_output?
      ThinkingSphinx.suppress_delta_output = true
    end

    def teardown
      ThinkingSphinx.deltas_enabled = @_ts_deltas_enabled
      ThinkingSphinx.updates_enabled = @_ts_updates_enabled
      ThinkingSphinx.suppress_delta_output = @_ts_suppress_delta_output
      super
    end
  end
end

