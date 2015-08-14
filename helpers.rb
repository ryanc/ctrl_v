module ViewHelpers
  def app_revision
    revision_file = File.join(__dir__, "REVISION")
    if File.readable?(revision_file)
      IO.read(revision_file).strip
    else
      "unknown"
    end
  end
end
