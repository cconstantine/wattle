class Backgrounder

  def initialize
    @queue = Queue.new
    background_thread

    at_exit do
      @queue << false
      background_thread.join()
    end
  end


  def queue &block
    p "queueing"
    @queue << block
  end

  def background_thread
    @thread ||= Thread.new do
      running = true
      while running || !@queue.empty?
        msg = @queue.pop
        if msg
          msg.call
        else
          running = false
        end
      end
    end
  end

end