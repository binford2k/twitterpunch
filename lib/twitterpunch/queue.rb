class Twitterpunch::Queue
  def initialize(config)
    @config = config
    @file   = config[:queue][:file]
    @ttl    = config[:queue][:ttl]
  end

  def pop
    message = nil
    File.open(@file, 'r+') do |file|
      file.flock(File::LOCK_EX)
      queue = load(file)

      unless queue.empty?
        if RUBY_VERSION < "1.9.3"
          message = queue[queue.keys.sort.first]
        else
          message = queue.shift[1]
        end
      end

      save(file, queue)
    end
    message
  end

  def push(message)
    return unless message.is_a? String
    return if message.empty?
    File.open(@file, 'r+') do |file|
      file.flock(File::LOCK_EX)

      queue = load(file)
      queue[Time.now] = message
      save(file, queue)
    end
  end

  def load(file)
    queue   = YAML.load(file.read) rescue {}
    queue ||= {}

    # forcibly expire anything that's too old.
    queue.select { |k,v| (Time.now - k) < @ttl }
  end

  def save(file, queue)
    file.rewind
    file.truncate 0
    file.write(queue.to_yaml)
  end
end
