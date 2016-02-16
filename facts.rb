class Facts
  LETTERS = ('A'..'Z').map(&:to_sym)

  def initialize(*truths)
    self.reset
    truths.each do |let|
      verify_letter(let)
      @hash[let] = true
    end
  end

  def verify_letter(let)
    raise "facts do not contain #{let.inspect}" unless LETTERS.include?(let)
    true
  end

  def reset
    @hash = Hash[LETTERS.map {|l| [l, nil]}]
    true
  end

  def apply(reaction)
    reaction.each do |let, val|
      self[let] = val
    end
  end

  def [](let)
    verify_letter(let)
    @hash[let]
  end

  def []=(let, val)
    verify_letter(let)
    if val == :ambiguous
      @hash[let] = val
      return val
    end
    raise "fact value cannot be set to nil" if val.nil?
    val = val ? true : false
    if @hash[let].nil?
      @hash[let] = val
    else
      raise "fact #{let} was set to #{@hash[let].inspect} and then #{val.inspect}!" unless @hash[let] == val
    end
    val
  end

  def keys
    LETTERS
  end

  def to_s
    @hash.map do |let, val|
      next if val.nil?
      val = val.to_s.to_sym
      "#{let}:#{val.inspect}"
    end.compact.join(' ')
  end

  def facts_for(query)
    query.map do |let|
      verify_letter(let)
      val = @hash[let]
      case val
      when nil
        val = :nil
      when true, false
        val = val.to_s.to_sym
      end
      "#{let}:#{val.inspect}"
    end.compact.join(' ')
  end

  def clone
    lean_hash = @hash.clone.delete_if { |k, v| v.nil? }
    clone_facts = Facts.new()
    clone_facts.apply(lean_hash)
    clone_facts
  end

  def method_missing(method, *args)
    @hash.send(method, *args)
  end
end
