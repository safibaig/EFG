class LenderLogo
  attr_reader :code

  def initialize(code)
    @code = code
  end

  def exists?
    path.exist?
  end

  def public_path
    "/#{relative_path}" 
  end

  def path
    Rails.root.join('public', relative_path)
  end

  private
  def relative_path
    "system/logos/#{code.upcase}.jpg"
  end
end
