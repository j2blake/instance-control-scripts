=begin
--------------------------------------------------------------------------------

Tweak the Hash class so we can add or remove values using the dot-notation.

--------------------------------------------------------------------------------
=end

class Hash
  def method_missing method_id, *args
    if args.empty?
      self[method_id.to_s]
    elsif method_id.to_s.end_with?('=')
      self[method_id.to_s.chop] = args[0]
    else
      super
    end
  end
end
