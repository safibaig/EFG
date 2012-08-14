module RefuteMacro
  def refute(val, message = '')
    assert !val, message
  end
end
