

class SleepyTransmogrifier < Media::Transmogrifier

  def initialize
  end

  def name
    :sleepy
  end

  def input_types
    ['test']
  end

  def output_types
    ['test']
  end

  PROGRESS = [
    'starting up.',
    'getting ready to do some work.',
    'working hard.',
    'winding down.',
    'that was tough.',
    'all done now.'
  ]

  def run
    for str in PROGRESS
      yield str
      sleep 0.1
    end
    return :success
  end

end


