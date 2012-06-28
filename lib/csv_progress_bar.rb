module CSVProgressBar
  def progress_bar
    @progress_bar ||= begin
      name = @io.respond_to?(:path) ? File.basename(@io.path) : 'CSV'
      ProgressBar.new(name, @io.size)
    end
  end

  def each(&block)
    itterator_with_progress = lambda {|row|
      block.call(row)
      progress_bar.set(self.pos)
    }
    super(&itterator_with_progress)
    progress_bar.finish
  end
end
